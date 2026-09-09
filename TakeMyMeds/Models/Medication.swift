import SwiftUI
import SwiftData

enum MedicationType: String, Codable, CaseIterable {
    case vitamin = "Vitamin"
    case prescription = "Prescription"
    case injectable = "Injectable"
    case asNeeded = "As Needed"

    var color: Color {
        switch self {
        case .vitamin: return .blue
        case .prescription: return .green
        case .injectable: return .orange
        case .asNeeded: return .purple
        }
    }

    var systemImage: String {
        switch self {
        case .vitamin: return "pill"
        case .prescription: return "cross.vial"
        case .injectable: return "syringe"
        case .asNeeded: return "staroflife"
        }
    }
}

@Model final class Medication {
    var id: UUID = UUID()
    var name: String = ""
    var type: MedicationType = MedicationType.vitamin
    var dose: String = ""
    var notes: String = ""
    var active: Bool = true
    var createdAt: Date = Date()

    @Relationship(deleteRule: .cascade) var schedule: MedSchedule?
    @Relationship(deleteRule: .cascade) var doseLogs: [DoseLog] = []
    @Relationship(deleteRule: .cascade) var bottles: [InjectionBottle] = []

    init(name: String, type: MedicationType, dose: String = "", notes: String = "") {
        self.name = name
        self.type = type
        self.dose = dose
        self.notes = notes
    }

    var currentBottle: InjectionBottle? { bottles.first { $0.isCurrent } }
    var totalDosesTaken: Int { doseLogs.filter { !$0.skipped }.count }
    var lastTakenDate: Date? { doseLogs.filter { !$0.skipped }.map(\.takenAt).max() }
}
