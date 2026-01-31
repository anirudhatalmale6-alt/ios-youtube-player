package com.demo.youtubeplayer

import android.annotation.SuppressLint
import android.content.Context
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.View
import android.webkit.*
import android.widget.FrameLayout

/**
 * YouTubePlayerView - A protected YouTube player for Android
 *
 * Features:
 * - No redirects to YouTube app or browser
 * - No copy link functionality
 * - No share button
 * - No text selection
 * - No context menu (long press)
 *
 * Uses WebView + YouTube IFrame API for in-app playback
 */
class YouTubePlayerView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : FrameLayout(context, attrs, defStyleAttr) {

    private var webView: WebView? = null
    private var listener: YouTubePlayerListener? = null
    private var isReady = false
    private var currentVideoId: String? = null

    // Player states matching YouTube IFrame API
    enum class PlayerState(val value: Int) {
        UNSTARTED(-1),
        ENDED(0),
        PLAYING(1),
        PAUSED(2),
        BUFFERING(3),
        CUED(5)
    }

    // Playback quality options
    enum class PlaybackQuality(val value: String) {
        SMALL("small"),
        MEDIUM("medium"),
        LARGE("large"),
        HD720("hd720"),
        HD1080("hd1080"),
        HIGH_RES("highres"),
        AUTO("default")
    }

    // Error codes from YouTube IFrame API
    enum class PlayerError(val code: Int) {
        INVALID_PARAMETER(2),
        HTML5_ERROR(5),
        VIDEO_NOT_FOUND(100),
        NOT_EMBEDDABLE(101),
        NOT_EMBEDDABLE_ALT(150),
        UNKNOWN(-1)
    }

    interface YouTubePlayerListener {
        fun onReady()
        fun onStateChange(state: PlayerState)
        fun onPlaybackQualityChange(quality: PlaybackQuality)
        fun onError(error: PlayerError)
        fun onCurrentTimeChange(seconds: Float)
    }

    init {
        setupWebView()
    }

    @SuppressLint("SetJavaScriptEnabled", "ClickableViewAccessibility")
    private fun setupWebView() {
        webView = WebView(context).apply {
            layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
            setBackgroundColor(android.graphics.Color.BLACK)

            settings.apply {
                javaScriptEnabled = true
                mediaPlaybackRequiresUserGesture = false
                domStorageEnabled = true
                loadWithOverviewMode = true
                useWideViewPort = true
                cacheMode = WebSettings.LOAD_DEFAULT

                // Disable zoom
                setSupportZoom(false)
                builtInZoomControls = false
                displayZoomControls = false
            }

            // Disable long press context menu
            setOnLongClickListener { true }
            isLongClickable = false
            isHapticFeedbackEnabled = false

            // Block text selection
            setOnTouchListener { v, event ->
                if (event.action == MotionEvent.ACTION_DOWN) {
                    v.requestFocus()
                }
                false
            }

            webViewClient = object : WebViewClient() {
                override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                    val url = request?.url?.toString() ?: return false

                    // Allow YouTube embed and player resources
                    if (url.contains("youtube.com") ||
                        url.contains("youtube-nocookie.com") ||
                        url.contains("ytimg.com") ||
                        url.contains("googlevideo.com") ||
                        url.contains("ggpht.com") ||
                        url.contains("gstatic.com") ||
                        url.contains("google.com") ||
                        url.contains("googleads") ||
                        url.contains("doubleclick") ||
                        url.startsWith("data:") ||
                        url.startsWith("about:") ||
                        url.startsWith("blob:")) {
                        // Block only watch/share URLs
                        if (url.contains("youtube.com/watch") || url.contains("youtu.be/")) {
                            return true
                        }
                        return false
                    }

                    return true // Block all other external navigation
                }

                override fun onPageFinished(view: WebView?, url: String?) {
                    super.onPageFinished(view, url)
                    // Inject CSS to disable selection after page load
                    view?.evaluateJavascript("""
                        (function() {
                            var style = document.createElement('style');
                            style.innerHTML = '* { -webkit-touch-callout: none !important; -webkit-user-select: none !important; user-select: none !important; }';
                            document.head.appendChild(style);
                        })();
                    """.trimIndent(), null)
                }
            }

            webChromeClient = object : WebChromeClient() {
                // Handle fullscreen if needed
            }

            addJavascriptInterface(YouTubeJSInterface(), "AndroidPlayer")
        }

        addView(webView)
    }

    /**
     * Load a YouTube video by ID
     */
    fun loadVideo(videoId: String) {
        currentVideoId = videoId
        isReady = false

        // Generate and load HTML with YouTube IFrame API
        val html = generateHTML(videoId)

        // Encode HTML and load as data URL - works better with YouTube IFrame API
        val encodedHtml = android.util.Base64.encodeToString(
            html.toByteArray(Charsets.UTF_8),
            android.util.Base64.NO_PADDING
        )
        webView?.loadData(encodedHtml, "text/html; charset=utf-8", "base64")
    }

    /**
     * Load a YouTube video by URL
     */
    fun loadVideoUrl(url: String) {
        extractVideoId(url)?.let { videoId ->
            loadVideo(videoId)
        }
    }

    /**
     * Play the video
     */
    fun play() {
        if (isReady) {
            webView?.evaluateJavascript("player.playVideo();", null)
        }
    }

    /**
     * Pause the video
     */
    fun pause() {
        if (isReady) {
            webView?.evaluateJavascript("player.pauseVideo();", null)
        }
    }

    /**
     * Stop the video
     */
    fun stop() {
        if (isReady) {
            webView?.evaluateJavascript("player.stopVideo();", null)
        }
    }

    /**
     * Seek to a specific time in seconds
     */
    fun seekTo(seconds: Float, allowSeekAhead: Boolean = true) {
        if (isReady) {
            webView?.evaluateJavascript("player.seekTo($seconds, $allowSeekAhead);", null)
        }
    }

    /**
     * Mute the video
     */
    fun mute() {
        if (isReady) {
            webView?.evaluateJavascript("player.mute();", null)
        }
    }

    /**
     * Unmute the video
     */
    fun unMute() {
        if (isReady) {
            webView?.evaluateJavascript("player.unMute();", null)
        }
    }

    /**
     * Set volume (0-100)
     */
    fun setVolume(volume: Int) {
        if (isReady) {
            val clampedVolume = volume.coerceIn(0, 100)
            webView?.evaluateJavascript("player.setVolume($clampedVolume);", null)
        }
    }

    /**
     * Set playback rate (0.25, 0.5, 1, 1.5, 2)
     */
    fun setPlaybackRate(rate: Float) {
        if (isReady) {
            webView?.evaluateJavascript("player.setPlaybackRate($rate);", null)
        }
    }

    /**
     * Set playback quality
     */
    fun setPlaybackQuality(quality: PlaybackQuality) {
        if (isReady) {
            webView?.evaluateJavascript("player.setPlaybackQuality('${quality.value}');", null)
        }
    }

    /**
     * Load a new video while player is ready
     */
    fun cueVideoById(videoId: String) {
        currentVideoId = videoId
        if (isReady) {
            webView?.evaluateJavascript("player.cueVideoById('$videoId');", null)
        }
    }

    /**
     * Load and play a new video immediately
     */
    fun loadVideoById(videoId: String) {
        currentVideoId = videoId
        if (isReady) {
            webView?.evaluateJavascript("player.loadVideoById('$videoId');", null)
        }
    }

    /**
     * Set listener for player events
     */
    fun setYouTubePlayerListener(listener: YouTubePlayerListener) {
        this.listener = listener
    }

    /**
     * Clean up resources
     */
    fun release() {
        webView?.apply {
            stopLoading()
            clearHistory()
            removeAllViews()
            destroy()
        }
        webView = null
    }

    private fun extractVideoId(url: String): String? {
        // Handle youtu.be short URLs
        if (url.contains("youtu.be/")) {
            return url.substringAfter("youtu.be/").substringBefore("?")
        }

        // Handle youtube.com/watch URLs
        if (url.contains("youtube.com/watch")) {
            val uri = android.net.Uri.parse(url)
            return uri.getQueryParameter("v")
        }

        // Handle youtube.com/embed URLs
        if (url.contains("/embed/")) {
            return url.substringAfter("/embed/").substringBefore("?")
        }

        return null
    }

    private fun generateHTML(videoId: String): String {
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
                <style>
                    * {
                        margin: 0;
                        padding: 0;
                        box-sizing: border-box;
                        -webkit-touch-callout: none !important;
                        -webkit-user-select: none !important;
                        user-select: none !important;
                    }
                    html, body {
                        width: 100%;
                        height: 100%;
                        background: #000;
                        overflow: hidden;
                    }
                    #player {
                        position: absolute;
                        top: 0;
                        left: 0;
                        width: 100%;
                        height: 100%;
                    }
                    /* HIDE ALL YOUTUBE LOGOS AND BRANDING */
                    .ytp-watermark, .ytp-watermark-container {
                        display: none !important;
                        visibility: hidden !important;
                        opacity: 0 !important;
                        pointer-events: none !important;
                    }
                    .ytp-youtube-button, .ytp-button[aria-label*="YouTube"],
                    a[href*="youtube.com"], .ytp-title-link {
                        display: none !important;
                        visibility: hidden !important;
                    }
                    .ytp-share-button { display: none !important; }
                    .ytp-watch-later-button { display: none !important; }
                    .ytp-pause-overlay, .ytp-pause-overlay-container { display: none !important; }
                    .ytp-endscreen-content, .ytp-endscreen-previous, .ytp-endscreen-next,
                    .ytp-ce-element, .ytp-ce-covering-overlay { display: none !important; }
                    .ytp-cards-button, .ytp-cards-teaser { display: none !important; }
                    .ytp-title, .ytp-title-text, .ytp-title-channel,
                    .ytp-title-channel-logo, .ytp-chrome-top { display: none !important; }
                    .ytp-impression-link, .ytp-show-cards-title { display: none !important; }
                    .ytp-overflow-button { display: none !important; }

                    /* Overlay to block logo clicks */
                    #logo-blocker {
                        position: absolute;
                        bottom: 0;
                        right: 0;
                        width: 120px;
                        height: 50px;
                        z-index: 9998;
                        background: transparent;
                        pointer-events: auto;
                    }
                </style>
            </head>
            <body>
                <div id="player"></div>
                <div id="logo-blocker"></div>
                <script src="https://www.youtube.com/iframe_api"></script>
                <script>
                    var player;
                    var progressInterval;

                    // Disable context menu
                    document.addEventListener('contextmenu', function(e) {
                        e.preventDefault();
                        e.stopPropagation();
                        return false;
                    }, true);

                    // Disable selection
                    document.addEventListener('selectstart', function(e) {
                        e.preventDefault();
                        return false;
                    });

                    // Disable copy
                    document.addEventListener('copy', function(e) {
                        e.preventDefault();
                        return false;
                    });

                    function onYouTubeIframeAPIReady() {
                        player = new YT.Player('player', {
                            videoId: '$videoId',
                            playerVars: {
                                'playsinline': 1,
                                'controls': 1,
                                'showinfo': 0,
                                'rel': 0,
                                'modestbranding': 1,
                                'fs': 0,
                                'disablekb': 0,
                                'enablejsapi': 1
                            },
                            events: {
                                'onReady': onPlayerReady,
                                'onStateChange': onPlayerStateChange,
                                'onPlaybackQualityChange': onPlaybackQualityChange,
                                'onError': onPlayerError
                            }
                        });
                    }

                    function onPlayerReady(event) {
                        AndroidPlayer.onReady();
                        startProgressTracking();
                    }

                    function onPlayerStateChange(event) {
                        AndroidPlayer.onStateChange(event.data);
                    }

                    function onPlaybackQualityChange(event) {
                        AndroidPlayer.onPlaybackQualityChange(event.data);
                    }

                    function onPlayerError(event) {
                        AndroidPlayer.onError(event.data);
                    }

                    function startProgressTracking() {
                        progressInterval = setInterval(function() {
                            if (player && player.getCurrentTime) {
                                var time = player.getCurrentTime();
                                AndroidPlayer.onCurrentTime(time);
                            }
                        }, 500);
                    }
                </script>
            </body>
            </html>
        """.trimIndent()
    }

    /**
     * JavaScript interface for communication from WebView to Android
     */
    private inner class YouTubeJSInterface {

        @JavascriptInterface
        fun onReady() {
            post {
                isReady = true
                listener?.onReady()
            }
        }

        @JavascriptInterface
        fun onStateChange(state: Int) {
            post {
                val playerState = PlayerState.values().find { it.value == state } ?: PlayerState.UNSTARTED
                listener?.onStateChange(playerState)
            }
        }

        @JavascriptInterface
        fun onPlaybackQualityChange(quality: String) {
            post {
                val playbackQuality = PlaybackQuality.values().find { it.value == quality } ?: PlaybackQuality.AUTO
                listener?.onPlaybackQualityChange(playbackQuality)
            }
        }

        @JavascriptInterface
        fun onError(errorCode: Int) {
            post {
                val error = PlayerError.values().find { it.code == errorCode } ?: PlayerError.UNKNOWN
                listener?.onError(error)
            }
        }

        @JavascriptInterface
        fun onCurrentTime(seconds: Float) {
            post {
                listener?.onCurrentTimeChange(seconds)
            }
        }
    }
}
