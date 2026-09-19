---
name: Color Thief Joyful Play
colors:
  surface: '#fcf8ff'
  surface-dim: '#dad7f3'
  surface-bright: '#fcf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f2ff'
  surface-container: '#efecff'
  surface-container-high: '#e8e5ff'
  surface-container-highest: '#e2e0fc'
  on-surface: '#1a1a2e'
  on-surface-variant: '#594139'
  inverse-surface: '#2f2e43'
  inverse-on-surface: '#f2efff'
  outline: '#8d7168'
  outline-variant: '#e1bfb5'
  surface-tint: '#ab3500'
  primary: '#ab3500'
  on-primary: '#ffffff'
  primary-container: '#ff6b35'
  on-primary-container: '#5f1900'
  inverse-primary: '#ffb59d'
  secondary: '#745c00'
  on-secondary: '#ffffff'
  secondary-container: '#fcd03d'
  on-secondary-container: '#705900'
  tertiary: '#006689'
  on-tertiary: '#ffffff'
  tertiary-container: '#1da5da'
  on-tertiary-container: '#00364b'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdbd0'
  primary-fixed-dim: '#ffb59d'
  on-primary-fixed: '#390c00'
  on-primary-fixed-variant: '#832600'
  secondary-fixed: '#ffe089'
  secondary-fixed-dim: '#edc22e'
  on-secondary-fixed: '#241a00'
  on-secondary-fixed-variant: '#574500'
  tertiary-fixed: '#c3e8ff'
  tertiary-fixed-dim: '#79d1ff'
  on-tertiary-fixed: '#001e2c'
  on-tertiary-fixed-variant: '#004c68'
  background: '#fcf8ff'
  on-background: '#1a1a2e'
  surface-variant: '#e2e0fc'
typography:
  headline-xl:
    fontFamily: Comfortaa
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-xl-mobile:
    fontFamily: Comfortaa
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Comfortaa
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Comfortaa
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: Comfortaa
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  body-lg:
    fontFamily: Nunito Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  body-md:
    fontFamily: Nunito Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
  body-sm:
    fontFamily: Nunito Sans
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 22px
  label-lg:
    fontFamily: Comfortaa
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 24px
  label-md:
    fontFamily: Comfortaa
    fontSize: 16px
    fontWeight: '700'
    lineHeight: 20px
  label-sm:
    fontFamily: Comfortaa
    fontSize: 13px
    fontWeight: '700'
    lineHeight: 16px
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1.5rem
  margin: 2rem
  space-xs: 0.5rem
  space-sm: 0.75rem
  space-md: 1.25rem
  space-lg: 2rem
  space-xl: 3rem
---

## Brand & Style

The design system embodies the playful, tactile magic of an interactive Saturday morning cartoon and richly illustrated picture books. Geared toward toddlers aged 2–6 and their caregivers, the aesthetic avoids sterile minimalism and cold digital flat design in favor of squishy, bouncy, and hyper-tactile physical metaphors. 

Every interaction sparks delight, wonder, and emotional warmth. Shapes feel pillowy and plump, edges are generously radiused, and feedback is immediate, vibrant, and physical. Chunky buttons feature 3D bottom lips that physically depress on touch, mimicking real-world toy buttons that small hands love to smash. 

The design prioritizes ultra-large touch targets (minimum 64×64pt, ideally 72–88pt) to accommodate developing motor coordination. Visual storytelling replaces dense instructional text, allowing pre-readers to explore autonomously without frustration.

## Colors

The palette is rooted in an ultra-warm cream canvas (`#FFF9F0`), replacing stark digital white with the comforting texture of milk paper and children's storybooks. Foreground elements use an energetic, candy-shop color suite designed to spark immediate focus:

- **Primary (Zesty Coral / Fox Orange):** `#FF6B35` — Used for main interactive buttons, active stages, and energetic call-to-actions.
- **Secondary (Sunshine Yellow):** `#FFD23F` — Used for rewards, stars, collectible tokens, and celebratory highlights.
- **Tertiary (Sky Blue):** `#54C8FF` — Used for auxiliary navigation, speech bubbles, and cooling balance.
- **Accent Grass Green:** `#4CD964` — Used for success states, confirmations, and natural world elements.
- **Accent Hot Pink:** `#FF4081` — Used for bonus items, celebratory effects, and high-energy accents.
- **Accent Mint:** `#00E5CC` — Used for secondary tools, water/magic effects, and playful contrast.
- **Deep Navy (Text & Outlines):** `#1A1A2E` — Replaces harsh pure black `#000000` with an animated, storybook ink tone for all borders, shadows, and readable copy.

Ensure color pairings preserve strong accessibility: buttons paired with Deep Navy borders create immediate visual boundaries even for children with emerging vision contrast sensitivity.

## Typography

Typography balances rounded, bouncy display charisma with effortless legibility. 

- **Display & Headlines (Comfortaa):** Comfortaa provides the bulbous, friendly geometry of classic children’s animation. All headings use bold weights (`700`), imparting a soft, stamp-like feel to chapter names, score celebrations, and modal dialogs.
- **Body & Parental Guidance (Nunito Sans):** Nunito Sans brings ultra-legible rounded terminals for adult-facing copy (parental gates, settings, audio toggles) and instructional labels.

Typography sizing must remain generously scaled across both iPhone and iPad viewports. Text is rarely set below `15px` to ensure effortless reading across handheld distance and high-movement gameplay.

## Layout & Spacing

Toddler apps demand an open, uncluttered layout architecture that accounts for erratic multi-finger taps and accidental thumb rests near screen edges.

- **Safe Zones & Margins:** Edge margins are generous (`2rem` / 32px), creating a wide defensive buffer from iOS home indicators and bezel edges.
- **Rhythm & Padding:** Component spacing relies on wide gutters to prevent toddler "fat-finger" mis-taps. A minimum clearance of `16px` (`1rem`) exists between any two interactive items.
- **Form Factor Adaptability:**
  - **Phone (Landscape/Portrait):** Single-tier floating HUD anchored to screen corners with a minimum touch area of 64×64pt.
  - **Tablet (iPad):** Expanded landscape canvas featuring two-column storybook spreads with content clustered within comfortable two-handed thumb arcs.

## Elevation & Depth

Visual hierarchy uses **tactile cartoon skeuomorphism** rather than ethereal drop shadows or frosted glass. The depth model mirrors wooden and plastic chunky toys:

- **Tactile Toy Push-Buttons:** Primary surfaces feature a solid 4px to 6px bottom border lip in a darkened shade of the base color or Deep Navy (`#1A1A2E`), alongside a crisp 3px stroke outline. When pressed, the element translates down on the Y-axis by 4px and the bottom edge collapses, providing unmistakable mechanical feedback.
- **Layered Stickers & Badges:** Overlays, cards, and modal dialogs feature a solid white (`#FFFFFF`) inner border (3px) enclosed by a strong Deep Navy outline (`#1A1A2E`), replicating thick die-cut vinyl stickers.
- **Ambient Shadow Drops:** Floating floating HUD elements utilize an offset solid shadow (`0px 6px 0px rgba(26, 26, 46, 0.2)`) instead of blurred shadows, maintaining crisp illustrative fidelity.

## Shapes

Shapes are universally bulbous, organic, and ultra-puffy. Sharp angles do not exist in this design language. 

- **Level 3 (Pill-shaped):** All interaction points—buttons, badge labels, slider tracks, and status tags—use continuous pill capsules or full circular boundaries.
- **Card & Dialog Radii:** Containers and modal sheets adopt hyper-generous corners (`2rem` / 32px to `3rem` / 48px), creating friendly, pebble-like surfaces that feel soft to the touch.
- **Decorative Blob Shapes:** Background vignettes and character speech bubbles utilize asymmetrical rounded organic blobs that mimic claymation and squishy play dough.

## Components

### Buttons
- **Chunky Game Action (Primary):** Pill-shaped, Coral (`#FF6B35`) background with a 3px solid Navy (`#1A1A2E`) border and a 6px darker coral (`#D44A18`) bottom extrusion. Text is white or Navy with heavy weight. On touch-down: transforms `translateY(4px)` with bottom extrusion reduced to 2px. Minimum height 64pt.
- **Icon Button (Circular HUD):** Circular 68×68pt disks in Sunshine Yellow (`#FFD23F`) or Sky Blue (`#54C8FF`) with high-contrast glyphs (Home, Audio, Replay, Color Bucket). Retains the 4px bottom extrusion shadow.

### Cards & Story Plates
- Mounted on pure white (`#FFFFFF`) or cream (`#FFF9F0`) surfaces, framed by a 4px Deep Navy stroke.
- Header bands are shaped like arched ribbons or pill stickers protruding over the top edge.

### Chips & Filter Bubbles
- Pill-shaped selector capsules featuring vibrant fill colors when active (Hot Pink, Mint, Sky Blue). Inactive states use Cream with a dashed Navy outline.

### Progress & Level Bars
- Capsule tracks filled with deep cream (`#EFE4D2`) inset shadow.
- Progress fills are glossy, segmented jelly capsules (Mint `#00E5CC` or Sunshine Yellow `#FFD23F`) with an animated shine stripe.

### Parental Gate Modal
- Restricted settings and external links are housed behind a child-proof gate. Uses clear adult typography (Nunito Sans) on a calming Sky Blue card, requiring a 3-second hold or written equation ("Hold for 3 seconds" or "Tap three orange apples").

### Checkboxes & Toggles
- Resemble chunky plastic rocker switches and bulbous round stamps. Active state displays an animated green star or smiling sticker checkmark.