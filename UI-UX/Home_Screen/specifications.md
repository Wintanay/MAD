#  Home Screen Specifications

##  Layout & Colors
- **Top Card:** `0xFF1A1C1E` (Dark Charcoal)
- **Primary Green:** `0xFF00C853` (Income text & Floating Action Button)
- **Danger Red:** `0xFFE53935` (Expense text)
- **Background:** `0xFFFFFFFF` (White)

##  Flutter Implementation
- **Total Balance:** Large `Text` widget (e.g., 24px), centered inside the Dark Card.
- **Empty State:** When no transactions exist, center the `ic_no_transactions.svg` and the text "No Transactions yet."
- **Navigation:** The "Home" icon in the bottom bar should be highlighted in `0xFF00C853`.

##  Assets Needed
- `home_preview.png` (Exported from Figma)
- `ic_no_transactions.svg` (The empty list icon)
