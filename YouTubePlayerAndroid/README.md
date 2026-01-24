# Protected YouTube Player for Android (Kotlin)

A secure YouTube player component for Android apps that prevents users from copying links, sharing videos, or leaving your app.

## Features

- **No Redirects**: Videos play entirely in-app - no jumps to YouTube app or browser
- **No Copy Link**: Context menu (long press) disabled
- **No Share Button**: YouTube share UI elements hidden
- **No Text Selection**: Users cannot select/copy any text
- **Quality Control**: Set video quality (240p to 1080p)
- **Speed Control**: Set playback rate (0.25x to 2x)

## Requirements

- Android 5.0+ (API 21+)
- Kotlin
- AndroidX

## Project Structure

```
YouTubePlayerAndroid/
├── app/
│   ├── src/main/
│   │   ├── java/com/demo/youtubeplayer/
│   │   │   ├── YouTubePlayerView.kt    # The player component
│   │   │   └── MainActivity.kt          # Demo activity
│   │   ├── res/layout/
│   │   │   └── activity_main.xml
│   │   └── AndroidManifest.xml
│   └── build.gradle
├── build.gradle
└── settings.gradle
```

## Quick Start

1. Open the project in Android Studio
2. Sync Gradle
3. Run on emulator or device

## Integration into Your App

### 1. Copy the YouTubePlayerView.kt file into your project

### 2. Add Internet permission to AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### 3. Add to your layout
```xml
<com.yourpackage.YouTubePlayerView
    android:id="@+id/playerView"
    android:layout_width="match_parent"
    android:layout_height="220dp"
    android:background="#000000" />
```

### 4. Use in your Activity/Fragment
```kotlin
val playerView = findViewById<YouTubePlayerView>(R.id.playerView)

// Set listener
playerView.setYouTubePlayerListener(object : YouTubePlayerView.YouTubePlayerListener {
    override fun onReady() {
        // Player is ready
    }
    override fun onStateChange(state: YouTubePlayerView.PlayerState) {
        // Handle state changes
    }
    override fun onPlaybackQualityChange(quality: YouTubePlayerView.PlaybackQuality) {}
    override fun onError(error: YouTubePlayerView.PlayerError) {}
    override fun onCurrentTimeChange(seconds: Float) {}
})

// Load video
playerView.loadVideo("dQw4w9WgXcQ")
```

## API

### Loading Videos
```kotlin
playerView.loadVideo("VIDEO_ID")
playerView.loadVideoUrl("https://youtube.com/watch?v=VIDEO_ID")
playerView.loadVideoById("VIDEO_ID")   // Load and play immediately
playerView.cueVideoById("VIDEO_ID")    // Load without playing
```

### Playback Control
```kotlin
playerView.play()
playerView.pause()
playerView.stop()
playerView.seekTo(30f)  // Seek to 30 seconds
```

### Volume
```kotlin
playerView.setVolume(50)  // 0-100
playerView.mute()
playerView.unMute()
```

### Quality & Speed
```kotlin
playerView.setPlaybackQuality(YouTubePlayerView.PlaybackQuality.HD720)
playerView.setPlaybackRate(1.5f)
```

### Cleanup
```kotlin
override fun onDestroy() {
    super.onDestroy()
    playerView.release()
}
```

## Player States
```kotlin
enum class PlayerState {
    UNSTARTED,
    ENDED,
    PLAYING,
    PAUSED,
    BUFFERING,
    CUED
}
```

## Quality Options
```kotlin
enum class PlaybackQuality {
    SMALL,      // 240p
    MEDIUM,     // 360p
    LARGE,      // 480p
    HD720,      // 720p
    HD1080,     // 1080p
    HIGH_RES,   // Best available
    AUTO        // Automatic
}
```

## License

MIT License - Free for personal and commercial use.
