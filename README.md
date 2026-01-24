# YouTubePlayerView

A self-contained Swift 5 UIView that plays YouTube videos entirely within your iOS app using WKWebView and the YouTube IFrame Player API. **No redirects to the YouTube app or Safari.**

## Requirements

- iOS 12.0+
- Swift 5
- Xcode 12+

## Installation

1. **Copy the file** `YouTubePlayerView.swift` into your Xcode project
2. That's it - no CocoaPods, SPM, or external dependencies required

## Info.plist Configuration

Add these entries to your `Info.plist` if not already present:

```xml
<!-- Allow arbitrary loads for YouTube resources (or use specific domains) -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoadsInWebContent</key>
    <true/>
</dict>
```

## Basic Usage

### 1. Create and Add the Player

```swift
import UIKit

class VideoViewController: UIViewController {

    private var playerView: YouTubePlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create the player
        playerView = YouTubePlayerView(frame: CGRect(x: 0, y: 100, width: view.bounds.width, height: 220))
        playerView.delegate = self
        view.addSubview(playerView)

        // Load a video by ID
        playerView.load(videoId: "dQw4w9WgXcQ")
    }
}
```

### 2. Load Videos

```swift
// Load by video ID
playerView.load(videoId: "dQw4w9WgXcQ")

// Load by URL (supports youtube.com/watch and youtu.be formats)
playerView.load(url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
playerView.load(url: "https://youtu.be/dQw4w9WgXcQ")

// Load a new video while player is ready (without reloading iframe)
playerView.loadVideo(videoId: "newVideoId")  // Starts immediately
playerView.cueVideo(videoId: "newVideoId")   // Cues without playing
```

### 3. Control Playback

```swift
playerView.play()
playerView.pause()
playerView.stop()

// Seek to 30 seconds
playerView.seek(to: 30)

// Volume control (0-100)
playerView.setVolume(50)
playerView.mute()
playerView.unmute()

// Playback rate (0.25, 0.5, 1, 1.5, 2)
playerView.setPlaybackRate(1.5)

// Quality (when available)
playerView.setPlaybackQuality(.hd720)
```

### 4. Get Playback Info

```swift
// Get current time
playerView.getCurrentTime { time in
    print("Current time: \(time) seconds")
}

// Get video duration
playerView.getDuration { duration in
    print("Duration: \(duration) seconds")
}
```

### 5. Fullscreen Mode

```swift
// Present fullscreen (handled entirely in-app)
playerView.enterFullscreen(from: self)
```

## Delegate Methods

Implement `YouTubePlayerViewDelegate` to receive player events:

```swift
extension VideoViewController: YouTubePlayerViewDelegate {

    func playerReady(_ playerView: YouTubePlayerView) {
        print("Player is ready")
        // Safe to call play(), pause(), etc.
    }

    func player(_ playerView: YouTubePlayerView, didChangeStateTo state: YouTubePlayerState) {
        switch state {
        case .playing:
            print("Video is playing")
        case .paused:
            print("Video is paused")
        case .ended:
            print("Video ended")
        case .buffering:
            print("Buffering...")
        default:
            break
        }
    }

    func player(_ playerView: YouTubePlayerView, didPlayTime time: Float) {
        // Called every 500ms with current playback time
        print("Current time: \(time)")
    }

    func player(_ playerView: YouTubePlayerView, didReceiveError error: YouTubePlayerError) {
        switch error {
        case .videoNotFound:
            print("Video not found")
        case .notEmbeddable:
            print("Video cannot be embedded")
        default:
            print("Player error: \(error)")
        }
    }

    func player(_ playerView: YouTubePlayerView, didChangeQualityTo quality: YouTubePlaybackQuality) {
        print("Quality changed to: \(quality.rawValue)")
    }
}
```

## Custom Player Variables

Pass custom YouTube IFrame player parameters during initialization:

```swift
let playerVars: [String: Any] = [
    "autoplay": 1,           // Auto-start playback
    "controls": 0,           // Hide player controls
    "loop": 1,               // Loop the video
    "start": 30,             // Start at 30 seconds
    "end": 60,               // End at 60 seconds
    "cc_load_policy": 1      // Show closed captions
]

let playerView = YouTubePlayerView(frame: frame, playerVars: playerVars)
```

See [YouTube IFrame Player Parameters](https://developers.google.com/youtube/player_parameters) for all available options.

## Player States

```swift
public enum YouTubePlayerState: Int {
    case unstarted = -1
    case ended = 0
    case playing = 1
    case paused = 2
    case buffering = 3
    case cued = 5
}
```

## Error Codes

```swift
public enum YouTubePlayerError: Int {
    case invalidParameter = 2    // Invalid video ID
    case html5Error = 5          // HTML5 player error
    case videoNotFound = 100     // Video not found/removed
    case notEmbeddable = 101     // Video owner disabled embedding
    case notEmbeddableAlt = 150  // Same as 101
}
```

## How It Works

1. The player uses `WKWebView` to load a local HTML page containing the YouTube IFrame Player API
2. All navigation is intercepted to prevent redirects to external YouTube pages or apps
3. JavaScript-to-Swift communication via `WKScriptMessageHandler` delivers player events
4. The `LeakAvoider` class prevents retain cycles between the view and WKWebView

## Important Notes

- **No YouTube API Key Required**: Uses the public IFrame Player API
- **In-App Fullscreen**: Custom fullscreen implementation keeps users in your app
- **Memory Management**: Properly handles cleanup to prevent memory leaks
- **Thread Safety**: All delegate callbacks are dispatched to the main thread

## Example Project Structure

```
YourApp/
├── YouTubePlayerView.swift    // Add this file
├── ViewController.swift       // Your view controller
└── Info.plist                 // Add NSAllowsArbitraryLoadsInWebContent
```

## License

MIT License - Free to use in personal and commercial projects.
