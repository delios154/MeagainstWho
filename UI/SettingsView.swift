import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = GameSettings()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Customize your game experience")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Settings toggles
                VStack(spacing: 16) {
                    SettingRow(
                        icon: "speaker.wave.2.fill",
                        title: "Sound Effects",
                        subtitle: "Play audio feedback",
                        isOn: $settings.soundOn
                    )
                    
                    SettingRow(
                        icon: "iphone.radiowaves.left.and.right",
                        title: "Haptic Feedback",
                        subtitle: "Vibration on actions",
                        isOn: $settings.hapticsOn
                    )
                    
                    SettingRow(
                        icon: "iphone.and.arrow.forward",
                        title: "Tilt Control",
                        subtitle: "Use device motion",
                        isOn: $settings.tiltOn
                    )
                    
                    SettingRow(
                        icon: "figure.walk",
                        title: "Reduce Motion",
                        subtitle: "Minimize animations",
                        isOn: $settings.reducedMotion
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Reset button
                Button(action: resetProgress) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Reset Progress")
                    }
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                }
                
                // Close button
                Button("Done") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding()
        }
    }
    
    private func resetProgress() {
        PersistenceService.shared.resetAllProgress()
        settings.reset()
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}