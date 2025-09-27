import AVFoundation
import UIKit

class AudioService: ObservableObject {
    static let shared = AudioService()
    
    private var audioPlayer: AVAudioPlayer?
    private let settings = GameSettings()
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playSound(_ soundName: String) {
        guard settings.soundOn else { return }
        
        // Generate simple tones for different sounds
        let frequency = getFrequency(for: soundName)
        let duration = 0.3
        
        generateTone(frequency: frequency, duration: duration)
    }
    
    private func getFrequency(for soundName: String) -> Double {
        switch soundName {
        case "snare": return 200.0
        case "fanfare": return 523.25 // C5
        case "thunder": return 100.0
        case "marimba": return 440.0 // A4
        case "sparkle": return 800.0
        case "beep": return 1000.0
        default: return 440.0
        }
    }
    
    private func generateTone(frequency: Double, duration: Double) {
        let sampleRate = 44100.0
        let samples = Int(sampleRate * duration)
        var audioData = [Float]()
        
        for i in 0..<samples {
            let time = Double(i) / sampleRate
            let amplitude: Float = 0.1 * sin(2.0 * Double.pi * frequency * time)
            audioData.append(amplitude)
        }
        
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: AVAudioFrameCount(samples))!
        
        audioBuffer.frameLength = AVAudioFrameCount(samples)
        let channelData = audioBuffer.floatChannelData![0]
        
        for i in 0..<samples {
            channelData[i] = audioData[i]
        }
        
        do {
            audioPlayer = try AVAudioPlayer(data: audioBuffer.audioBufferList.pointee.mBuffers)
            audioPlayer?.volume = 0.3
            audioPlayer?.play()
        } catch {
            print("Failed to play audio: \(error)")
        }
    }
    
    func playSuccessSound() {
        playSound("sparkle")
    }
    
    func playFailSound() {
        playSound("beep")
    }
}