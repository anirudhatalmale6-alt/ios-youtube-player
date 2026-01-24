# Add project specific ProGuard rules here.

# Keep JavaScript interface for WebView
-keepclassmembers class com.demo.youtubeplayer.YouTubePlayerView$YouTubeJSInterface {
    public *;
}

-keepattributes JavascriptInterface
