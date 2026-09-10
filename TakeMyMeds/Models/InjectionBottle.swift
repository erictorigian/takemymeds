import Foundation
import SwiftData

@Model final class InjectionBottle {
    var id: UUID = UUID()
    var openedAt: Date? = nil
    var closedAt: Date? = nil
    var totalDoses: Int = 1
    var lotNumber: String? = nil
    var expiresAt: Date? = nil
    var maxOpenDays: Int? = nil
    var isCurrent: Bool = true
    var notes: String? = nil

    @Relationship var medication: Medication?
    @Relationship(deleteRule: .nullify) var doseLogs: [DoseLog] = []

    init(medication: Medication, openedAt: Date? = Date(), totalDoses: Int = 1, lotNumber: String? = nil, expiresAt: Date? = nil, maxOpenDays: Int? = nil, notes: String? = nil) {
        self.medication = medication
        self.openedAt = openedAt
        self.totalDoses = totalDoses
        self.lotNumber = lotNumber
        self.expiresAt = expiresAt
        self.maxOpenDays = maxOpenDays
        self.notes = notes
    }

    var dosesTaken: Int { doseLogs.filter { !$0.skipped }.count }
    var dosesRemaining: Int { max(0, totalDoses - dosesTaken) }

    var ageInDays: Int {
        guard let opened = openedAt else { return 0 }
        let end = closedAt ?? Date()
        return Calendar.current.dateComponents([.day], from: opened, to: end).day ?? 0
    }

    var isExpiredByDate: Bool { expiresAt.map { Date() > $0 } ?? false }
    var isExpiredByOpenDays: Bool { maxOpenDays.map { ageInDays >= $0 } ?? false }
    var isExpired: Bool { isExpiredByDate || isExpiredByOpenDays }

    var daysUntilExpiry: Int? {
        var candidates: [Int] = []
        if let exp = expiresAt {
            let days = Calendar.current.dateComponents([.day], from: Date(), to: exp).day ?? 0
            candidates.append(days)
        }
        if let maxDays = maxOpenDays {
            candidates.append(maxDays - ageInDays)
        }
        return candidates.min()
    }
}
