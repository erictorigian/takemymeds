import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(filter: #Predicate<Medication> { $0.active }) private var medications: [Medication]

    private var overdueCount: Int {
        ScheduleEngine.todaysDoses(from: medications).filter(\.isOverdue).count
    }

    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "calendar") }
                .badge(overdueCount > 0 ? overdueCount : 0)

            MedicationListView()
                .tabItem { Label("Medications", systemImage: "pill") }

            HistoryView()
                .tabItem { Label("History", systemImage: "clock") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .onChange(of: medications) {
            Task { await NotificationManager.shared.scheduleAll(for: medications) }
        }
    }
}
