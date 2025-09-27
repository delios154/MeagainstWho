import SpriteKit

protocol Microgame {
    func start(in scene: SKScene)
    func update(_ currentTime: TimeInterval)
    func handleTouch(_ location: CGPoint)
    func teardown()
}

class MicrogameFactory {
    static func createRandomMicrogame() -> Microgame {
        let microgames: [() -> Microgame] = [
            { PopBalloonsGame() },
            { TraceLineGame() },
            { BalanceStackGame() },
            { TapOnBeatGame() },
            { CatchFallingGame() },
            { AvoidWallsGame() },
            { WhackMoleGame() },
            { MemoryPairGame() },
            { SliderStopGame() },
            { BubbleWrapGame() },
            { QuickTargetGame() }
        ]
        
        // Check if tilt is enabled for TiltBalance
        let settings = GameSettings()
        var availableGames = microgames
        
        if settings.tiltOn {
            availableGames.append { TiltBalanceGame() }
        }
        
        return availableGames.randomElement()!()
    }
}