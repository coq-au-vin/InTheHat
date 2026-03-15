# PulseTimer — Setup Instructions

## 1. Create the Xcode Project

1. Xcode → New Project → iOS App
2. Product Name: `PulseTimer`, Bundle ID: `com.yourname.PulseTimer`, Interface: SwiftUI, Language: Swift
3. Save into the `ClaudeCode/` folder (so `PulseTimer.xcodeproj` sits next to this `PulseTimer/` folder)

## 2. Add Source Files

Drag all `.swift` files from this folder into the Xcode project navigator, preserving group structure:
- `PulseTimerApp.swift`, `ContentView.swift` → root group
- `Models/WorkoutConfiguration.swift`
- `Managers/AudioManager.swift`, `WorkoutManager.swift`, `NotificationManager.swift`
- `Views/SetupView.swift`, `Views/ActiveTimerView.swift`
- `Views/Components/CircularProgressView.swift`, `Views/Components/TimerDisplayView.swift`

Check **"Copy items if needed"** and add to the `PulseTimer` target.

## 3. Generate Audio Assets

```bash
# 1-second silent MP3
ffmpeg -f lavfi -i anullsrc=r=44100:cl=mono -t 1 silence.mp3

# beep.mp3 — provide any short beep sound (< 1s)
```

Drag both into Xcode → `Resources/` group, check "Copy items if needed".

## 4. Enable Background Audio Capability

Xcode → Target → Signing & Capabilities → `+ Capability` → **Background Modes** → check **Audio, AirPlay, and Picture in Picture**

This writes the `UIBackgroundModes` key to `Info.plist` automatically.

## 5. Add Notification Usage Description

In `Info.plist` add:
```
Key:   NSUserNotificationsUsageDescription
Value: PulseTimer sends interval alerts to your lock screen so you know when to switch exercises.
```

## 6. Build & Run

- **Simulator**: UI flow works; haptics and lock-screen audio require a physical device.
- **Physical iPhone**: Full background audio + notifications work after granting permission.
