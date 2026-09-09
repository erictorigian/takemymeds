import Foundation
import SwiftData

@Model final class DoseLog {
    var id: UUID = UUID()
    var scheduledFor: Date? = nil
    var takenAt: Date = Date()
    var skipped: Bool = false
    var notes: String = ""

    @Relationship var medication: Medication?
    @Relationship var bottle: InjectionBottle?

    init(medication: Medication, scheduledFor: Date? = nil, takenAt: Date = Date(), skipped: Bool = false, notes: String = "", bottle: InjectionBottle? = nil) {
        self.medication = medication
        self.scheduledFor = scheduledFor
        self.takenAt = takenAt
        self.skipped = skipped
        self.notes = notes
        self.bottle = bottle
    }
}
