import Foundation

struct ScheduledDose: Identifiable {
    let id = UUID()
    let medication: Medication
    let scheduledFor: Date
    var log: DoseLog?

    var isTaken: Bool { log != nil && log?.skipped == false }
    var isSkipped: Bool { log?.skipped == true }
    var isPending: Bool { log == nil }
    var isOverdue: Bool { isPending && scheduledFor < Date() }
}

enum ScheduleEngine {
    static func todaysDoses(from medications: [Medication]) -> [ScheduledDose] {
        let today = Calendar.current.startOfDay(for: Date())
        var doses: [ScheduledDose] = []

        for med in medications where med.active {
            guard let schedule = med.schedule else { continue }
            guard schedule.frequency != .asNeeded else { continue }
            guard isDueOn(date: today, schedule: schedule) else { continue }

            for timeStr in schedule.times {
                guard let scheduledDate = date(for: timeStr, on: today) else { continue }
                let matchingLog = med.doseLogs.first { log in
                    guard let logScheduled = log.scheduledFor else { return false }
                    return Calendar.current.isDate(logScheduled, equalTo: scheduledDate, toGranularity: .minute)
                }
                doses.append(ScheduledDose(medication: med, scheduledFor: scheduledDate, log: matchingLog))
            }
        }

        return doses.sorted { $0.scheduledFor < $1.scheduledFor }
    }

    static func isDueOn(date: Date, schedule: MedSchedule) -> Bool {
        switch schedule.frequency {
        case .daily, .twiceDaily:
            return true
        case .biWeekly:
            guard let anchor = schedule.anchorDate else { return false }
            let anchorDay = Calendar.current.startOfDay(for: anchor)
            let targetDay = Calendar.current.startOfDay(for: date)
            let days = Calendar.current.dateComponents([.day], from: anchorDay, to: targetDay).day ?? 0
            return days >= 0 && days % 14 == 0
        case .asNeeded:
            return false
        }
    }

    static func nextDueDate(for schedule: MedSchedule) -> Date? {
        guard schedule.frequency == .biWeekly, let anchor = schedule.anchorDate else { return nil }
        let today = Calendar.current.startOfDay(for: Date())
        let anchorDay = Calendar.current.startOfDay(for: anchor)
        let daysSince = Calendar.current.dateComponents([.day], from: anchorDay, to: today).day ?? 0
        if daysSince < 0 { return anchor }
        let remainder = daysSince % 14
        let daysUntilNext = remainder == 0 ? 14 : 14 - remainder
        return Calendar.current.date(byAdding: .day, value: daysUntilNext, to: today)
    }

    static func date(for timeStr: String, on date: Date) -> Date? {
        let parts = timeStr.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }
        return Calendar.current.date(bySettingHour: parts[0], minute: parts[1], second: 0, of: date)
    }

    static func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
