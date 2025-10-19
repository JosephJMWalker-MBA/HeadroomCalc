//
//  FilingProfile.swift
//  HeadroomCalc
import Foundation
import SwiftData

enum FilingStatus: String, Codable, CaseIterable, Identifiable {
    case single = "Single"
    case marriedJoint = "Married Filing Jointly"
    case marriedSeparate = "Married Filing Separately"
    case headOfHousehold = "Head of Household"

    var id: String { rawValue }
}

@Model
final class FilingProfile {
    var status: FilingStatus
    var standardDeduction: Double   // v1: simple; can evolve by year/age later
    init(status: FilingStatus = .single, standardDeduction: Double = 14600) {
        self.status = status
        self.standardDeduction = standardDeduction
    }
}
