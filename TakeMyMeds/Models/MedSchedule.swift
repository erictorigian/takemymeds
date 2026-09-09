import Foundation
import SwiftData

enum ScheduleFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case twiceDaily = "Twice Daily"
    case biWeekly = "Every 2 Weeks"
    case asNeeded = "As Needed"

    var defaultTimes: [String] {
        switch self {
        case .daily: return ["08:00"]
        case .twiceDaily: return ["08:00", "20:00"]
        case .biWeekly: return ["09:00"]
        case .asNeeded: return []
        }
    }

    var displayName: String { rawValue }
}

@Model final class MedSchedule {
    var frequency: ScheduleFrequency = ScheduleFrequency.daily
    var times: [String] = ["08:00"]
    var anchorDate: Date? = nil

    @Relationship var medication: Medication?

    init(frequency: ScheduleFrequency, times: [String]? = nil, anchorDate: Date? = nil) {
        self.frequency = frequency
        self.times = times ?? frequency.defaultTimes
        self.anchorDate = anchorDate
    }
}
