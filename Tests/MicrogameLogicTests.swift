import XCTest
@testable import MeAgainstWho

class MicrogameLogicTests: XCTestCase {
    
    func testPopBalloonsGame() {
        let game = PopBalloonsGame()
        let scene = SKScene()
        
        game.start(in: scene)
        
        // Simulate popping balloons
        for _ in 0..<5 {
            game.handleTouch(CGPoint(x: 100, y: 100))
        }
        
        // Game should complete successfully
        game.update(0.0)
        
        game.teardown()
    }
    
    func testTraceLineGame() {
        let game = TraceLineGame()
        let scene = SKScene()
        
        game.start(in: scene)
        
        // Simulate tracing along path
        let pathPoints = [
            CGPoint(x: 50, y: 400),
            CGPoint(x: 100, y: 400),
            CGPoint(x: 150, y: 400),
            CGPoint(x: 200, y: 400),
            CGPoint(x: 250, y: 400),
            CGPoint(x: 300, y: 400)
        ]
        
        for point in pathPoints {
            game.handleTouch(point)
        }
        
        game.update(0.0)
        
        game.teardown()
    }
    
    func testBalanceStackGame() {
        let game = BalanceStackGame()
        let scene = SKScene()
        
        game.start(in: scene)
        
        // Simulate dropping blocks
        for _ in 0..<5 {
            game.handleTouch(CGPoint(x: 200, y: 100))
        }
        
        game.update(0.0)
        
        game.teardown()
    }
    
    func testTapOnBeatGame() {
        let game = TapOnBeatGame()
        let scene = SKScene()
        
        game.start(in: scene)
        
        // Simulate tapping targets
        for _ in 0..<5 {
            game.handleTouch(CGPoint(x: 200, y: 400))
        }
        
        game.update(0.0)
        
        game.teardown()
    }
    
    func testCatchFallingGame() {
        let game = CatchFallingGame()
        let scene = SKScene()
        
        game.start(in: scene)
        
        // Simulate catching items
        for _ in 0..<5 {
            game.handleTouch(CGPoint(x: 200, y: 100))
        }
        
        game.update(0.0)
        
        game.teardown()
    }
    
    func testAvoidWallsGame() {
        let game = AvoidWallsGame()
        let scene = SKScene()
        
        game.start(in: scene)
        
        // Simulate avoiding walls
        for _ in 0..<10 {
            game.handleTouch(CGPoint(x: 200, y: 400))
        }
        
        game.update(0.0)
        
        game.teardown()
    }
    
    func testWhackMoleGame() {
        let game = WhackMoleGame()
        let scene = SKScene()
        
        game.start(in: scene)
        
        // Simulate whacking moles
        for _ in 0..<5 {
            game.handleTouch(CGPoint(x: 200, y: 300))
        }
        
        game.update(0.0)
        
        game.teardown()
    }
    
    func testMemoryPairGame() {
        let game = MemoryPairGame()
        let scene = SKScene()
        
        game.start(in: scene)
        
        // Simulate flipping tiles
        for _ in 0..<4 {
            game.handleTouch(CGPoint(x: 150, y: 250))
        }
        
        game.update(0.0)
        
        game.teardown()
    }
    
    func testSliderStopGame() {
        let game = SliderStopGame()
        let scene = SKScene()
        
        game.start(in: scene)
        
        // Simulate stopping slider
        game.handleTouch(CGPoint(x: 200, y: 400))
        
        game.update(0.0)
        
        game.teardown()
    }
    
    func testBubbleWrapGame() {
        let game = BubbleWrapGame()
        let scene = SKScene()
        
        game.start(in: scene)
        
        // Simulate popping bubbles
        for _ in 0..<15 {
            game.handleTouch(CGPoint(x: 100, y: 200))
        }
        
        game.update(0.0)
        
        game.teardown()
    }
    
    func testQuickTargetGame() {
        let game = QuickTargetGame()
        let scene = SKScene()
        
        game.start(in: scene)
        
        // Simulate hitting target
        game.handleTouch(CGPoint(x: 200, y: 250))
        
        game.update(0.0)
        
        game.teardown()
    }
    
    func testMicrogameFactory() {
        let microgame = MicrogameFactory.createRandomMicrogame()
        
        XCTAssertNotNil(microgame)
        
        // Test that microgame can be started
        let scene = SKScene()
        microgame.start(in: scene)
        
        // Test that microgame can handle touches
        microgame.handleTouch(CGPoint(x: 200, y: 300))
        
        // Test that microgame can be updated
        microgame.update(0.0)
        
        // Test that microgame can be torn down
        microgame.teardown()
    }
}