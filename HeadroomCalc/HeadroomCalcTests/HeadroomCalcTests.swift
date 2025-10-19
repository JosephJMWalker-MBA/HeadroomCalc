//
//  HeadroomCalcTests.swift
//  HeadroomCalcTests
//
//  Created by Jeff Walker on 10/16/25.
//

import Testing
@testable import HeadroomCalc

struct HeadroomCalcTests {

    @Test func clonedLedgerPreservesMetadata() throws {
        let profile = FilingProfile(status: .marriedJoint, standardDeduction: 50000)
        let ledger = YearLedger(year: 2025, profile: profile)

        let entry = IncomeEntry(sourceType: .restrictedStockUnit,
                                displayName: "AAPL — RSU Vest",
                                amount: 42_000,
                                shares: 100,
                                fairMarketPrice: 420,
                                costBasisPerShare: 100)
        entry.symbol = "AAPL"
        ledger.addEntry(entry)

        let clone = ledger.cloned(forYear: 2026)

        #expect(clone.year == 2026)
        #expect(clone.entries.count == 1)

        let clonedEntry = try #require(clone.entries.first)
        #expect(clonedEntry !== entry)
        #expect(clonedEntry.displayName == entry.displayName)
        #expect(clonedEntry.symbol == "AAPL")
        #expect(clonedEntry.amount == entry.amount)
        #expect(clonedEntry.shares == entry.shares)
        #expect(clonedEntry.fairMarketPrice == entry.fairMarketPrice)
        #expect(clonedEntry.costBasisPerShare == entry.costBasisPerShare)

        let clonedProfile = try #require(clone.profile)
        #expect(clonedProfile !== profile)
        #expect(clonedProfile.status == profile.status)
        #expect(clonedProfile.standardDeduction == profile.standardDeduction)
    }

}
