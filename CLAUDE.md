# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an iOS anxiety/stress relief app called "Nuvin" built with SwiftUI. The app focuses on providing immediate relief tools for anxiety and panic attacks through breathing exercises, grounding techniques, and other evidence-based methods.

## Development Commands

### Building
```bash
# Build the project
xcodebuild -project anxietyapp.xcodeproj -scheme anxietyapp -destination 'platform=iOS Simulator,name=iPhone 15' build

# Build and run in simulator
open anxietyapp.xcodeproj
# Then use Xcode's Play button or Cmd+R
```

### Testing
```bash
# Run unit tests
xcodebuild -project anxietyapp.xcodeproj -scheme anxietyapp -destination 'platform=iOS Simulator,name=iPhone 15' test

# Or use Xcode: Product → Test (Cmd+U)
```

### Code Quality
```bash
# Swift code formatting (if SwiftFormat is installed)
swiftformat .

# Swift linting (if SwiftLint is installed)
swiftlint
```

## Architecture & Code Structure

### MVVM Pattern
The app follows MVVM (Model-View-ViewModel) architecture as outlined in the PRD:
- **Models**: Data structures (User, Subscription, mood logs)
- **Views**: SwiftUI views for UI screens
- **ViewModels**: Business logic connecting Models and Views

### Planned File Structure
```
anxietyapp/
├── Models/           # Data models
├── Views/            # SwiftUI views
│   ├── OnboardingView.swift
│   ├── DashboardView.swift
│   ├── SOSFlowView.swift
│   └── ...
├── ViewModels/       # Business logic
├── Services/         # API and data services
├── Utilities/        # Helper functions and extensions
└── Resources/        # Assets, colors, constants
```

### Key Features to Implement
- **SOS Flow**: Primary crisis intervention feature with <2 minute relief goal
- **Breathing Exercises**: Box breathing (4-4-4-4), guided visual/audio cues
- **Grounding Techniques**: 5-4-3-2-1 sensory method
- **Physical Reset**: Shake, muscle tension/release, posture reset
- **Mood Tracking**: Daily check-ins with emoji-based interface

## Design Guidelines

### UI/UX Principles
- **Minimalist Design**: Lots of white space, clean interfaces
- **Crisis-First**: SOS button always prominent and accessible in ≤2 taps
- **Color Scheme**:
  - Primary: White background
  - Accent: Soft violet for calm/trust
  - Secondary: Light blue
  - Emergency: Soft pastel red (SOS button only)
- **Typography**: Inter font family (Medium for titles, Regular for body, Bold for CTAs)
- **8px Grid System**: All spacing/padding in multiples of 8px

### Performance Requirements
- App launch: <2 seconds
- SOS flow: Must work offline
- Animations: 60fps for breathing/visual exercises

## Key Technical Considerations

### Offline-First Approach
- Core SOS functionality must work without internet
- Local data storage for journaling and mood tracking
- Queue sync operations for when connectivity returns

### Privacy & Security
- No mandatory account creation for MVP
- Local data storage first (encrypted when possible)
- Journaling data stored locally and optionally deleted after use

### Monetization
- Premium-only subscription model (no free tier)
- StoreKit integration required
- RevenueCat or Superwall for subscription management

## Important Files & Documentation

- `prd.md`: Complete product requirements document with detailed feature specifications
- `uxuiguidelines.md`: UI/UX design best practices and guidelines
- `anxietyappApp.swift`: Main app entry point
- `ContentView.swift`: Current main view (placeholder - needs full implementation)

## Development Notes

- Target iOS 16+ (iPhone 12 and above)
- SwiftUI + UIKit hybrid approach allowed
- Use SF Symbols for consistent iconography
- Haptic feedback important for accessibility and user experience
- GDPR compliance required for data handling