#  Add Expense Screen Specifications

##  Layout & Colors
- **Header Card:** `0xFF2D2F33` (Dark Charcoal/Grey)
- **Amount Text:** `0xFFFFFFFF` (White)
- **Cancel Button (X):** `0xFFE53935` (Danger Red)
- **Checkmark Button (✓):** `0xFF00C853` (Success Green)
- **Save Button:** `0xFF00C853` (Success Green)
- **Category Icon Background:** `0xFFF5F5F5` (Light Grey circle)

##  Flutter Implementation
- **Top Card:** Use a `Container` with `BorderRadius.vertical(bottom: Radius.circular(24))`.
- **Category List:** Use a `ListView.builder` or `Column` for the list of categories (Food, Transport, etc.).
- **Row Styling:** Each category row should have an Icon in a circle on the left and the name text on the right.
- **Save Button:** Use `ElevatedButton` with `width: double.infinity` at the bottom of the screen.

##  Assets Needed
- `add_expense_preview.png`
- `ic_food.svg`, `ic_transport.svg`, `ic_rent.svg`, `ic_shopping.svg`
