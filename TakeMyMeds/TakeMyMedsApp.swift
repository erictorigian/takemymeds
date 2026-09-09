import SwiftUI
import SwiftData

@main
struct TakeMyMedsApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Medication.self, MedSchedule.self, DoseLog.self, InjectionBottle.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task { await NotificationManager.shared.requestPermission() }
        }
        .modelContainer(container)
    }
}
