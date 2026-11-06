# KHAO web

One-page responsive site for KHAO (Mohammadpur, Dhaka) — Flutter Web, built
from the original design handoff (Design A, "Street Fire"; see `HANDOFF.md`).
Breakpoint: 860px. The handoff copy, its zips and the `reference/` design
screenshots were removed to keep the repo small; they remain in git history
(before the commit that removed them).

```sh
flutter run -d chrome
flutter build web --release
```

## Content

All menu items, prices, tiers, dayparts and contact info come from
`assets/data/menu.json`. The project copy adds a few fields the original
handoff JSON lacked, taken from the design source: `carouselSub` (carousel
subtitles), `nameEn` on daypart items (ticker), `tickerOrder`, the all-day
`desc`, and `shortName` for the sauces.

Contact values that are still placeholders (`[link]`, `[ফোন নম্বর]`) show a
"coming soon" snackbar instead of launching. Fill them in and they become live
links — no code change needed. Same for `assets/video/hero.mp4`.

## Fonts

`google_fonts` is used for Anek Bangla, Bebas Neue, Galada and Hind Siliguri,
with the font files bundled in `assets/google_fonts/` (downloaded from the
Google Fonts css2 API, OFL licensed). Bundling pins the same font versions the
design was rendered with; the package's own pinned versions have different
metrics. Bebas Neue has no Bangla glyphs — use `LatinText`, which asserts on
Bangla input.

## Structure

```
lib/
  main.dart
  theme/khao_theme.dart        colors, layout, motion, text styles
  data/menu_repository.dart    loads menu.json
  data/links.dart              url_launcher wrapper (map, tel:, socials)
  models/                      menu models, Bangla digits, section ids
  widgets/                     one file per section + common pieces
  pages/home_page.dart         page assembly, nav scrolling
```

Motion respects `prefers-reduced-motion` (`MediaQuery.disableAnimations`):
end states are shown and loops are stopped.
