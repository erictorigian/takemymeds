import SwiftUI

struct MedicationDetailView: View {
    let medication: Medication
    @State private var showEdit = false

    var body: some View {
        List {
            Section("Details") {
                LabeledContent("Type", value: medication.type.rawValue)
                if !medication.dose.isEmpty {
                    LabeledContent("Dose", value: medication.dose)
                }
                if !medication.notes.isEmpty {
                    LabeledContent("Notes", value: medication.notes)
                }
            }

            if let schedule = medication.schedule {
                Section("Schedule") {
                    LabeledContent("Frequency", value: schedule.frequency.rawValue)
                    if schedule.frequency != .asNeeded {
                        ForEach(schedule.times, id: \.self) { t in
                            LabeledContent("Time", value: t)
                        }
                    }
                    if let next = ScheduleEngine.nextDueDate(for: schedule) {
                        LabeledContent("Next Dose", value: next.formatted(date: .abbreviated, time: .omitted))
                    }
                }
            }

            Section("Stats") {
                LabeledContent("Total Taken", value: "\(medication.totalDosesTaken)")
                if let last = medication.lastTakenDate {
                    LabeledContent("Last Taken", value: last.formatted(date: .abbreviated, time: .shortened))
                }
            }

            if medication.type == .injectable {
                Section("Bottles") {
                    if let current = medication.currentBottle {
                        NavigationLink("Manage Bottles") { BottleManagerView(medication: medication) }
                        LabeledContent("Doses Remaining", value: "\(current.dosesRemaining) / \(current.totalDoses)")
                        LabeledContent("Bottle Age", value: "\(current.ageInDays) days")
                        if current.isExpired {
                            Label("Bottle Expired", systemImage: "exclamationmark.triangle.fill").foregroundStyle(.red)
                        } else if let days = current.daysUntilExpiry, days <= 7 {
                            Label("Expires in \(days) days", systemImage: "exclamationmark.triangle").foregroundStyle(.orange)
                        }
                    } else {
                        NavigationLink("Open New Bottle") { BottleManagerView(medication: medication) }
                    }
                }
            }
        }
        .navigationTitle(medication.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showEdit = true }
            }
        }
        .sheet(isPresented: $showEdit) {
            MedicationFormView(medication: medication)
        }
    }
}
