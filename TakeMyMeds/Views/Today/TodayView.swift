import SwiftUI
import SwiftData

struct TodayView: View {
    @Query(filter: #Predicate<Medication> { $0.active }) private var medications: [Medication]
    @Environment(\.modelContext) private var context
    @State private var showBottleAlert = false
    @State private var pendingMedication: Medication?

    private var scheduledDoses: [ScheduledDose] {
        ScheduleEngine.todaysDoses(from: medications)
    }

    private var asNeededMeds: [Medication] {
        medications.filter { $0.schedule?.frequency == .asNeeded }
    }

    var body: some View {
        NavigationStack {
            List {
                if !scheduledDoses.isEmpty {
                    Section("Scheduled") {
                        ForEach(scheduledDoses) { dose in
                            DoseCardView(dose: dose) {
                                markTaken(dose: dose)
                            } onSkip: {
                                skip(dose: dose)
                            }
                        }
                    }
                }

                if !asNeededMeds.isEmpty {
                    Section("As Needed") {
                        ForEach(asNeededMeds) { med in
                            AsNeededRowView(medication: med)
                        }
                    }
                }

                if scheduledDoses.isEmpty && asNeededMeds.isEmpty {
                    ContentUnavailableView("No Medications Today", systemImage: "checkmark.circle", description: Text("Add medications in the Medications tab."))
                }
            }
            .navigationTitle(todayTitle)
            .alert("Open a Bottle First", isPresented: $showBottleAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Open a new bottle for \(pendingMedication?.name ?? "this injectable") before logging a dose.")
            }
        }
    }

    private var todayTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    private func markTaken(dose: ScheduledDose) {
        let med = dose.medication
        if med.type == .injectable && med.currentBottle == nil {
            pendingMedication = med
            showBottleAlert = true
            return
        }
        let log = DoseLog(
            medication: med,
            scheduledFor: dose.scheduledFor,
            takenAt: Date(),
            bottle: med.currentBottle
        )
        context.insert(log)
    }

    private func skip(dose: ScheduledDose) {
        let log = DoseLog(
            medication: dose.medication,
            scheduledFor: dose.scheduledFor,
            takenAt: Date(),
            skipped: true
        )
        context.insert(log)
    }
}
