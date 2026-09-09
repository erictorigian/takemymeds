import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermission() async {
        try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleAll(for medications: [Medication]) async {
        let center = UNUserNotificationCenter.current()
        await center.removeAllPendingNotificationRequests()

        var scheduled = 0
        let maxNotifications = 60
        let calendar = Calendar.current

        for med in medications where med.active {
            guard let schedule = med.schedule, schedule.frequency != .asNeeded else { continue }
            if scheduled >= maxNotifications { break }

            for dayOffset in 0..<7 {
                guard let day = calendar.date(byAdding: .day, value: dayOffset, to: Date()) else { continue }
                let dayStart = calendar.startOfDay(for: day)
                guard ScheduleEngine.isDueOn(date: dayStart, schedule: schedule) else { continue }

                for timeStr in schedule.times {
                    guard scheduled < maxNotifications,
                          let fireDate = ScheduleEngine.date(for: timeStr, on: dayStart),
                          fireDate > Date() else { continue }

                    let content = UNMutableNotificationContent()
                    content.title = "Time for \(med.name)"
                    content.body = med.dose.isEmpty ? "Don't forget your medication." : "Dose: \(med.dose)"
                    content.sound = .default

                    let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
                    let request = UNNotificationRequest(
                        identifier: "\(med.id)-\(timeStr)-\(dayOffset)",
                        content: content,
                        trigger: trigger
                    )
                    try? await center.add(request)
                    scheduled += 1
                }
            }
        }
    }
}
