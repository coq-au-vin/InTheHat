    ---                                                     
    # Nick's iOS App Style Guide                                               
                                         
    > Reference this file at the start of any new iOS/SwiftUI project.
    > Tell Claude: *"Use the style guide at ../STYLE_GUIDE.md"*

    ---

    ## 1. Colour Palette

    All colours live in a `Theme.swift` file using a `Color.theme.*` access
    pattern.
    The hex initialiser (`Color(hex:)`) must also be included.

    | Token | Hex | Name | Role |
    |---|---|---|---|
    | `Color.theme.background` | `#F9F7F2` | Coconut Milk | Main app background
     |
    | `Color.theme.surface` | `#F0EDE4` | Sand Dollar | Cards, grouped rows |
    | `Color.theme.work` | `#E69F9B` | Guava Pink | Warm accent / active state
    |
    | `Color.theme.rest` | `#A8D0BC` | Seafoam Sage | Success / positive state
    |
    | `Color.theme.warning` | `#F4D793` | Mango Pulp | Alerts / highlights |
    | `Color.theme.textPrimary` | `#4A3F35` | Roasted Coffee | Headings &
    labels |
    | `Color.theme.textSecondary` | `#8C8279` | Pebble Gray | Subtitles & stats
     |

    ### Per-App Primary Accent
    Every new app gets one additional `Color.theme.accent` (and
    `Color.theme.accentLight`
    for gradient ends). **Always ask the user which primary colour this app
    should use**
    before generating the Theme file. It must be visually distinct from Guava
    Pink.

    Example: InTheHat uses `#5B67E8` (Indigo Blue) / `#8B92F0` (Periwinkle).

    ---

    ## 2. Typography

    Three font helpers defined as `Font` extensions:

    ```swift
    // Large timer/countdown digits
    Font.dinTimer(size: CGFloat = 96)   // DINAlternate-Bold, monospacedDigit

    // Headings, buttons, body text
    Font.rounded(_ style: TextStyle = .body, weight: Weight = .semibold)
    Font.roundedSize(_ size: CGFloat, weight: Weight = .bold)

    // Technical stats, section labels, small captions
    Font.monoStats(_ style: TextStyle = .caption)   // SF Mono

    Usage conventions

    ┌────────────────────────┬───────────────────────────────────────────────┐
    │        Context         │                     Font                      │
    ├────────────────────────┼───────────────────────────────────────────────┤
    │ Screen title / hero    │ .roundedSize(30–34)                           │
    ├────────────────────────┼───────────────────────────────────────────────┤
    │ Card heading           │ .rounded(.headline) or .rounded(.body)        │
    ├────────────────────────┼───────────────────────────────────────────────┤
    │ Section label (ALL     │ .monoStats(.caption) + .tracking(1.4)         │
    │ CAPS)                  │                                               │
    ├────────────────────────┼───────────────────────────────────────────────┤
    │ Body / form rows       │ .rounded(.body, weight: .regular)             │
    ├────────────────────────┼───────────────────────────────────────────────┤
    │ Countdown / timer      │ .dinTimer(size: 72–96)                        │
    │ digit                  │                                               │
    ├────────────────────────┼───────────────────────────────────────────────┤
    │ Stats, player counts   │ .monoStats(.subheadline)                      │
    ├────────────────────────┼───────────────────────────────────────────────┤
    │ Phase badges (spaced   │ .rounded(.subheadline, weight: .bold) +       │
    │ caps)                  │ .tracking(3)                                  │
    └────────────────────────┴───────────────────────────────────────────────┘

    ---
    3. Component Patterns

    Primary Button

    PrimaryButton(title: "Label", enabled: Bool, action: { })
    - Background: LinearGradient([Color.theme.accent, Color.theme.accentLight])
    - Corner radius: 18, style: .continuous
    - Vertical padding: 17pt
    - Font: .rounded(.title3)
    - Text colour: .white (when using dark accent) or textPrimary (light
    accent)
    - Disabled state: Color.theme.surface background, textSecondary text

    Cards / Sections

    CardSection(title: "SECTION LABEL") { /* rows */ }
    - Background: Color.theme.surface
    - Corner radius: 16, style: .continuous
    - Section title: .monoStats(.caption), tracking 1.4, textSecondary
    - Row dividers: textPrimary.opacity(0.06)
    - Internal padding: 13pt vertical, 16pt horizontal

    Stepper Rows

    - Use StepperRow(label:, value:, range:, step:) — custom ±buttons, no
    system Stepper
    - Button size: 36×36pt, corner radius 10
    - Value width: 46pt, centred

    Phase Badge (Capsule)

    Text("LABEL")
        .font(.monoStats(.caption))
        .tracking(3)
        .padding(.horizontal, 16).padding(.vertical, 6)
        .background(.white.opacity(0.15))
        .clipShape(Capsule())

    ---
    4. App Background & Screen Layout

    - All screens: ZStack { Color.theme.background.ignoresSafeArea() }
    - Top content padding: 48–60pt
    - Horizontal section padding: 20pt
    - Scroll bottom padding: 40–48pt

    Active / Gameplay Screens

    For timer-driven or game-state screens, use a full-screen solid colour
    matching the
    current phase/team colour as the background (mirrors WorkoutTimer's active
    timer screen).
    White text and semi-transparent button overlays work on top.

    ---
    5. App Logo / Icon

    Shape

    Every app gets a custom SwiftUI Shape (not an emoji) as its logo.
    - Implement as a struct XxxShape: Shape { func path(in:) } using Path
    curves
    - Wrap in a XxxView(size: CGFloat, color: Color) that layers fill + stroke
    + details
    - Create an AppIconView using a dark indigo gradient background (#1E1B4B →
    #3730A3)
    with the logo rendered in white at ~72% of the icon width

    Icon background

    Always dark gradient + white logo for maximum contrast on both light and
    dark home screens.

    Asking the user

    ▎ Before generating the logo shape, ask: "What object or symbol should
    represent this app?
    ▎ And which primary accent colour should it use from the palette?"

    ---
    6. Animations

    ┌─────────────────────────┬─────────────────────────────────┬────────────┐
    │         Context         │            Duration             │   Curve    │
    ├─────────────────────────┼─────────────────────────────────┼────────────┤
    │ Phase / screen          │ 0.45s                           │ .easeInOut │
    │ background              │                                 │            │
    ├─────────────────────────┼─────────────────────────────────┼────────────┤
    │ Phase badge swap        │ 0.3s                            │ .easeInOut │
    ├─────────────────────────┼─────────────────────────────────┼────────────┤
    │ Name / content fade     │ 0.25s                           │ .easeInOut │
    ├─────────────────────────┼─────────────────────────────────┼────────────┤
    │ Progress ring           │ 1.0s                            │ .linear    │
    ├─────────────────────────┼─────────────────────────────────┼────────────┤
    │ Timer digit             │ .numericText() content          │ —          │
    │                         │ transition                      │            │
    ├─────────────────────────┼─────────────────────────────────┼────────────┤
    │ Spring bounces          │ 0.3s                            │ .spring    │
    └─────────────────────────┴─────────────────────────────────┴────────────┘

    ---
    7. Timer & Countdown Sounds + Haptics

    Source of truth: /Users/nick/Desktop/ClaudeCode/WorkoutTimer/

    Whenever a new app includes a countdown or round timer, copy the audio and
    haptic
    system directly from WorkoutTimer rather than building from scratch.

    What to reuse

    ┌───────────────────────────────┬────────────────────────────────────────┐
    │       File / component        │              What it does              │
    ├───────────────────────────────┼────────────────────────────────────────┤
    │ SoundManager.swift (or        │ Plays pip beeps for final countdown    │
    │ equivalent)                   │ seconds                                │
    ├───────────────────────────────┼────────────────────────────────────────┤
    │ HapticManager.swift (or       │ Triggers UIImpactFeedbackGenerator on  │
    │ equivalent)                   │ events                                 │
    ├───────────────────────────────┼────────────────────────────────────────┤
    │ Bundled .wav / .caf audio     │ The actual pip and completion chime    │
    │ assets                        │ sounds                                 │
    └───────────────────────────────┴────────────────────────────────────────┘

    Behaviour rules

    - Countdown pips: play a short beep for each of the last 3–5 seconds of a
    round
    - Round end / completion: play a distinct chime (different pitch/length
    from pips)
    - Correct answer: light haptic impact (.light or .medium)
    - Round start: medium haptic
    - Timer low (≤10s): timer digit turns a high-contrast warning colour (e.g.
    #FFECEC on coloured bg)

    Implementation checklist for new apps

    1. Copy SoundManager + audio asset files from WorkoutTimer
    2. Copy HapticManager (or inline UIImpactFeedbackGenerator calls)
    3. Hook pip sounds into the timer's per-second callback when timeRemaining
    <= 5
    4. Hook completion chime into the round-end function
    5. Ensure audio files are added to the Xcode target's Copy Bundle Resources
     build phase

    ---
    8. Persistence

    - Use UserDefaults with a versioned key (e.g. "AppName_GameState_v2") for
    all game state
    - Encode/decode via JSONEncoder / JSONDecoder with a Codable SavedState
    struct
    - Call saveState() at the end of every mutating function
    - On app launch (.onAppear of root view): call loadState() then
    resumeTimerIfNeeded()
    - Enums with associated values need manual Codable conformance (keyed
    container pattern)

    ---
    9. Architecture

    - One GameViewModel: ObservableObject owns all state
    - Inject at app root via .environmentObject(vm), consume with
    @EnvironmentObject
    - ContentView is a switch vm.phase { } router — no navigation stack needed
    for linear flows
    - Views are read-only w.r.t. state; all mutations go through named vm.xxx()
     functions

    ---

