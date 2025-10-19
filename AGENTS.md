# HeadroomCalc Agent Notes

## Project Overview
- **Platform:** SwiftUI app targeting Apple platforms with SwiftData persistence.
- **Entry Point:** `HeadroomCalcApp` sets up a `modelContainer` for `YearLedger`, `IncomeEntry`, and `FilingProfile` models and hosts `ContentView`.
- **Navigation:** `ContentView` uses a `NavigationSplitView` where the sidebar lists `YearLedger` instances and the detail pane shows a summary plus income entry list for the selected year. It also presents Settings, export/share sheets, and an onboarding How-To sheet.

## Data Model Basics
- `FilingProfile` captures filing status (`FilingStatus` enum) and a standard deduction amount. Instances are attached optionally to `YearLedger` and duplicated when cloning ledgers.
- `YearLedger` is the central year record. It stores the tax year, optional `FilingProfile`, and a cascading relationship to its `IncomeEntry` collection. Helper methods exist to add entries, clone a ledger for a new year (deep copy), compute `totalIncome`, and ensure relationships stay in sync.
- `IncomeEntry` tracks individual income sources with metadata like shares and cost basis. Each entry references its parent `YearLedger` through the inverse relationship.

## Tax Calculation Flow
- `HeadroomSummaryView` reacts to ledger/profile changes and calls `HeadroomEngine.compute(for:)`. The result drives summary rows (taxable income, bracket information, headroom). Errors map to user-facing guidance about missing profiles or absent tax table JSON bundles.
- Ensure non-finite numeric values are clamped before formatting to avoid rendering issues; utilities for this exist in both `ContentView` and `HeadroomSummaryView`.

## UI Components
- `IncomeListView` manages the detailed list of `IncomeEntry` items, including editing sheets (`AddIncomeSheet`) and inline help affordances (`InlineHelpView`).
- Settings and onboarding flows live in `SettingsView`, `HowToUseView`, and `AboutView`; they rely on the models above and standard SwiftUI state patterns.

## Development Tips
- When adding new models or relationships, import `SwiftData` and define proper `@Relationship` inverses to avoid macro resolution errors.
- Tests live under `HeadroomCalcTests`/`HeadroomCalcUITests`; they require Xcode tooling not available in this container, so prefer reasoning about logic or writing Swift unit tests but expect to run them locally.
- PDF export uses `ReportExporter` and will fail gracefully if tax tables are missing; keep this in mind when adjusting export-related code paths.
