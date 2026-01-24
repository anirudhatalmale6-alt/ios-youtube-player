//
//  ViewController.swift
//  YouTubePlayerDemo
//
//  Sample view controller demonstrating the protected YouTube player
//  with quality and speed controls
//
//  Compatible with iOS 12.0+
//

import UIKit

class ViewController: UIViewController {

    // MARK: - UI Elements

    private var playerView: YouTubePlayerView!
    private var statusLabel: UILabel!
    private var timeLabel: UILabel!
    private var videoIdTextField: UITextField!
    private var qualityButton: UIButton!
    private var speedButton: UIButton!

    // Current settings
    private var currentSpeed: Float = 1.0
    private var currentQuality: YouTubePlaybackQuality = .auto

    // CHANGE THIS VIDEO ID TO TEST DIFFERENT VIDEOS
    private let VIDEO_ID = "dQw4w9WgXcQ"  // Rick Astley - Never Gonna Give You Up (worldwide available)

    // Sample video IDs for testing (all worldwide available)
    private let sampleVideos = [
        ("Rick Astley", "dQw4w9WgXcQ"),
        ("Gangnam Style", "9bZkp7q19f0"),
        ("Despacito", "kJQP7kiw5Fk")
    ]

    // Speed options
    private let speedOptions: [(String, Float)] = [
        ("0.25x", 0.25),
        ("0.5x", 0.5),
        ("0.75x", 0.75),
        ("Normal", 1.0),
        ("1.25x", 1.25),
        ("1.5x", 1.5),
        ("1.75x", 1.75),
        ("2x", 2.0)
    ]

    // Quality options
    private let qualityOptions: [(String, YouTubePlaybackQuality)] = [
        ("Auto", .auto),
        ("Small (240p)", .small),
        ("Medium (360p)", .medium),
        ("Large (480p)", .large),
        ("HD 720p", .hd720),
        ("HD 1080p", .hd1080),
        ("High Res", .highRes)
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - iOS Version Compatible Colors

    private var backgroundColor: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return .white
        }
    }

    private var secondaryLabelColor: UIColor {
        if #available(iOS 13.0, *) {
            return .secondaryLabel
        } else {
            return .darkGray
        }
    }

    private var grayButtonColor: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray6
        } else {
            return UIColor(white: 0.95, alpha: 1.0)
        }
    }

    private var greenColor: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGreen
        } else {
            return UIColor(red: 0.2, green: 0.78, blue: 0.35, alpha: 1.0)
        }
    }

    private var blueColor: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBlue
        } else {
            return UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
        }
    }

    private var orangeColor: UIColor {
        if #available(iOS 13.0, *) {
            return .systemOrange
        } else {
            return UIColor(red: 1.0, green: 0.58, blue: 0.0, alpha: 1.0)
        }
    }

    private var redColor: UIColor {
        if #available(iOS 13.0, *) {
            return .systemRed
        } else {
            return .red
        }
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = backgroundColor

        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Protected YouTube Player"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Video ID input
        videoIdTextField = UITextField()
        videoIdTextField.placeholder = "Enter YouTube Video ID"
        videoIdTextField.borderStyle = .roundedRect
        videoIdTextField.autocapitalizationType = .none
        videoIdTextField.autocorrectionType = .no
        videoIdTextField.returnKeyType = .go
        videoIdTextField.delegate = self
        videoIdTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoIdTextField)

        // Load button
        let loadButton = UIButton(type: .system)
        loadButton.setTitle("Load", for: .normal)
        loadButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        loadButton.addTarget(self, action: #selector(loadButtonTapped), for: .touchUpInside)
        loadButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadButton)

        // YouTube Player View
        playerView = YouTubePlayerView()
        playerView.delegate = self
        playerView.backgroundColor = .black
        playerView.layer.cornerRadius = 8
        playerView.clipsToBounds = true
        playerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerView)

        // Playback control buttons stack (Play, Pause, Fullscreen)
        let playbackStack = createPlaybackButtons()
        playbackStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playbackStack)

        // Quality and Speed controls stack
        let settingsStack = createSettingsButtons()
        settingsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(settingsStack)

        // Status label
        statusLabel = UILabel()
        statusLabel.text = "Status: Not loaded"
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = secondaryLabelColor
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)

        // Time label
        timeLabel = UILabel()
        timeLabel.text = "Time: 0:00"
        timeLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        timeLabel.textColor = secondaryLabelColor
        timeLabel.textAlignment = .center
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeLabel)

        // Sample videos buttons
        let samplesLabel = UILabel()
        samplesLabel.text = "Sample Videos:"
        samplesLabel.font = .systemFont(ofSize: 14, weight: .medium)
        samplesLabel.textColor = secondaryLabelColor
        samplesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(samplesLabel)

        let samplesStack = createSampleButtons()
        samplesStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(samplesStack)

        // Info label
        let infoLabel = UILabel()
        infoLabel.text = "✓ No redirects  ✓ No copy link  ✓ No share"
        infoLabel.font = .systemFont(ofSize: 12)
        infoLabel.textColor = greenColor
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoLabel)

        // Layout
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            videoIdTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            videoIdTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            videoIdTextField.trailingAnchor.constraint(equalTo: loadButton.leadingAnchor, constant: -8),
            videoIdTextField.heightAnchor.constraint(equalToConstant: 40),

            loadButton.centerYAnchor.constraint(equalTo: videoIdTextField.centerYAnchor),
            loadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loadButton.widthAnchor.constraint(equalToConstant: 60),

            playerView.topAnchor.constraint(equalTo: videoIdTextField.bottomAnchor, constant: 12),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 9.0/16.0),

            playbackStack.topAnchor.constraint(equalTo: playerView.bottomAnchor, constant: 12),
            playbackStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            settingsStack.topAnchor.constraint(equalTo: playbackStack.bottomAnchor, constant: 10),
            settingsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            statusLabel.topAnchor.constraint(equalTo: settingsStack.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            timeLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            samplesLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 16),
            samplesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            samplesStack.topAnchor.constraint(equalTo: samplesLabel.bottomAnchor, constant: 8),
            samplesStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            infoLabel.topAnchor.constraint(equalTo: samplesStack.bottomAnchor, constant: 16),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        // Auto-load the video
        videoIdTextField.text = VIDEO_ID
        playerView.load(videoId: VIDEO_ID)
    }

    private func createPlaybackButtons() -> UIStackView {
        let playButton = createButton(title: "▶ Play", action: #selector(playTapped))
        let pauseButton = createButton(title: "⏸ Pause", action: #selector(pauseTapped))
        let fullscreenButton = createButton(title: "⛶ Full", action: #selector(fullscreenTapped))

        let stack = UIStackView(arrangedSubviews: [playButton, pauseButton, fullscreenButton])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        return stack
    }

    private func createSettingsButtons() -> UIStackView {
        // Quality button
        qualityButton = UIButton(type: .system)
        qualityButton.setTitle("Quality: Auto ▼", for: .normal)
        qualityButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        qualityButton.backgroundColor = blueColor.withAlphaComponent(0.1)
        qualityButton.setTitleColor(blueColor, for: .normal)
        qualityButton.layer.cornerRadius = 8
        qualityButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        qualityButton.addTarget(self, action: #selector(qualityTapped), for: .touchUpInside)

        // Speed button
        speedButton = UIButton(type: .system)
        speedButton.setTitle("Speed: 1x ▼", for: .normal)
        speedButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        speedButton.backgroundColor = orangeColor.withAlphaComponent(0.1)
        speedButton.setTitleColor(orangeColor, for: .normal)
        speedButton.layer.cornerRadius = 8
        speedButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        speedButton.addTarget(self, action: #selector(speedTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [qualityButton, speedButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }

    private func createSampleButtons() -> UIStackView {
        var buttons: [UIButton] = []

        for (index, video) in sampleVideos.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(video.0, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 13)
            button.tag = index
            button.addTarget(self, action: #selector(sampleVideoTapped(_:)), for: .touchUpInside)
            buttons.append(button)
        }

        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.spacing = 16
        return stack
    }

    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        button.backgroundColor = grayButtonColor
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    // MARK: - Actions

    @objc private func loadButtonTapped() {
        guard let videoId = videoIdTextField.text, !videoId.isEmpty else { return }
        videoIdTextField.resignFirstResponder()
        playerView.load(videoId: videoId)
        statusLabel.text = "Status: Loading..."
    }

    @objc private func playTapped() {
        playerView.play()
    }

    @objc private func pauseTapped() {
        playerView.pause()
    }

    @objc private func fullscreenTapped() {
        playerView.enterFullscreen(from: self)
    }

    @objc private func sampleVideoTapped(_ sender: UIButton) {
        let video = sampleVideos[sender.tag]
        videoIdTextField.text = video.1
        playerView.load(videoId: video.1)
        statusLabel.text = "Status: Loading \(video.0)..."
    }

    // MARK: - Quality Selection

    @objc private func qualityTapped() {
        let alert = UIAlertController(title: "Select Quality", message: nil, preferredStyle: .actionSheet)

        for (name, quality) in qualityOptions {
            let action = UIAlertAction(title: name, style: .default) { [weak self] _ in
                self?.setQuality(quality, name: name)
            }
            // Mark current selection
            if quality == currentQuality {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // iPad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = qualityButton
            popover.sourceRect = qualityButton.bounds
        }

        present(alert, animated: true)
    }

    private func setQuality(_ quality: YouTubePlaybackQuality, name: String) {
        currentQuality = quality
        playerView.setPlaybackQuality(quality)
        qualityButton.setTitle("Quality: \(name.replacingOccurrences(of: " (", with: "\n(").components(separatedBy: "\n").first ?? name) ▼", for: .normal)
    }

    // MARK: - Speed Selection

    @objc private func speedTapped() {
        let alert = UIAlertController(title: "Select Speed", message: nil, preferredStyle: .actionSheet)

        for (name, speed) in speedOptions {
            let action = UIAlertAction(title: name, style: .default) { [weak self] _ in
                self?.setSpeed(speed, name: name)
            }
            // Mark current selection
            if speed == currentSpeed {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // iPad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = speedButton
            popover.sourceRect = speedButton.bounds
        }

        present(alert, animated: true)
    }

    private func setSpeed(_ speed: Float, name: String) {
        currentSpeed = speed
        playerView.setPlaybackRate(speed)
        speedButton.setTitle("Speed: \(name) ▼", for: .normal)
    }

    // MARK: - Helpers

    private func formatTime(_ seconds: Float) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loadButtonTapped()
        return true
    }
}

// MARK: - YouTubePlayerViewDelegate

extension ViewController: YouTubePlayerViewDelegate {

    func playerReady(_ playerView: YouTubePlayerView) {
        statusLabel.text = "Status: Ready"
        statusLabel.textColor = secondaryLabelColor
    }

    func player(_ playerView: YouTubePlayerView, didChangeStateTo state: YouTubePlayerState) {
        statusLabel.textColor = secondaryLabelColor
        switch state {
        case .unstarted:
            statusLabel.text = "Status: Unstarted"
        case .ended:
            statusLabel.text = "Status: Ended"
        case .playing:
            statusLabel.text = "Status: Playing"
        case .paused:
            statusLabel.text = "Status: Paused"
        case .buffering:
            statusLabel.text = "Status: Buffering..."
        case .cued:
            statusLabel.text = "Status: Cued"
        }
    }

    func player(_ playerView: YouTubePlayerView, didPlayTime time: Float) {
        timeLabel.text = "Time: \(formatTime(time))"
    }

    func player(_ playerView: YouTubePlayerView, didReceiveError error: YouTubePlayerError) {
        var errorMessage = "Error: "
        switch error {
        case .videoNotFound:
            errorMessage += "Video not found"
        case .notEmbeddable, .notEmbeddableAlt:
            errorMessage += "Video not embeddable"
        case .invalidParameter:
            errorMessage += "Invalid parameter"
        case .html5Error:
            errorMessage += "HTML5 error"
        case .unknown:
            errorMessage += "Unknown error"
        }
        statusLabel.text = errorMessage
        statusLabel.textColor = redColor
    }
}
