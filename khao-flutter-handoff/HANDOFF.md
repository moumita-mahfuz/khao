# KHAO website — Design A ("Street Fire") → Flutter handoff

One-page responsive website for **KHAO**, a snack & adda spot in Mohammadpur, Dhaka.
Tagline: **যত খাবে তত চাবে**. Copy is Bangla-first with English accents.

Build target: **Flutter Web** (one codebase, responsive). Same widgets should also run on Android/iOS.

## What's in this folder

| Path | What it is |
|---|---|
| `reference/desktop.png` | Full desktop page at 1440px (source of truth for layout) |
| `reference/mobile-1.png`, `mobile-2.png` | Mobile page at 390px (rendered @2x, so 780px wide). Split in two at the dark→cream checker strip |
| `reference/source/*.dc.html` | Original HTML/CSS design source. **Use it for exact sizes, colors, radii, copy and animation timings.** Ignore the template syntax (`{{ }}`, `<sc-for>`, `<sc-if>`) — that's the design tool's runtime |
| `data/menu.json` | All menu items, prices, tiers, spice levels, contact placeholders. Drive the UI from this, don't hard-code |
| `assets/images/` | Food + shop photos (brand logo already cropped out) |
| `assets/logo/` | `logo-on-dark.png` (cream ink, transparent), `logo-on-light.png` (black ink, transparent), `logo-badge-yellow.jpg` |
| `assets/video/hero.mp4` + `hero-poster.jpg` | 18s 1280×720 loop for the hero, no audio |

Screenshots show the *end state* of animations; motion is described below.

## Design tokens

```dart
// Colors (from the KHAO brand palette)
khaoYellow   = Color(0xFFFFC107);
khaoOrange   = Color(0xFFFF6A00);
khaoRed      = Color(0xFFE63900);
khaoBlack    = Color(0xFF111111);
khaoCream    = Color(0xFFFFF6E6);
richBrown    = Color(0xFF4A2C15);   // signature carousel bg, secondary text on cream
darkRed      = Color(0xFFB32D00);   // small red text on cream (contrast-safe)
surfaceDark  = Color(0xFF1C1C1C);
lineDark     = Color(0xFF262626);   // dividers on black
dashedBeige  = Color(0xFFC9B48F);   // menu table row dividers
rowHover     = Color(0xFFFFE9B0);
```

Fonts (use the `google_fonts` package):

| Role | Font | Notes |
|---|---|---|
| Bangla display / headings / prices | **Anek Bangla** 600–800 | all big Bangla headlines, prices |
| English labels / kickers / ticker | **Bebas Neue** | **Latin only**: it has no Bangla glyphs, so never use it on Bangla text |
| Handwritten accent lines | **Galada** | e.g. "ছোট পিস থেকে বড় আড্ডা", footer line |
| Body | **Hind Siliguri** 400–600 | paragraphs, descriptions |

Prices use Bangla digits (`৳১১০`). Write a small `toBanglaDigits(int)` helper and keep raw ints in data.

Radii: buttons are pills (999). Cards 24–36. Menu table 28. Thumbnails are circles.

## Breakpoint

- **≥ 860px**: desktop layout (content max-width 1440, side padding 56)
- **< 860px**: mobile layout (side padding 16). See the mobile screenshots. Mobile is **not** just a squeeze of desktop:
  - Nav links are replaced by a hamburger that opens a cream dropdown panel.
  - The menu table becomes stacked cards.
  - The day timeline turns vertical.

## Page sections (top → bottom)

### 1. Hero (video)
- Full-bleed `video_player`: muted, looping, autoplay, `BoxFit.cover`. Poster image shows until it's ready. Note that web autoplay needs `setVolume(0)` *before* `play()`.
- Height: 900 desktop, 760 mobile.
- Dark gradient scrim over the video: top 0.7 → 0.1 at 35% → 0.35 at 60% → 0.95 at bottom (black).
- **Top bar** (overlaid, transparent):
  - `logo-on-dark.png` (64h desktop / 48h mobile).
  - Nav links স্পেশাল · মেনু · দুপুর/বিকেল · খুঁজে নাও (desktop only). These scroll to their sections.
  - Yellow pill **ORDER NOW** button.
  - Mobile adds the hamburger.
- **Bottom-left content**:
  - Outlined pill "NOW OPEN · MOHAMMADPUR, DHAKA" with a flame icon.
  - H1 two lines **যত খাবে / তত চাবে** (second line yellow). Anek Bangla 800, ~156px desktop, 66px mobile.
  - Paragraph.
  - Two buttons: orange filled **মেনু দেখো** and cream outlined **কোথায় আছি?** (stacked full-width on mobile).
- **Bottom-right (desktop only)**: 190px badge.
  - Ring of text "GOOD FOOD · BETTER MOOD ·" rotating, 18s per turn.
  - Yellow inner circle with a red flame that flickers (scale/rotate pulse, 1.6s).
- Scroll cue (mouse outline + bouncing dot) at bottom center.

### 2. Ticker strip
- Yellow band rotated −1.5°, overlapping the hero bottom slightly.
- Bebas Neue 44px items separated by a red ✺. Infinite marquee, 30s per loop.

### 3. Signature Bites carousel (bg `richBrown`)
- Kicker "SIGNATURE BITES".
- Heading **একটু আলাদা। / ঝালে-মজায় ভরা।** in yellow.
- Small yellow checker motif next to an intro paragraph.
- **Carousel**: items in `carouselOrder`, start index 1.
  - Desktop shows 5 cards (active ±2). Mobile shows 3 (active ±1, the side ones peek from the edges).
  - Side cards: cream, ~230px wide. The circular photo overlaps the card top (negative margin).
  - Far cards: 50% opacity, scale 0.9.
  - **Active card**: wider (350), yellow, top corners 120 radius (arch), lifted 24px. Its photo is bigger (250) and floats (bob + slight rotate, 4s loop).
- Every card has:
  - a black pill "STARTING AT ৳…"
  - the name
  - a subtitle
  - an outlined **অর্ডার করো** button with a cart icon
- **Active card only**:
  - Tier selector অল্প / বেশি / অনেক (snacks only), which changes the shown price.
  - **ঝাল** meter: 5 bars, red = spice level.
  - Big price.
- Prev / next circular outline buttons plus pill indicators (the active one is a wide yellow pill).
- Changing the slide resets the tier to অল্প.
- Animate the size/color changes (~550ms, `Curves.easeOutCubic` style).
- Items with `image: null` show an orange circle with the Bebas `placeholderTag` and "[ছবি দরকার]".

### 4. Checker strip (brown/black)
- 72px tall, 2 rows of 36px squares, alternating `richBrown`/`khaoBlack`.
- Slowly scrolls horizontally (8s per 72px). Use a `CustomPainter` with an animated x-offset.
- It's the visual joint between two sections. Mobile: 48px.

### 5. টুকটাক খাও menu (bg black)
- Galada kicker in yellow, big heading.
- **Desktop**: a white card with a 2px black border and radius 28, laid out as a table.
  - Columns: circular thumb · item name/tagline · অল্প · বেশি · অনেক.
  - The header row is cream, with tier pills in yellow / orange / red plus piece counts.
  - Rows have dashed dividers. On hover the row turns `rowHover` and the thumbnail scales/rotates.
- Bottom of the card: a yellow two-column **সব খাও** band.
  - Left: tilted heading plus the Galada tagline.
  - Right: the includes list plus a black circular price sticker **৳১১০** rotated −8°.
- **Mobile**: one cream card per item.
  - Thumb + name.
  - A 3-column row of price boxes (yellow / orange / black) labelled "অল্প · ৪ পিস" etc.
  - Then the yellow combo card.

### 6. Checker strip (black/cream)

### 7. KHAO-এর একটা দিন (bg `khaoCream`, text black)
- Galada kicker "সকাল ১১টা থেকে রাত ১০টা" in `darkRed`. Heading **KHAO-এর একটা দিন**.
- **Desktop**: a horizontal dashed line, with 3 columns sitting on it.
  - Each column has a numbered dot (১১ yellow, ৫ orange, ১০ red).
  - Then an image card (2px black border, radius 24), a time label, the title with price, and a description.
  - The third column is a brown card with the drinks/sauces price list instead of a photo.
- **Mobile**: a vertical dashed line on the left. The dots sit on the line and the cards stack.
- Dots pop in (scale 0 → 1) as they scroll into view.

### 8. Checker strip (cream/black)

### 9. Find us (bg black)
- Desktop has two columns: the shop photo (radius 32, slight parallax) and the info.
- The info column has:
  - kicker "04 — FIND US"
  - heading **একবার খাও, / বারবার আসো!** (second line yellow)
  - paragraph
  - a definition list: ঠিকানা, খোলা, ফোন, ফলো করো
  - a yellow **ম্যাপে দেখো →** button
- Mobile: the photo goes on top, and **ম্যাপ** / **কল করো** buttons sit side by side.
- Wire `url_launcher` for map, phone (`tel:`) and social links from `menu.json` → `contact`.

### 10. Checker strip (black/cream) + Footer (bg cream)
- `logo-on-light.png`.
- Galada line "ভালো খাবার, ভালো মামুর, ভালো আড্ডা".
- "© 2026 KHAO · Mohammadpur".
- Desktop: one row, space-between. Mobile: centered stack.

## Motion summary

| Where | Effect |
|---|---|
| Hero load | Video zooms 1.12 → 1.0 (2.4s). Headline lines slide up out of a clip (1.1s, staggered 150ms/320ms). Paragraph and buttons fade up (delays 0.6s / 0.8s) |
| Hero badge | Text ring rotates continuously; flame flickers |
| Ticker | Infinite horizontal marquee |
| Scroll reveal | Section headings, cards and rows fade up 24px as they enter the viewport (`visibility_detector` + `flutter_animate`) |
| Carousel | Animated width/color/elevation change on the active card; the active photo floats |
| Checker strips | Slow continuous horizontal pattern drift |
| Hover (web) | Buttons lift 3px; menu rows highlight; photos zoom 1.06–1.1 |
| Reduced motion | Respect `MediaQuery.disableAnimations`: show end states, no loops |

## Suggested structure

```
lib/
  main.dart
  theme/khao_theme.dart          // colors, text styles
  data/menu_repository.dart      // loads assets/data/menu.json → models
  models/                        // MenuItem, Tier, Daypart, Contact
  widgets/
    hero_video_section.dart
    ticker_strip.dart
    signature_carousel.dart
    checker_strip.dart           // CustomPainter, colors as params
    menu_table.dart              // desktop table + mobile cards
    day_timeline.dart            // horizontal / vertical
    find_us_section.dart
    khao_footer.dart
    reveal_on_scroll.dart
  pages/home_page.dart           // CustomScrollView of all sections, GlobalKeys for nav scroll
```

Packages: `google_fonts`, `video_player`, `flutter_animate`, `visibility_detector`, `url_launcher`. Optionally `go_router` if more pages come later.

## Still missing (keep as visible placeholders)
- Photos of নাগা আলু সিঙ্গারা and দুধ চা.
- Exact address, phone number, Facebook/Instagram/map links.
- Real hero footage. The current `hero.mp4` is a slideshow made from the food photos. Swap the file when the real video arrives; no code change should be needed.
