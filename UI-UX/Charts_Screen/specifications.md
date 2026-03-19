#   Charts (Spending Analysis) Screen 

##  Colors & Style
- **Background:** `0xFFFFFFFF` (Pure White)
- **Chart Ring (Empty/Base):** `0xFFE0E0E0` (Light Grey)
- **Chart Ring (Active):** `0xFF00C853` (Success Green)
- **Tab Background (Active):** `0xFFFFFFFF` (White with Black Border)
- **Tab Background (Inactive):** `0xFF212121` (Dark Grey/Black)
- **Bottom Nav Bar:** `0xFF1A1C1E` (Dark Charcoal)

##  Flutter Implementation
- **Spending Analysis Header:** `Text` widget, centered, bold.
- **Time Filter Tabs:** Use a `Row` with three `Expanded` containers (Week, Month, Year).
  - The "Week" tab has a white background and rounded corners on the left.
- **Donut Chart:** Use the `fl_chart` package.
  - Set the center text to `0%` (or the actual percentage).
  - **Stroke Width:** `30.0` for a thick, modern ring.
- **Floating Action Button:** Green circle with a white `+` icon, placed above the Nav Bar.

##  Assets Needed
- `statistics_preview.png` 
- `ic_charts_active.svg` 
