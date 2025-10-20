# HeadroomCalc

HeadroomCalc is a SwiftUI app that helps investors keep tabs on their capital gains tax headroom for the current tax year. It stores filing profiles and year-by-year ledgers with detailed income entries using SwiftData, then computes how much room remains in each tax bracket.

## Features
- **Ledger management:** Track multiple tax years with their own filing profile and income entries.
- **SwiftData persistence:** Uses the new SwiftData framework with proper `@Relationship` inverses between `FilingProfile`, `YearLedger`, and `IncomeEntry` models.
- **Headroom calculations:** Summaries powered by `HeadroomEngine` show total income, taxable income, bracket details, and remaining headroom.
- **Rich UI:** A `NavigationSplitView` sidebar lists ledgers while detail views surface summaries, income entry editing, onboarding, and settings.
- **Export support:** Generate shareable reports through `ReportExporter`.

## Requirements
- Xcode 15 or later.
- Swift 5.9 toolchain.
- iOS 17 / macOS 14 SDKs (SwiftData requirement).

## Project Structure
```
HeadroomCalc/
├── HeadroomCalc/              # App target source
│   ├── HeadroomCalcApp.swift  # Entry point setting up the SwiftData model container
│   ├── Models/                # SwiftData models (FilingProfile, YearLedger, IncomeEntry)
│   ├── Views/                 # SwiftUI views (ContentView, IncomeListView, Settings, etc.)
│   └── Utilities/             # Helpers such as HeadroomEngine and ReportExporter
├── HeadroomCalcTests/         # Unit tests (run via Xcode)
└── HeadroomCalcUITests/       # UI tests (run via Xcode)
```

## Getting Started
1. Open the project in Xcode 15 or later.
2. Ensure the deployment target is iOS 17 (or macOS 14 for the Mac catalyst build).
3. Clean the build folder (`Shift` + `Cmd` + `K`) the first time you open the project.
4. Run the app on a simulator or device.

### Seeding Data
On first launch, the app seeds example ledgers and entries if none exist. To reset the store after changing models:
- Delete the app from the simulator/device, or
- Use Simulator → *Erase All Content and Settings...*

## Data Model Relationships
- `FilingProfile` ↔ `YearLedger`: `FilingProfile.ledgers` cascades deletes to ledgers; each `YearLedger` keeps a `.profile` reference that nullifies on profile removal.
- `YearLedger` ↔ `IncomeEntry`: Ledgers cascade-delete their `entries`; each `IncomeEntry` maintains a `.ledger` inverse reference.

When creating instances manually, make sure to set both sides of the relationship or use the provided convenience initialisers that do so automatically.

## Troubleshooting
- **Unknown attribute 'Relationship':** Verify you are building with Xcode 15+, targeting iOS 17/macOS 14, and that SwiftData is linked to the target.
- **Circular reference resolving attached macro 'Relationship':** Confirm inverse key paths are correct and that each `@Model` is part of the build target.
- **Model mismatches at runtime:** Delete the installed app to remove stale SwiftData stores whenever you change model schemas.

## Contributing
1. Create a feature branch.
2. Make your changes and add tests when possible.
3. Run `swift test` or Xcode test suites locally.
4. Open a pull request summarising your updates.

## License
This project is maintained privately. Contact the maintainers for licensing details.
