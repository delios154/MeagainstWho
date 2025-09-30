import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var gameCoordinator = GameCoordinator()
    @State private var showingSettings = false
    
    var body: some View {
        ZStack {
            // SpriteKit Game View
            SpriteView(scene: gameCoordinator.currentScene)
                .ignoresSafeArea()
                .overlay(alignment: .topLeading) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(gameCoordinator.totalStars)")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
                    .padding()
                    .allowsHitTesting(false)
                }
                .overlay(alignment: .topTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(20)
                    }
                    .padding()
                }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onAppear {
            gameCoordinator.start()
        }
    }
}