import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \YearLedger.year, order: .reverse) private var ledgers: [YearLedger]

    @State private var selection: YearLedger?
    @State private var showingSettings = false
    @State private var exportedURL: URL?
    @State private var showingShare = false
    @State private var exportError: String?
    @AppStorage("hasSeenHowTo") private var hasSeenHowTo: Bool = false

    private enum ActiveSheet: Identifiable {
        case settings
        case share(URL)
        case howTo
        var id: String {
            switch self {
            case .settings: return "settings"
            case .share(let url): return "share:\(url.absoluteString)"
            case .howTo: return "howto"
            }
        }
    }
    @State private var activeSheet: ActiveSheet?

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(ledgers) { ledger in
                    NavigationLink(value: ledger) {
                        VStack(alignment: .leading) {
                            Text(ledger.year, format: .number.grouping(.never))
                                .font(.headline)
                            Text("\(ledger.entries.count) entries — " + currency(ledger.totalIncome))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteYears)
            }
            .navigationTitle("HeadroomCalc")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        addCurrentYearIfNeeded()
                    } label: { Label("Add Year", systemImage: "calendar.badge.plus") }

                    Button {
                        clonePreviousYear()
                    } label: { Label("Clone Last Year", systemImage: "rectangle.on.rectangle") }

                    EditButton()
                }
            }
        } detail: {
            if let selectedLedger = selection {
                VStack(spacing: 0) {
                    HeadroomSummaryView(ledger: selectedLedger)
                    Divider()
                    IncomeListView(ledger: selectedLedger)
                }
                .navigationTitle(Text(selectedLedger.year, format: .number.grouping(.never)))
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button {
                            do {
                                let url = try ReportExporter.exportPDF(for: selectedLedger)
                                exportedURL = url
                                DispatchQueue.main.async { activeSheet = .share(url) }
                            } catch {
                                exportError = (error as? ReportExporterError) == .tablesUnavailable
                                    ? "Tax tables are unavailable for this year."
                                    : "Could not render PDF."
                            }
                        } label: {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }

                        Button {
                            ensureProfile(for: selectedLedger)
                            DispatchQueue.main.async { activeSheet = .settings }
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
                .sheet(item: $activeSheet) { item in
                    switch item {
                    case .settings:
                        SettingsView(ledger: selectedLedger)
                    case .share(let url):
                        ReportShareView(url: url)
                    case .howTo:
                        NavigationStack { HowToUseView() }
                    }
                }
                .alert("Export Error", isPresented: Binding(
                    get: { exportError != nil },
                    set: { if !$0 { exportError = nil } }
                )) {
                    Button("OK", role: .cancel) { exportError = nil }
                } message: {
                    Text(exportError ?? "Unknown error")
                }
            } else {
                ContentUnavailableView("Select or add a year",
                                       systemImage: "calendar",
                                       description: Text("Your income entries and headroom will appear here."))
            }
        }
        .onAppear {
            if selection == nil { selection = ledgers.first }
            if !hasSeenHowTo {
                DispatchQueue.main.async {
                    activeSheet = .howTo
                    hasSeenHowTo = true
                }
            }
        }
    }

    // Clamp non-finite values to avoid CoreGraphics NaN warnings during formatting/rendering
    private func currency(_ x: Double) -> String { (x.isFinite ? x : 0).formatted(.currency(code: "USD")) }

    // MARK: - Actions

    private func addCurrentYearIfNeeded() {
        let y = Calendar.current.component(.year, from: Date())
        if !ledgers.contains(where: { $0.year == y }) {
            let ledger = YearLedger(year: y, profile: FilingProfile()) // default profile
            modelContext.insert(ledger)
            selection = ledger
        } else {
            selection = ledgers.first(where: { $0.year == y })
        }
    }

    private func clonePreviousYear() {
        guard let mostRecent = ledgers.first else { return }
        let newYear = (mostRecent.year + 1)
        guard !ledgers.contains(where: { $0.year == newYear }) else {
            selection = ledgers.first(where: { $0.year == newYear })
            return
        }

        let cloned = YearLedger(year: newYear,
                                profile: mostRecent.profile.map { FilingProfile(status: $0.status,
                                                                                standardDeduction: $0.standardDeduction) },
                                entries: mostRecent.entries.map {
                                    IncomeEntry(sourceType: $0.sourceType,
                                                displayName: $0.displayName,
                                                amount: $0.amount,
                                                shares: $0.shares,
                                                fairMarketPrice: $0.fairMarketPrice,
                                                costBasisPerShare: $0.costBasisPerShare)
                                })
        modelContext.insert(cloned)
        selection = cloned
    }

    private func deleteYears(at offsets: IndexSet) {
        let ledgersToDelete = offsets.compactMap { index in
                    ledgers.indices.contains(index) ? ledgers[index] : nil
                }

                if let selected = selection, ledgersToDelete.contains(where: { $0 === selected }) {
                    selection = nil
                }

                for ledger in ledgersToDelete {
                    modelContext.delete(ledger)
                }

                selection = selection ?? ledgers.first
        selection = ledgers.first
    }

    private func ensureProfile(for ledger: YearLedger) {
        if ledger.profile == nil {
            ledger.profile = FilingProfile()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [YearLedger.self, IncomeEntry.self, FilingProfile.self])
}
