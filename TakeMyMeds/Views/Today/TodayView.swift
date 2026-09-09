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

    private var takenCount: Int { scheduledDoses.filter(\.isTaken).count }
    private var overdueCount: Int { scheduledDoses.filter(\.isOverdue).count }

    var body: some View {
        NavigationStack {
            List {
                if !scheduledDoses.isEmpty {
                    Section {
                        ForEach(scheduledDoses) { dose in
                            DoseCardView(dose: dose) {
                                markTaken(dose: dose)
                            } onSkip: {
                                skip(dose: dose)
                            }
                        }
                    } header: {
                        HStack {
                            Text("Scheduled")
                            Spacer()
                            Text("\(takenCount) of \(scheduledDoses.count) taken")
                                .foregroundStyle(overdueCount > 0 ? .red : .secondary)
                                .monospacedDigit()
                                .textCase(nil)
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
                    ContentUnavailableView(
                        "No Medications Today",
                        systemImage: "checkmark.circle",
                        description: Text("Add medications in the Medications tab.")
                    )
                    .listRowBackground(Color.clear)
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
        Date().formatted(.dateTime.weekday(.wide).month().day())
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
