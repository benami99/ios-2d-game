# MyFirstGame — file flow (current)

## Project layout

Swift sources are grouped under **`App/`** (shell) and **`Game/`** (one folder per entity). Asset catalogs stay next to them.

```
MyFirstGame/
  App/
    ContentView.swift
    GameHUDView.swift
    MyFirstGameApp.swift
    PongGameBridge.swift
  Game/
    Flow/PongFlowState.swift
    Ball/PongBall.swift
    Court/PongCourtElements.swift
    Court/PongGoalZones.swift
    GameMode/PongGameMode.swift
    Paddle/PongPaddle.swift
    Physics/PhysicsCategory.swift
    Playfield/Playfield.swift
    Rules/PongRules.swift
    Rules/PongMatchPhase.swift
    Rules/PongSide.swift
    Scene/PongScene.swift
  Assets.xcassets/
```

Two views: **runtime** (what runs when the app launches) and **code dependencies** (which Swift files reference which).

## 1. Runtime: from `@main` to the scene

```mermaid
flowchart LR
    subgraph swiftui["SwiftUI — App/"]
        A["MyFirstGameApp.swift<br/>@main → WindowGroup"]
        B["ContentView.swift<br/>@State PongScene"]
        C["SpriteView"]
    end

    subgraph spritekit["SpriteKit — Game/Scene/"]
        D["SKView"]
        E["PongScene.swift<br/>SKScene"]
    end

    A --> B
    B --> C
    C --> D
    D --> E
```

**Sequence (conceptual):**

1. **`App/MyFirstGameApp.swift`** — Process entry (`@main`); builds the app’s scene and opens a window whose root is `ContentView`.
2. **`App/ContentView.swift`** — Creates **one** `PongScene` (stored in `@State`) and passes it to `SpriteView`.
3. **`SpriteView`** — Hosts an **`SKView`** and presents `PongScene`.
4. **`Game/Scene/PongScene.swift`** — `didMove(to:)` runs: configures the scene, physics world, adds court nodes, lays out paddles, touches, AI, scoring.

---

## 2. Dependencies: which files talk to which

`Playfield`, `PhysicsCategory`, `PongCourtElements`, `PongGoalZones`, `PongPaddle`, `PongBall`, and `PongGameMode` are not in the launch chain themselves; **`PongScene`** pulls them in when building and running the game.

```mermaid
flowchart TB
    subgraph app_layer["App shell"]
        App["App/MyFirstGameApp.swift"]
        CV["App/ContentView.swift"]
    end

    subgraph game_scene["Game Scene"]
        PS["Game/Scene/PongScene.swift"]
    end

    subgraph data["Layout & rules"]
        PF["Game/Playfield/Playfield.swift"]
        PP["Game/Paddle/PongPaddle.swift"]
        PB["Game/Ball/PongBall.swift"]
        GM["Game/GameMode/PongGameMode.swift"]
    end

    subgraph court["Court construction"]
        PCE["Game/Court/PongCourtElements.swift"]
        PGZ["Game/Court/PongGoalZones.swift"]
        Phy["Game/Physics/PhysicsCategory.swift"]
    end

    App --> CV
    CV --> PS
    PS --> PF
    PS --> PP
    PS --> PB
    PS --> GM
    PS --> PCE
    PS --> PGZ
    PCE --> PF
    PCE --> Phy
    PGZ --> PF
    PGZ --> Phy
```

| File | Role in this diagram |
|------|----------------------|
| `App/MyFirstGameApp.swift` | Entry → `WindowGroup` → `ContentView` |
| `App/ContentView.swift` | Owns `PongScene` instance → `SpriteView` |
| `Game/Scene/PongScene.swift` | Scene lifecycle, physics, HUD, AI, touch routing |
| `Game/Playfield/Playfield.swift` | Logical size and inner/outer Y bounds (no SpriteKit) |
| `Game/Paddle/PongPaddle.swift` | Paddle size, margin, sprite + physics |
| `Game/Ball/PongBall.swift` | Ball geometry + physics |
| `Game/Court/PongCourtElements.swift` | Walls + center line |
| `Game/Court/PongGoalZones.swift` | Goal sensors |
| `Game/Physics/PhysicsCategory.swift` | Physics category bitmasks |
| `Game/GameMode/PongGameMode.swift` | One player vs two players |

---

## 3. Preview path

Xcode **previews** skip `@main` and instantiate `ContentView()` directly; from there the flow is the same: `ContentView` → `SpriteView` → `PongScene`.
