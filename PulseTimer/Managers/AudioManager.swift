import AVFoundation

class AudioManager: ObservableObject {
    private var silentPlayer: AVAudioPlayer?
    private var beepPlayer: AVAudioPlayer?
    private var bingPlayer: AVAudioPlayer?
    private var pipPlayer: AVAudioPlayer?

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioManager: session config failed: \(error)")
        }
        silentPlayer = makePlayer(resource: "silence")
        silentPlayer?.numberOfLoops = -1
        silentPlayer?.volume = 0.0
        silentPlayer?.prepareToPlay()

        beepPlayer = makePlayer(resource: "beep")
        beepPlayer?.prepareToPlay()

        bingPlayer = makePlayer(resource: "bing")
        bingPlayer?.prepareToPlay()

        pipPlayer = makePlayer(resource: "pip")
        pipPlayer?.prepareToPlay()
    }

    func startSilentLoop() {
        guard let player = silentPlayer else { return }
        if !player.isPlaying { player.play() }
    }

    func stopSilentLoop() {
        silentPlayer?.stop()
        silentPlayer?.currentTime = 0
    }

    func playBeep() {
        beepPlayer?.currentTime = 0
        beepPlayer?.play()
    }

    func playBing() {
        try? AVAudioSession.sharedInstance().setActive(true)
        bingPlayer?.currentTime = 0
        bingPlayer?.play()
    }

    func playPip() {
        try? AVAudioSession.sharedInstance().setActive(true)
        pipPlayer?.currentTime = 0
        pipPlayer?.play()
    }

    private func makePlayer(resource: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "wav") else {
            print("AudioManager: \(resource).wav not found in bundle")
            return nil
        }
        do {
            return try AVAudioPlayer(contentsOf: url)
        } catch {
            print("AudioManager: failed to load \(resource).wav: \(error)")
            return nil
        }
    }

    @objc private func handleInterruption(notification: Notification) {
        guard
            let info = notification.userInfo,
            let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else { return }

        if type == .ended {
            try? AVAudioSession.sharedInstance().setActive(true)
            startSilentLoop()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
