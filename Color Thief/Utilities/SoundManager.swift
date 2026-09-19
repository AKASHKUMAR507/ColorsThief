import AVFoundation

/// AVFoundation wrapper: background music loop + tap / fanfare effects,
/// gated by the Sound and Music settings (UserDefaults). Uses the ambient
/// session so it mixes with other audio and respects the silent switch.
final class SoundManager {
    
    static let shared = SoundManager()
    
    private var music: AVAudioPlayer?
    private var effectPlayers: [String: [AVAudioPlayer]] = [:]
    private var observer: NSObjectProtocol?
    
    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        
        // React to the Settings toggles (and Home's Music button)
        observer = NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification,
                                                          object: nil, queue: .main) { [weak self] _ in
            self?.syncMusicWithSettings()
        }
    }
    
    // MARK: - Settings
    
    static var isSoundEnabled: Bool {
        UserDefaults.standard.object(forKey: UserDefaultsKeys.soundEnabled) as? Bool ?? true
    }
    
    static var isMusicEnabled: Bool {
        UserDefaults.standard.object(forKey: UserDefaultsKeys.musicEnabled) as? Bool ?? true
    }
    
    // MARK: - Music
    
    /// Starts the loop if music is enabled and it isn't already playing.
    func startMusic() {
        guard Self.isMusicEnabled else { return }
        if music == nil, let url = Bundle.main.url(forResource: "music_loop", withExtension: "caf") {
            music = try? AVAudioPlayer(contentsOf: url)
            music?.numberOfLoops = -1
            music?.volume = 0.55
            music?.prepareToPlay()
        }
        guard let music, !music.isPlaying else { return }
        music.play()
    }
    
    func stopMusic() {
        music?.pause()
    }
    
    private func syncMusicWithSettings() {
        Self.isMusicEnabled ? startMusic() : stopMusic()
    }
    
    // MARK: - Effects
    
    func playTap()     { play("tap", ext: "caf", volume: 0.9) }
    func playFanfare() { play("fanfare", ext: "m4a", volume: 0.9) }
    
    /// Small per-sound pool so rapid taps overlap instead of cutting each other off.
    private func play(_ name: String, ext: String, volume: Float) {
        guard Self.isSoundEnabled else { return }
        var pool = effectPlayers[name] ?? []
        if let free = pool.first(where: { !$0.isPlaying }) {
            free.volume = volume
            free.currentTime = 0
            free.play()
            return
        }
        guard pool.count < 4, let url = Bundle.main.url(forResource: name, withExtension: ext),
              let player = try? AVAudioPlayer(contentsOf: url) else { return }
        player.volume = volume
        player.prepareToPlay()
        player.play()
        pool.append(player)
        effectPlayers[name] = pool
    }
}
