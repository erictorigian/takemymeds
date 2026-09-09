import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var medications: [Medication]
    @Query private var logs: [DoseLog]
    @Environment(\.modelContext) private var context
    @State private var showArchived = false
    @State private var showClearConfirm = false

    private var archivedMeds: [Medication] { medications.filter { !$0.active } }

    var body: some View {
        NavigationStack {
            List {
                Section("Notifications") {
                    Button("Reschedule Notifications") {
                        Task { await NotificationManager.shared.scheduleNotifications(for: medications) }
                    }
                }

                Section("Data") {
                    LabeledContent("Total Medications", value: "\(medications.filter { $0.active }.count)")
                    LabeledContent("Total Dose Logs", value: "\(logs.count)")
                    if !archivedMeds.isEmpty {
                        Button("View Archived (\(archivedMeds.count))") { showArchived = true }
                    }
                    Button("Clear All History", role: .destructive) { showClearConfirm = true }
                }

                Section("About") {
                    LabeledContent("App", value: "TakeMyMeds")
                    LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showArchived) {
                ArchivedMedicationsView(medications: archivedMeds)
            }
            .confirmationDialog("Clear all dose history?", isPresented: $showClearConfirm, titleVisibility: .visible) {
                Button("Clear History", role: .destructive) { clearHistory() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes all dose logs but keeps your medications and bottle records.")
            }
        }
    }

    private func clearHistory() {
        for log in logs { context.delete(log) }
    }
}

struct ArchivedMedicationsView: View {
    let medications: [Medication]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(medications) { med in
                HStack {
                    Image(systemName: med.type.systemImage).foregroundStyle(med.type.color)
                    VStack(alignment: .leading) {
                        Text(med.name).font(.headline)
                        Text(med.type.rawValue).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Restore") { med.active = true }
                        .buttonStyle(.bordered)
                        .tint(.green)
                }
            }
            .navigationTitle("Archived")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }
}
