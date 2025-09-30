import AVFoundation
import UIKit
import Combine

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
        let sampleRate: Double = 44100.0
        let samples = Int(sampleRate * duration)
        let amplitudeScalar: Double = 0.1

        var pcm16 = [Int16]()
        pcm16.reserveCapacity(samples)

        for i in 0..<samples {
            let time = Double(i) / sampleRate
            let sampleValue = sin(2.0 * Double.pi * frequency * time) * amplitudeScalar
            let clamped = max(-1.0, min(1.0, sampleValue))
            let intSample = Int16(clamped * Double(Int16.max))
            pcm16.append(intSample)
        }

        // Build a minimal WAV header for 16-bit PCM mono
        let byteRate = UInt32(sampleRate * 2.0) // sampleRate * channels(1) * bitsPerSample(16)/8
        let blockAlign: UInt16 = 2 // channels(1) * bitsPerSample(16)/8
        let bitsPerSample: UInt16 = 16
        let dataChunkSize = UInt32(pcm16.count * MemoryLayout<Int16>.size)
        let riffChunkSize = 36 + dataChunkSize

        var data = Data()
        // RIFF header
        data.append(contentsOf: Array("RIFF".utf8))
        data.append(UInt32(riffChunkSize).littleEndianData)
        data.append(contentsOf: Array("WAVE".utf8))
        // fmt chunk
        data.append(contentsOf: Array("fmt ".utf8))
        data.append(UInt32(16).littleEndianData)                 // Subchunk1Size for PCM
        data.append(UInt16(1).littleEndianData)                  // AudioFormat = 1 (PCM)
        data.append(UInt16(1).littleEndianData)                  // NumChannels = 1
        data.append(UInt32(sampleRate).littleEndianData)         // SampleRate
        data.append(byteRate.littleEndianData)                   // ByteRate
        data.append(blockAlign.littleEndianData)                 // BlockAlign
        data.append(bitsPerSample.littleEndianData)              // BitsPerSample
        // data chunk
        data.append(contentsOf: Array("data".utf8))
        data.append(dataChunkSize.littleEndianData)
        // PCM data
        pcm16.withUnsafeBufferPointer { ptr in
            data.append(contentsOf: UnsafeRawBufferPointer(ptr))
        }

        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.volume = 0.3
            audioPlayer?.prepareToPlay()
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

private extension FixedWidthInteger {
    var littleEndianData: Data {
        var value = self.littleEndian
        return Data(bytes: &value, count: MemoryLayout<Self>.size)
    }
}