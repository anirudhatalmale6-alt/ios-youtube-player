# Protected YouTube Player for iOS

A secure YouTube player component for iOS apps that prevents users from copying links, sharing videos, or leaving your app.

## Features

- **No Redirects**: Videos play entirely in-app - no jumps to YouTube app or Safari
- **No Copy Link**: Context menu (long press) disabled
- **No Share Button**: YouTube share UI elements hidden
- **No Text Selection**: Users cannot select/copy any text
- **No Link Preview**: 3D Touch/Haptic Touch previews disabled
- **End Screen Hidden**: Related videos at the end are blocked

## Project Structure

```
YouTubePlayerDemo/
├── YouTubePlayerDemo.xcodeproj    # Open this in Xcode
└── YouTubePlayerDemo/
    ├── AppDelegate.swift
    ├── ViewController.swift        # Demo view controller
    ├── YouTubePlayerView.swift     # The player component (copy this to your project)
    ├── Info.plist
    └── Base.lproj/
        └── LaunchScreen.storyboard
```

## Quick Start

1. Open `YouTubePlayerDemo.xcodeproj` in Xcode
2. Build and run on simulator or device
3. Test the player with sample videos

## Integration into Your App

1. Copy `YouTubePlayerView.swift` into your project
2. Add to Info.plist:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoadsInWebContent</key>
    <true/>
</dict>
```

3. Use in your view controller:
```swift
let playerView = YouTubePlayerView(frame: CGRect(x: 0, y: 100, width: view.bounds.width, height: 220))
playerView.delegate = self
view.addSubview(playerView)

// Load by video ID
playerView.load(videoId: "dQw4w9WgXcQ")

// Or load by URL
playerView.load(url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
```

## API

### Loading Videos
```swift
playerView.load(videoId: "VIDEO_ID")
playerView.load(url: "https://youtube.com/watch?v=VIDEO_ID")
playerView.loadVideo(videoId: "VIDEO_ID")  // Load and play immediately
playerView.cueVideo(videoId: "VIDEO_ID")   // Load without playing
```

### Playback Control
```swift
playerView.play()
playerView.pause()
playerView.stop()
playerView.seek(to: 30)  // Seek to 30 seconds
```

### Volume
```swift
playerView.setVolume(50)  // 0-100
playerView.mute()
playerView.unmute()
```

### Fullscreen
```swift
playerView.enterFullscreen(from: self)  // In-app fullscreen
```

### Get Playback Info
```swift
playerView.getCurrentTime { time in print(time) }
playerView.getDuration { duration in print(duration) }
```

## Delegate

```swift
extension YourVC: YouTubePlayerViewDelegate {
    func playerReady(_ playerView: YouTubePlayerView) { }
    func player(_ playerView: YouTubePlayerView, didChangeStateTo state: YouTubePlayerState) { }
    func player(_ playerView: YouTubePlayerView, didPlayTime time: Float) { }
    func player(_ playerView: YouTubePlayerView, didReceiveError error: YouTubePlayerError) { }
}
```

## Requirements

- iOS 12.0+
- Swift 5
- Xcode 12+

## License

MIT License - Free for personal and commercial use.
