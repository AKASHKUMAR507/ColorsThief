---
name: Paperland Wander
colors:
  surface: '#fbf9f8'
  surface-dim: '#dbdad9'
  surface-bright: '#fbf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3f3'
  surface-container: '#efeded'
  surface-container-high: '#eae8e7'
  surface-container-highest: '#e4e2e2'
  on-surface: '#1b1c1c'
  on-surface-variant: '#4d4634'
  inverse-surface: '#303030'
  inverse-on-surface: '#f2f0f0'
  outline: '#7f7661'
  outline-variant: '#d1c5ad'
  surface-tint: '#745c00'
  primary: '#745c00'
  on-primary: '#ffffff'
  primary-container: '#ffd23f'
  on-primary-container: '#725a00'
  inverse-primary: '#edc22e'
  secondary: '#00658b'
  on-secondary: '#ffffff'
  secondary-container: '#6dcbff'
  on-secondary-container: '#005575'
  tertiary: '#a7392a'
  on-tertiary: '#ffffff'
  tertiary-container: '#ffcbc2'
  on-tertiary-container: '#a53829'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffe089'
  primary-fixed-dim: '#edc22e'
  on-primary-fixed: '#241a00'
  on-primary-fixed-variant: '#574500'
  secondary-fixed: '#c5e7ff'
  secondary-fixed-dim: '#7ed0ff'
  on-secondary-fixed: '#001e2d'
  on-secondary-fixed-variant: '#004c6a'
  tertiary-fixed: '#ffdad4'
  tertiary-fixed-dim: '#ffb4a8'
  on-tertiary-fixed: '#410100'
  on-tertiary-fixed-variant: '#862116'
  background: '#fbf9f8'
  on-background: '#1b1c1c'
  surface-variant: '#e4e2e2'
typography:
  headline-xl:
    fontFamily: Quicksand
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
  headline-xl-mobile:
    fontFamily: Quicksand
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg:
    fontFamily: Quicksand
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
  headline-lg-mobile:
    fontFamily: Quicksand
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
  headline-md:
    fontFamily: Quicksand
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-sm:
    fontFamily: Quicksand
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  body-lg:
    fontFamily: Nunito Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-md:
    fontFamily: Nunito Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  label-lg:
    fontFamily: Quicksand
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 22px
  label-md:
    fontFamily: Quicksand
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 18px
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1.5rem
  gutter-mobile: 1rem
  margin: 2.5rem
  margin-mobile: 1.25rem
  space-xs: 0.5rem
  space-sm: 0.75rem
  space-md: 1.25rem
  space-lg: 2rem
  space-xl: 3rem
---

## Brand & Style

This design system establishes an interactive picture-book atmosphere tailored for toddlers and early learners (ages 2–6). The aesthetic marries tactile, storybook illustration with modern minimalist play patterns. By casting the world in muted charcoal and warm stone-gray inks over an organic parchment background, the interface emphasizes dramatic color restoration as the primary emotional reward.

The emotional core is curiosity, gentle discovery, and agency. The visual language blends:
- **Storybook Tactility:** Organic, paper-textured tones that feel like an uncolored printed coloring book waiting to spring to life.
- **Toy-Like Physicality:** Oversized, bulbous, physical interactive elements that look plump, pressable, and inviting to small, developing motor skills.
- **Zero-Text Minimalism:** Strict non-verbal cues. All actions, feedback, and progression pathways rely entirely on visual choreography, scale contrast, clear iconography, and bouncy physics rather than written words.

## Colors

The palette establishes an immediate narrative tension between an uncolored world and the joyful return of pure chromatic vitality:

- **Canvas & Substrates:**
  - Base Ground: `#F5F0E8` (warm, natural linen parchment).
  - Surface Paper Raised: `#FAF7F2` (soft off-white cutouts for cards and elevated panels).
- **The Stolen Grayscale Landscape:**
  - Ink Deep: `#2D2D2D` (linework, primary silhouettes, and focal characters).
  - Charcoal Mid: `#5A5A5A` (secondary scenery, passive background layers).
  - Shadow Mist: `#8C8C8C` (distant foliage, atmospheric contours).
  - Washed Ash: `#D8D4CD` (muted ground fills and inactive interactive states).
- **Restored Chromatic Accents:**
  - **Sunflower Glow (Primary - `#FFD23F`):** Represents joy, magic, and direct interaction. Used for the primary tap targets, restored sunbeam tokens, and active progress cues.
  - **Breeze Blue (Secondary - `#54B5E8`):** Restored water, skies, and secondary interactive points.
  - **Wild Coral (Tertiary - `#FF7A66`):** Fruit, flowers, critical feedback flashes, and celebratory bursts.

Non-interactive canvas areas must stay restrained within the parchment and grayscale ranges. Chromatic colors should feel earned, beaming out through localized splashes and animated fill reveals.

## Typography

Text is strictly prohibited in the core child-facing game viewport; typographic tokens exist solely for numerical score counts, pictorial glyph containers, developer/parental gates, and high-level section transitions. 

All glyphs must exhibit pronounced rounded terminals and soft anatomical geometry. Quicksand provides an approachable, bubbly structure for numeric counts and parental headings. Nunito Sans serves secondary supportive contexts (e.g., settings dialogs, parental verification locks) while maintaining an open, comforting cadence.

## Layout & Spacing

Toddler ergonomics require wide hit areas, uncluttered spatial fields, and defensive perimeter buffers to prevent accidental bezel activation:

- **Hit Targets:** Interactive nodes must observe a strict minimum footprint of 64×64px (ideally 80×80px on tablets), spaced at least `space-md` apart to prevent mis-taps.
- **Screen Bounds:** Margins form an inviolable perimeter safety zone of `margin` on tablets and `margin-mobile` on handheld devices, keeping game triggers clear of physical hardware grips.
- **Layout Model:** A dynamic contextual stage layout. The central interactive playboard occupies a fluid canvas flanked by pinned, floating tool pods in the top-right and bottom-center quadrants.
- **Multi-Device Adaptability:** On larger viewports (tablets, touch monitors), layouts expand laterally into a wide storybook landscape orientation; mobile viewports collapse non-essential secondary counters into simplified corner badges.

## Elevation & Depth

Visual hierarchy uses physical paper layering and soft ambient light:

- **Cutout Paper Relief:** Background terrain elements sit flush against the `#F5F0E8` baseline. Active play areas, dialog plates, and containers use `#FAF7F2` elevated by 2px downward translation and a feathered contact shadow: `box-shadow: 0 4px 12px rgba(45, 45, 45, 0.06)`.
- **Tactile Squishy Buttons:** Interactive items mimic stamped wooden or plush rubber tokens. They have a pronounced warm ambient drop shadow: `box-shadow: 0 8px 24px rgba(255, 210, 63, 0.35), 0 4px 8px rgba(45, 45, 45, 0.08)`.
- **Depression State:** On press, actionable elements scale to 92%, translating 4px downward along the Y-axis while their shadow contracts to `0 2px 4px rgba(45, 45, 45, 0.12)`, delivering an immediate visual snap.
- **No Harsh Lines:** Never apply pure black or hard razor-thin stroke dividers. Outlines, where necessary, are soft 3px or 4px strokes using `#D8D4CD` or `#2D2D2D` with rounded caps.

## Shapes

The interface embraces a strictly soft geometric profile with zero sharp corners across all components:

- **Tokens & Nodes:** Primary interactive elements are continuous spheres or squircular discs (`border-radius: 9999px`).
- **Containers & Panels:** Substrate frames and story containers employ pillow curves (`border-radius: 2rem` to `3rem`).
- **Visual Edges:** Internal illustrations, frames, and icon strokes must use rounded caps (`stroke-linecap: round`) and rounded joins (`stroke-linejoin: round`) to reinforce an environment safe for young eyes and fingers.

## Components

### Action Bubbles (Primary Buttons)
- Circular buttons (80×80px minimum) colored in vibrant Sunflower Glow (`#FFD23F`) with 4px inner highlights.
- Visual icon centered within the circle (e.g., paintbrush, play arrow, rewind swirl) drawn in `#2D2D2D` with heavy 4px strokes and rounded joins.
- Pressing triggers an immediate bouncy squish animation (`scale(0.92)`).

### World Portals (Level Selection Cards)
- Large rounded rectangles (`rounded-xl`, 3rem corner radius) constructed with a `#FAF7F2` backing and a 4px `#D8D4CD` border.
- Inactive/unvisited levels appear purely in linework and grayscale `#8C8C8C`.
- Completed levels burst with full-bleed color illustrations, an active Sunflower Yellow seal, and an ambient warm halo.

### Color Splat Chips & Filters
- Asymmetrical pill-shaped blobs used to swap active restoration pigments.
- Inactive state: Translucent gray pill (`#D8D4CD`) with a 32px monochromatic icon.
- Active selected state: Inflates by 15% with the selected pigment (`#54B5E8` or `#FF7A66`), projecting a soft color-matched glow.

### Non-Verbal Toggles & Sliders
- Extra-wide track (48px height) in `#D8D4CD` with pill-shaped rounded ends.
- Thumb is an oversized 64px physical sphere in `#FAF7F2` carrying an illustrative icon (e.g., musical note with a strikethrough vs. dancing note for audio settings).
- Bounces with spring physics into place on release.

### Parental Gate Modal
- Fullscreen soft overlay (`#F5F0E8` at 90% opacity with background blur).
- Contained central parchment slate with rounded corners (`rounded-xl`).
- Visual sequence puzzle (e.g., "Tap three red apples") to block accidental child exit while preserving the text-free paradigm for the toddler.