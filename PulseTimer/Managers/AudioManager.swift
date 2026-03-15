import AVFoundation

class AudioManager: ObservableObject {
    private var silentPlayer: AVAudioPlayer?
    private var beepPlayer: AVAudioPlayer?

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
            print("AudioManager: Failed to configure session: \(error)")
        }
    }

    func startSilentLoop() {
        guard let url = Bundle.main.url(forResource: "silence", withExtension: "mp3") else {
            print("AudioManager: silence.mp3 not found in bundle")
            return
        }
        do {
            silentPlayer = try AVAudioPlayer(contentsOf: url)
            silentPlayer?.numberOfLoops = -1
            silentPlayer?.volume = 0.0
            silentPlayer?.prepareToPlay()
            silentPlayer?.play()
        } catch {
            print("AudioManager: Failed to start silent loop: \(error)")
        }
    }

    func stopSilentLoop() {
        silentPlayer?.stop()
        silentPlayer = nil
    }

    func playBeep() {
        guard let url = Bundle.main.url(forResource: "beep", withExtension: "mp3") else {
            print("AudioManager: beep.mp3 not found in bundle")
            return
        }
        do {
            beepPlayer = try AVAudioPlayer(contentsOf: url)
            beepPlayer?.numberOfLoops = 0
            beepPlayer?.prepareToPlay()
            beepPlayer?.play()
        } catch {
            print("AudioManager: Failed to play beep: \(error)")
        }
    }

    @objc private func handleInterruption(notification: Notification) {
        guard
            let info = notification.userInfo,
            let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else { return }

        if type == .ended {
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("AudioManager: Failed to reactivate session after interruption: \(error)")
            }
            if silentPlayer != nil {
                startSilentLoop()
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
