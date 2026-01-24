package com.demo.youtubeplayer

import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat

/**
 * Simple demo - single video player with quality and speed controls
 * No input fields - just plays one video
 */
class MainActivity : AppCompatActivity(), YouTubePlayerView.YouTubePlayerListener {

    private lateinit var playerView: YouTubePlayerView
    private lateinit var statusText: TextView
    private lateinit var timeText: TextView
    private lateinit var qualityButton: Button
    private lateinit var speedButton: Button

    // CHANGE THIS VIDEO ID TO TEST DIFFERENT VIDEOS
    private val VIDEO_ID = "dSyP3Uc30HE"  // Client's test video

    private var currentSpeed = 1.0f
    private var currentQuality = YouTubePlayerView.PlaybackQuality.AUTO

    // Speed options
    private val speedOptions = listOf(
        Pair("0.25x", 0.25f),
        Pair("0.5x", 0.5f),
        Pair("0.75x", 0.75f),
        Pair("Normal", 1.0f),
        Pair("1.25x", 1.25f),
        Pair("1.5x", 1.5f),
        Pair("1.75x", 1.75f),
        Pair("2x", 2.0f)
    )

    // Quality options
    private val qualityOptions = listOf(
        Pair("Auto", YouTubePlayerView.PlaybackQuality.AUTO),
        Pair("240p", YouTubePlayerView.PlaybackQuality.SMALL),
        Pair("360p", YouTubePlayerView.PlaybackQuality.MEDIUM),
        Pair("480p", YouTubePlayerView.PlaybackQuality.LARGE),
        Pair("720p", YouTubePlayerView.PlaybackQuality.HD720),
        Pair("1080p", YouTubePlayerView.PlaybackQuality.HD1080)
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        setupViews()
        setupPlayer()

        // Auto-load the video
        playerView.loadVideo(VIDEO_ID)
    }

    private fun setupViews() {
        playerView = findViewById(R.id.playerView)
        statusText = findViewById(R.id.statusText)
        timeText = findViewById(R.id.timeText)
        qualityButton = findViewById(R.id.qualityButton)
        speedButton = findViewById(R.id.speedButton)

        // Play button
        findViewById<Button>(R.id.playButton).setOnClickListener {
            playerView.play()
        }

        // Pause button
        findViewById<Button>(R.id.pauseButton).setOnClickListener {
            playerView.pause()
        }

        // Quality button
        qualityButton.setOnClickListener {
            showQualityDialog()
        }

        // Speed button
        speedButton.setOnClickListener {
            showSpeedDialog()
        }
    }

    private fun setupPlayer() {
        playerView.setYouTubePlayerListener(this)
    }

    private fun showQualityDialog() {
        val qualityNames = qualityOptions.map { it.first }.toTypedArray()
        val currentIndex = qualityOptions.indexOfFirst { it.second == currentQuality }

        AlertDialog.Builder(this)
            .setTitle("Select Quality")
            .setSingleChoiceItems(qualityNames, currentIndex) { dialog, which ->
                val selected = qualityOptions[which]
                currentQuality = selected.second
                playerView.setPlaybackQuality(selected.second)
                qualityButton.text = "Quality: ${selected.first}"
                dialog.dismiss()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun showSpeedDialog() {
        val speedNames = speedOptions.map { it.first }.toTypedArray()
        val currentIndex = speedOptions.indexOfFirst { it.second == currentSpeed }

        AlertDialog.Builder(this)
            .setTitle("Select Speed")
            .setSingleChoiceItems(speedNames, currentIndex) { dialog, which ->
                val selected = speedOptions[which]
                currentSpeed = selected.second
                playerView.setPlaybackRate(selected.second)
                speedButton.text = "Speed: ${selected.first}"
                dialog.dismiss()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun formatTime(seconds: Float): String {
        val mins = (seconds / 60).toInt()
        val secs = (seconds % 60).toInt()
        return String.format("%d:%02d", mins, secs)
    }

    // YouTubePlayerListener callbacks

    override fun onReady() {
        runOnUiThread {
            statusText.text = "Status: Ready"
            statusText.setTextColor(ContextCompat.getColor(this, android.R.color.white))
        }
    }

    override fun onStateChange(state: YouTubePlayerView.PlayerState) {
        runOnUiThread {
            statusText.setTextColor(ContextCompat.getColor(this, android.R.color.white))
            statusText.text = when (state) {
                YouTubePlayerView.PlayerState.UNSTARTED -> "Status: Unstarted"
                YouTubePlayerView.PlayerState.ENDED -> "Status: Ended"
                YouTubePlayerView.PlayerState.PLAYING -> "Status: Playing"
                YouTubePlayerView.PlayerState.PAUSED -> "Status: Paused"
                YouTubePlayerView.PlayerState.BUFFERING -> "Status: Buffering..."
                YouTubePlayerView.PlayerState.CUED -> "Status: Cued"
            }
        }
    }

    override fun onPlaybackQualityChange(quality: YouTubePlayerView.PlaybackQuality) {
        // Quality changed
    }

    override fun onError(error: YouTubePlayerView.PlayerError) {
        runOnUiThread {
            statusText.text = when (error) {
                YouTubePlayerView.PlayerError.VIDEO_NOT_FOUND -> "Error: Video not found"
                YouTubePlayerView.PlayerError.NOT_EMBEDDABLE,
                YouTubePlayerView.PlayerError.NOT_EMBEDDABLE_ALT -> "Error: Video not embeddable"
                YouTubePlayerView.PlayerError.INVALID_PARAMETER -> "Error: Invalid parameter"
                YouTubePlayerView.PlayerError.HTML5_ERROR -> "Error: HTML5 error"
                YouTubePlayerView.PlayerError.UNKNOWN -> "Error: Unknown error"
            }
            statusText.setTextColor(ContextCompat.getColor(this, android.R.color.holo_red_light))
        }
    }

    override fun onCurrentTimeChange(seconds: Float) {
        runOnUiThread {
            timeText.text = "Time: ${formatTime(seconds)}"
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        playerView.release()
    }
}
