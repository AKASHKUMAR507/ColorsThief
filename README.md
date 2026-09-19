# Color Thief

Native iOS toddler game (Swift + SpriteKit, SwiftUI for parent-facing screens). Grey world → tap → colour.
Spec: https://claude.ai/artifact/TsyEaiUKyP1VgapHSEv4E1 · Design references: `Design/`

## Run
Open `Color Thief.xcodeproj`, scheme **Color Thief** (shared; it attaches `Products.storekit` so the
Full Game purchase works in the simulator via Xcode ▸ Run). Minimum iOS 16.

## Flow
Splash (2.5 s) → Home → Level Select → Game (colouring-book "friend") → Level Complete → next level.
For Parents / 🔒 → Parent Gate → Settings → Parent Zone (purchase, restore, privacy policy).
Levels 1–3 free; finishing level 3 (or tapping a premium card) shows the paywall.

## Before App Store submission
- **App Store Connect:** create non-consumable `com.akash.colorthief.fullgame` ("Full Game", $1.99 tier).
- **Privacy policy:** live at https://akashkumar507.github.io/ColorsThief/privacy.html (source `docs/privacy.html`, GitHub Pages). Same text is shown in-app via `PrivacyPolicyView`. Fill in the name/email placeholders in both.
- **Audio:** `Color Thief/Audio/*` are synthesised placeholders; drop in licensed files with the same names
  (`tap.caf`, `fanfare.m4a`, `music_loop.caf`).
- **Art:** friends (`Nodes/Art/FriendArt.swift`) and landscapes (`Nodes/Art/LandscapeArt.swift`) are vector
  placeholders; the app icon / launch logo were generated from the same mascot.
- Kids category metadata, age band 2–6, no third-party analytics/ads (none are included).
