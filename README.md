# Me Against Who? — Mini Mystery Duels

A family-friendly iOS game built with SwiftUI and SpriteKit, featuring quick microgames and mystery-solving gameplay.

## Features

- **Ultra-short rounds**: 60-120 seconds of gameplay
- **3 microgames per round**: Each lasting 3-5 seconds
- **Mystery solving**: Collect clues to guess your hidden opponent
- **6 unique opponents**: Each with distinct visual and audio clues
- **12 microgames**: Variety of one-thumb control games
- **Offline-first**: No internet connection required
- **Accessibility**: Color-blind safe, scalable touch targets
- **Family-friendly**: Suitable for kids and adults

## Gameplay

1. **Start a run**: Randomly select a hidden opponent
2. **Play 3 microgames**: Quick, engaging mini-games
3. **Collect clues**: After each microgame, receive a clue about your opponent
4. **Make your guess**: Choose from 6 opponent tiles
5. **Bonus round**: If correct, play a bonus mini-game for extra stars

## Opponents

- 🦊 **Fox** - Orange color, snare sound, paw sticker
- 👑 **King** - Gold color, fanfare sound, crown sticker  
- ⚡ **Thunder** - Yellow color, thunder sound, lightning sticker
- 🍃 **Leaf** - Green color, marimba sound, leaf sticker
- ⭐ **Star** - Purple color, sparkle sound, star sticker
- 🤖 **Robo** - Blue color, beep sound, gear sticker

## Microgames

1. **Pop Balloons** - Tap to pop balloons quickly
2. **Trace Line** - Follow a wavy path without leaving
3. **Balance Stack** - Stack blocks without toppling
4. **Tap on Beat** - Tap targets as they appear
5. **Catch Falling** - Catch falling items with a basket
6. **Avoid Walls** - Rise to avoid obstacles
7. **Whack Mole** - Tap moles as they appear
8. **Memory Pair** - Match tile pairs
9. **Slider Stop** - Stop moving slider in target zone
10. **Bubble Wrap** - Pop bubbles quickly
11. **Tilt Balance** - Keep ball in circle using device tilt
12. **Quick Target** - Find the odd-one-out shape

## Technical Requirements

- iOS 16.0+
- Swift 5.9+
- Xcode 15.0+
- Portrait orientation only

## Building and Running

1. Open `MeAgainstWho.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run (⌘+R)

## Project Structure

```
MeAgainstWho/
├── MeAgainstWhoApp.swift          # App entry point
├── ContentView.swift              # Main SwiftUI view
├── GameCoordinator.swift          # Game state management
├── Models/
│   ├── Opponent.swift            # Opponent data model
│   ├── Clue.swift                # Clue system
│   └── GameSettings.swift        # User settings
├── Services/
│   ├── ClueService.swift         # Clue generation
│   ├── AudioService.swift        # Sound effects
│   ├── Haptics.swift             # Haptic feedback
│   └── Persistence.swift         # Data storage
├── GameCenter/
│   └── GameCenterManager.swift   # Game Center integration
├── Scenes/
│   ├── MenuScene.swift           # Main menu
│   ├── MicrogameScene.swift      # Microgame container
│   ├── GuessScene.swift          # Opponent selection
│   ├── ResultScene.swift         # Win/lose screen
│   └── BonusScene.swift          # Bonus mini-game
├── UI/
│   ├── GuessCardView.swift       # Opponent selection cards
│   └── SettingsView.swift        # Settings screen
├── Microgames/
│   ├── Microgame.swift           # Microgame protocol
│   └── [12 microgame implementations]
└── Tests/
    ├── ClueServiceTests.swift    # Clue system tests
    └── MicrogameLogicTests.swift # Microgame tests
```

## Design Rationale

### Accessibility First
- **Color-blind safe**: Uses shapes and icons alongside colors
- **Large touch targets**: Minimum 44pt touch areas
- **Reduced motion**: Respects system accessibility settings
- **VoiceOver support**: Proper labels for screen readers

### Family-Friendly Design
- **No reading required**: Visual and audio cues only
- **Forgiving gameplay**: Generous success thresholds
- **Positive feedback**: Encouraging sounds and haptics
- **Quick sessions**: Perfect for short attention spans

### Technical Architecture
- **SwiftUI + SpriteKit**: Modern iOS development
- **Offline-first**: No network dependencies
- **Modular design**: Easy to add new microgames
- **Test coverage**: Unit tests for core logic
- **Performance optimized**: 60fps gameplay

## Game Center Integration

Optional Game Center features (gracefully degrades if unavailable):
- **Achievements**: First Win, 10 Streak, Perfect Round
- **Leaderboard**: Daily Streak tracking
- **Safe stubs**: Compiles even without Game Center

## Localization

Currently supports English with icon-based UI. Easy to extend with:
- `Localizable.strings` for text content
- Icon-based design reduces translation needs
- VoiceOver labels for accessibility

## Performance Notes

- **60fps target**: Optimized for smooth gameplay
- **Memory efficient**: Proper cleanup of game objects
- **Battery friendly**: Minimal background processing
- **Quick loading**: Instant app startup

## Future Enhancements

- Additional microgames
- More opponent types
- Daily challenges
- Multiplayer modes
- Custom themes
- Advanced analytics

## License

This project is for educational and demonstration purposes.