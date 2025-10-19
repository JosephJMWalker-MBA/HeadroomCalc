//
//  HeadroomCalcApp.swift
//  HeadroomCalc
//
//  Created by Jeff Walker on 10/16/25.
//

import SwiftUI
import SwiftData

@main
struct HeadroomCalcApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [YearLedger.self, IncomeEntry.self, FilingProfile.self])
    }
}
