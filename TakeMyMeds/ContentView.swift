import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(filter: #Predicate<Medication> { $0.active }) private var medications: [Medication]

    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "calendar") }
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
