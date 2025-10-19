//
//  YearLedger.swift
//  HeadroomCalc
import Foundation
import SwiftData

@Model
final class YearLedger {
    @Attribute(.unique) var year: Int
    @Relationship(deleteRule: .nullify)
    var profile: FilingProfile?
    @Relationship(deleteRule: .cascade, inverse: \IncomeEntry.ledger)
    var entries: [IncomeEntry] = []

    init(year: Int, profile: FilingProfile? = nil, entries: [IncomeEntry] = []) {
        self.year = year
        self.profile = profile
        self.entries = entries
        // Ensure inverse is set for any pre-seeded entries
        for e in self.entries { e.ledger = self }
    }

    // MARK: - Mutation helpers (add only; use modelContext.delete(_) for removals)
    func addEntry(_ entry: IncomeEntry) {
        entry.ledger = self
        entries.append(entry)
    }

    /// Creates a deep copy of the ledger for a different year, preserving relevant metadata.
    func cloned(forYear newYear: Int) -> YearLedger {
        let clonedProfile = profile.map { FilingProfile(status: $0.status, standardDeduction: $0.standardDeduction) }
        let clonedEntries: [IncomeEntry] = entries.map { entry in
            let copy = IncomeEntry(sourceType: entry.sourceType,
                                   displayName: entry.displayName,
                                   amount: entry.amount,
                                   shares: entry.shares,
                                   fairMarketPrice: entry.fairMarketPrice,
                                   costBasisPerShare: entry.costBasisPerShare)
            copy.symbol = entry.symbol
            return copy
        }
        return YearLedger(year: newYear, profile: clonedProfile, entries: clonedEntries)
    }

    var totalIncome: Double {
        let sum = entries.reduce(0) { acc, e in
            let v = e.amount
            return acc + (v.isFinite ? v : 0)
        }
        return sum.isFinite ? sum : 0
    }
}
