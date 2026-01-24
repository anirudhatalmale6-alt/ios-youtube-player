//
//  YouTubePlayerView.swift
//  YouTubePlayer
//
//  A self-contained UIView subclass that plays YouTube videos in-app
//  using WKWebView and the YouTube IFrame Player API.
//  No redirects to YouTube app or Safari.
//
//  Swift 5 | iOS 12.0+
//

import UIKit
import WebKit

// MARK: - Player State Enum

/// Represents the current state of the YouTube player
public enum YouTubePlayerState: Int {
    case unstarted = -1
    case ended = 0
    case playing = 1
    case paused = 2
    case buffering = 3
    case cued = 5
}

// MARK: - Player Quality Enum

/// Video quality options for YouTube playback
public enum YouTubePlaybackQuality: String {
    case small = "small"
    case medium = "medium"
    case large = "large"
    case hd720 = "hd720"
    case hd1080 = "hd1080"
    case highRes = "highres"
    case auto = "default"
}

// MARK: - Delegate Protocol

/// Delegate protocol for receiving player events
public protocol YouTubePlayerViewDelegate: AnyObject {
    func playerReady(_ playerView: YouTubePlayerView)
    func player(_ playerView: YouTubePlayerView, didChangeStateTo state: YouTubePlayerState)
    func player(_ playerView: YouTubePlayerView, didChangeQualityTo quality: YouTubePlaybackQuality)
    func player(_ playerView: YouTubePlayerView, didReceiveError error: YouTubePlayerError)
    func player(_ playerView: YouTubePlayerView, didPlayTime time: Float)
}

// Default implementations (all optional)
public extension YouTubePlayerViewDelegate {
    func playerReady(_ playerView: YouTubePlayerView) {}
    func player(_ playerView: YouTubePlayerView, didChangeStateTo state: YouTubePlayerState) {}
    func player(_ playerView: YouTubePlayerView, didChangeQualityTo quality: YouTubePlaybackQuality) {}
    func player(_ playerView: YouTubePlayerView, didReceiveError error: YouTubePlayerError) {}
    func player(_ playerView: YouTubePlayerView, didPlayTime time: Float) {}
}

// MARK: - Player Error Enum

/// Errors that can occur during YouTube playback
public enum YouTubePlayerError: Int {
    case invalidParameter = 2
    case html5Error = 5
    case videoNotFound = 100
    case notEmbeddable = 101
    case notEmbeddableAlt = 150
    case unknown = -1
}

// MARK: - YouTubePlayerView

/// A UIView subclass that embeds a YouTube player using WKWebView and IFrame API.
/// All playback occurs within the app - no redirects to YouTube app or Safari.
public class YouTubePlayerView: UIView {

    // MARK: - Properties

    /// Delegate for receiving player events
    public weak var delegate: YouTubePlayerViewDelegate?

    /// The WKWebView used for playback
    private var webView: WKWebView!

    /// Current video ID being played
    private(set) public var currentVideoId: String?

    /// Whether the player is ready to receive commands
    private(set) public var isReady: Bool = false

    /// Configuration for the player
    private var playerVars: [String: Any] = [:]

    // MARK: - Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupWebView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWebView()
    }

    /// Initialize with custom player variables
    /// - Parameter playerVars: Dictionary of YouTube IFrame player parameters
    public convenience init(frame: CGRect, playerVars: [String: Any]) {
        self.init(frame: frame)
        self.playerVars = playerVars
    }

    // MARK: - Setup

    private func setupWebView() {
        // Configure WKWebView to allow inline playback and autoplay
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        // Create web view
        webView = WKWebView(frame: bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.isOpaque = false
        webView.backgroundColor = .black

        // Set navigation delegate to intercept external links
        webView.navigationDelegate = self

        // Add message handler for JavaScript callbacks
        webView.configuration.userContentController.add(LeakAvoider(delegate: self), name: "youtubePlayer")

        addSubview(webView)
    }

    // MARK: - Public Methods

    /// Load and prepare a YouTube video for playback
    /// - Parameter videoId: The YouTube video ID (e.g., "dQw4w9WgXcQ")
    public func load(videoId: String) {
        currentVideoId = videoId
        isReady = false

        let html = generateHTML(videoId: videoId)
        webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube.com"))
    }

    /// Load a video by full YouTube URL
    /// - Parameter url: Full YouTube URL (supports youtube.com/watch and youtu.be formats)
    public func load(url: String) {
        if let videoId = extractVideoId(from: url) {
            load(videoId: videoId)
        }
    }

    /// Start or resume video playback
    public func play() {
        evaluatePlayerCommand("player.playVideo();")
    }

    /// Pause video playback
    public func pause() {
        evaluatePlayerCommand("player.pauseVideo();")
    }

    /// Stop video playback
    public func stop() {
        evaluatePlayerCommand("player.stopVideo();")
    }

    /// Seek to a specific time in the video
    /// - Parameters:
    ///   - seconds: Time to seek to in seconds
    ///   - allowSeekAhead: Whether to allow seeking beyond buffered content
    public func seek(to seconds: Float, allowSeekAhead: Bool = true) {
        evaluatePlayerCommand("player.seekTo(\(seconds), \(allowSeekAhead));")
    }

    /// Mute the video
    public func mute() {
        evaluatePlayerCommand("player.mute();")
    }

    /// Unmute the video
    public func unmute() {
        evaluatePlayerCommand("player.unMute();")
    }

    /// Set playback volume
    /// - Parameter volume: Volume level (0-100)
    public func setVolume(_ volume: Int) {
        let clampedVolume = max(0, min(100, volume))
        evaluatePlayerCommand("player.setVolume(\(clampedVolume));")
    }

    /// Set playback rate
    /// - Parameter rate: Playback rate (0.25, 0.5, 1, 1.5, 2)
    public func setPlaybackRate(_ rate: Float) {
        evaluatePlayerCommand("player.setPlaybackRate(\(rate));")
    }

    /// Set video quality
    /// - Parameter quality: Desired playback quality
    public func setPlaybackQuality(_ quality: YouTubePlaybackQuality) {
        evaluatePlayerCommand("player.setPlaybackQuality('\(quality.rawValue)');")
    }

    /// Get current playback time
    /// - Parameter completion: Callback with current time in seconds
    public func getCurrentTime(completion: @escaping (Float) -> Void) {
        webView.evaluateJavaScript("player.getCurrentTime();") { result, _ in
            if let time = result as? NSNumber {
                completion(time.floatValue)
            }
        }
    }

    /// Get video duration
    /// - Parameter completion: Callback with duration in seconds
    public func getDuration(completion: @escaping (Float) -> Void) {
        webView.evaluateJavaScript("player.getDuration();") { result, _ in
            if let duration = result as? NSNumber {
                completion(duration.floatValue)
            }
        }
    }

    /// Load a new video and start playing
    /// - Parameter videoId: The YouTube video ID
    public func cueVideo(videoId: String) {
        currentVideoId = videoId
        evaluatePlayerCommand("player.cueVideoById('\(videoId)');")
    }

    /// Load a new video and start playing immediately
    /// - Parameter videoId: The YouTube video ID
    public func loadVideo(videoId: String) {
        currentVideoId = videoId
        evaluatePlayerCommand("player.loadVideoById('\(videoId)');")
    }

    // MARK: - Fullscreen Support

    /// Present the player in fullscreen mode
    /// - Parameter viewController: The view controller to present from
    public func enterFullscreen(from viewController: UIViewController) {
        let fullscreenVC = YouTubeFullscreenViewController(playerView: self)
        fullscreenVC.modalPresentationStyle = .fullScreen
        viewController.present(fullscreenVC, animated: true)
    }

    // MARK: - Private Methods

    private func evaluatePlayerCommand(_ command: String) {
        guard isReady else { return }
        webView.evaluateJavaScript(command, completionHandler: nil)
    }

    private func extractVideoId(from url: String) -> String? {
        // Handle youtu.be short URLs
        if url.contains("youtu.be/") {
            return url.components(separatedBy: "youtu.be/").last?.components(separatedBy: "?").first
        }

        // Handle youtube.com/watch URLs
        if let urlComponents = URLComponents(string: url),
           let queryItems = urlComponents.queryItems,
           let videoId = queryItems.first(where: { $0.name == "v" })?.value {
            return videoId
        }

        // Handle youtube.com/embed URLs
        if url.contains("/embed/") {
            return url.components(separatedBy: "/embed/").last?.components(separatedBy: "?").first
        }

        return nil
    }

    private func generateHTML(videoId: String) -> String {
        // Merge default player vars with custom ones
        var vars: [String: Any] = [
            "playsinline": 1,
            "controls": 1,
            "showinfo": 0,
            "rel": 0,
            "modestbranding": 1,
            "fs": 0,  // Disable YouTube's native fullscreen (we handle it ourselves)
            "origin": "https://www.youtube.com"
        ]

        // Override with custom player vars
        for (key, value) in playerVars {
            vars[key] = value
        }

        // Convert to JSON string
        let playerVarsJSON = vars.map { "\"\($0.key)\": \($0.value)" }.joined(separator: ", ")

        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                html, body { width: 100%; height: 100%; background: #000; overflow: hidden; }
                #player { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }
            </style>
        </head>
        <body>
            <div id="player"></div>
            <script src="https://www.youtube.com/iframe_api"></script>
            <script>
                var player;
                var progressInterval;

                function onYouTubeIframeAPIReady() {
                    player = new YT.Player('player', {
                        videoId: '\(videoId)',
                        playerVars: { \(playerVarsJSON) },
                        events: {
                            'onReady': onPlayerReady,
                            'onStateChange': onPlayerStateChange,
                            'onPlaybackQualityChange': onPlaybackQualityChange,
                            'onError': onPlayerError
                        }
                    });
                }

                function onPlayerReady(event) {
                    sendMessage('ready', {});
                    startProgressTracking();
                }

                function onPlayerStateChange(event) {
                    sendMessage('stateChange', { state: event.data });
                }

                function onPlaybackQualityChange(event) {
                    sendMessage('qualityChange', { quality: event.data });
                }

                function onPlayerError(event) {
                    sendMessage('error', { code: event.data });
                }

                function startProgressTracking() {
                    progressInterval = setInterval(function() {
                        if (player && player.getCurrentTime) {
                            var time = player.getCurrentTime();
                            sendMessage('progress', { time: time });
                        }
                    }, 500);
                }

                function sendMessage(event, data) {
                    var message = { event: event, data: data };
                    window.webkit.messageHandlers.youtubePlayer.postMessage(JSON.stringify(message));
                }
            </script>
        </body>
        </html>
        """
    }

    // MARK: - Cleanup

    deinit {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "youtubePlayer")
    }
}

// MARK: - WKNavigationDelegate

extension YouTubePlayerView: WKNavigationDelegate {

    /// Intercept navigation to prevent redirects to YouTube app or Safari
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let urlString = url.absoluteString

        // Allow YouTube iframe API and player resources
        if urlString.contains("youtube.com/iframe_api") ||
           urlString.contains("youtube.com/embed") ||
           urlString.contains("youtube.com/s/player") ||
           urlString.contains("ytimg.com") ||
           urlString.contains("googlevideo.com") ||
           urlString.hasPrefix("data:") ||
           urlString.hasPrefix("about:") {
            decisionHandler(.allow)
            return
        }

        // Block navigation to external YouTube pages (prevents app/Safari redirects)
        if urlString.contains("youtube.com/watch") ||
           urlString.contains("youtu.be/") ||
           navigationAction.navigationType == .linkActivated {
            decisionHandler(.cancel)
            return
        }

        // Allow initial HTML load and other internal navigation
        if navigationAction.navigationType == .other {
            decisionHandler(.allow)
            return
        }

        decisionHandler(.cancel)
    }
}

// MARK: - WKScriptMessageHandler

extension YouTubePlayerView: WKScriptMessageHandler {

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? String,
              let data = body.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let event = json["event"] as? String,
              let eventData = json["data"] as? [String: Any] else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            switch event {
            case "ready":
                self.isReady = true
                self.delegate?.playerReady(self)

            case "stateChange":
                if let stateRaw = eventData["state"] as? Int,
                   let state = YouTubePlayerState(rawValue: stateRaw) {
                    self.delegate?.player(self, didChangeStateTo: state)
                }

            case "qualityChange":
                if let qualityRaw = eventData["quality"] as? String,
                   let quality = YouTubePlaybackQuality(rawValue: qualityRaw) {
                    self.delegate?.player(self, didChangeQualityTo: quality)
                }

            case "error":
                if let code = eventData["code"] as? Int {
                    let error = YouTubePlayerError(rawValue: code) ?? .unknown
                    self.delegate?.player(self, didReceiveError: error)
                }

            case "progress":
                if let time = eventData["time"] as? Double {
                    self.delegate?.player(self, didPlayTime: Float(time))
                }

            default:
                break
            }
        }
    }
}

// MARK: - LeakAvoider (prevents retain cycle with WKWebView)

private class LeakAvoider: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?

    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}

// MARK: - Fullscreen View Controller

/// A simple fullscreen container for the YouTube player
public class YouTubeFullscreenViewController: UIViewController {

    private weak var playerView: YouTubePlayerView?
    private var originalSuperview: UIView?
    private var originalFrame: CGRect = .zero

    init(playerView: YouTubePlayerView) {
        self.playerView = playerView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        guard let playerView = playerView else { return }

        // Store original position
        originalSuperview = playerView.superview
        originalFrame = playerView.frame

        // Move player to fullscreen
        playerView.removeFromSuperview()
        playerView.frame = view.bounds
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(playerView)

        // Add close button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    public override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc private func closeTapped() {
        guard let playerView = playerView else {
            dismiss(animated: true)
            return
        }

        // Restore player to original position
        playerView.removeFromSuperview()
        playerView.frame = originalFrame
        originalSuperview?.addSubview(playerView)

        dismiss(animated: true)
    }
}
