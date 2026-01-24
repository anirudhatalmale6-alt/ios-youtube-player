//
//  ViewController.swift
//  YouTubePlayerDemo
//
//  Sample view controller demonstrating the protected YouTube player
//

import UIKit

class ViewController: UIViewController {

    // MARK: - UI Elements

    private var playerView: YouTubePlayerView!
    private var statusLabel: UILabel!
    private var timeLabel: UILabel!
    private var videoIdTextField: UITextField!

    // Sample video IDs for testing
    private let sampleVideos = [
        ("Big Buck Bunny", "aqz-KE-bpKQ"),
        ("Sintel Trailer", "eRsGyueVLvQ"),
        ("Elephants Dream", "TLkA0RELQ1g")
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground

        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Protected YouTube Player"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
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

        // Control buttons stack
        let controlsStack = createControlButtons()
        controlsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlsStack)

        // Status label
        statusLabel = UILabel()
        statusLabel.text = "Status: Not loaded"
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)

        // Time label
        timeLabel = UILabel()
        timeLabel.text = "Time: 0:00"
        timeLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        timeLabel.textColor = .secondaryLabel
        timeLabel.textAlignment = .center
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeLabel)

        // Sample videos buttons
        let samplesLabel = UILabel()
        samplesLabel.text = "Sample Videos:"
        samplesLabel.font = .systemFont(ofSize: 14, weight: .medium)
        samplesLabel.textColor = .secondaryLabel
        samplesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(samplesLabel)

        let samplesStack = createSampleButtons()
        samplesStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(samplesStack)

        // Info label
        let infoLabel = UILabel()
        infoLabel.text = "✓ No redirects to YouTube app\n✓ No copy link option\n✓ No share button\n✓ Content stays in-app"
        infoLabel.font = .systemFont(ofSize: 13)
        infoLabel.textColor = .systemGreen
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoLabel)

        // Layout
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            videoIdTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            videoIdTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            videoIdTextField.trailingAnchor.constraint(equalTo: loadButton.leadingAnchor, constant: -8),
            videoIdTextField.heightAnchor.constraint(equalToConstant: 44),

            loadButton.centerYAnchor.constraint(equalTo: videoIdTextField.centerYAnchor),
            loadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loadButton.widthAnchor.constraint(equalToConstant: 60),

            playerView.topAnchor.constraint(equalTo: videoIdTextField.bottomAnchor, constant: 16),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 9.0/16.0),

            controlsStack.topAnchor.constraint(equalTo: playerView.bottomAnchor, constant: 16),
            controlsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            statusLabel.topAnchor.constraint(equalTo: controlsStack.bottomAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            timeLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            samplesLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 20),
            samplesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            samplesStack.topAnchor.constraint(equalTo: samplesLabel.bottomAnchor, constant: 8),
            samplesStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            infoLabel.topAnchor.constraint(equalTo: samplesStack.bottomAnchor, constant: 20),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        // Load first sample video
        let firstVideo = sampleVideos[0]
        videoIdTextField.text = firstVideo.1
        playerView.load(videoId: firstVideo.1)
    }

    private func createControlButtons() -> UIStackView {
        let playButton = createButton(title: "▶️ Play", action: #selector(playTapped))
        let pauseButton = createButton(title: "⏸️ Pause", action: #selector(pauseTapped))
        let fullscreenButton = createButton(title: "⛶ Fullscreen", action: #selector(fullscreenTapped))

        let stack = UIStackView(arrangedSubviews: [playButton, pauseButton, fullscreenButton])
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
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
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
    }

    func player(_ playerView: YouTubePlayerView, didChangeStateTo state: YouTubePlayerState) {
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
        statusLabel.textColor = .systemRed
    }
}
