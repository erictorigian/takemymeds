import SwiftUI

struct MedicationDetailView: View {
    let medication: Medication
    @State private var showEdit = false

    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        MedTypeIcon(type: medication.type, size: 64)
                        VStack(spacing: 4) {
                            Text(medication.name)
                                .font(.title2.weight(.bold))
                            Text(medication.type.rawValue)
                                .font(.subheadline)
                                .foregroundStyle(medication.type.color)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(medication.type.color.opacity(0.12), in: Capsule())
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 12)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            Section("Details") {
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
                LabeledContent("Total Taken") {
                    Text("\(medication.totalDosesTaken)")
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                }
                if let last = medication.lastTakenDate {
                    LabeledContent("Last Taken", value: last.formatted(date: .abbreviated, time: .shortened))
                }
            }

            if medication.type == .injectable {
                Section("Bottles") {
                    if let current = medication.currentBottle {
                        NavigationLink(destination: BottleManagerView(medication: medication)) {
                            LabeledContent("Doses Remaining") {
                                Text("\(current.dosesRemaining) of \(current.totalDoses)")
                                    .monospacedDigit()
                                    .foregroundStyle(current.dosesRemaining <= 3 ? .orange : .primary)
                            }
                        }
                        LabeledContent("Bottle Age", value: "\(current.ageInDays) days")
                        if current.isExpired {
                            Label("Bottle Expired", systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                        } else if let days = current.daysUntilExpiry, days <= 7 {
                            Label("Expires in \(days) days", systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.orange)
                        }
                    } else {
                        NavigationLink(destination: BottleManagerView(medication: medication)) {
                            Label("Open New Bottle", systemImage: "plus.circle")
                                .foregroundStyle(medication.type.color)
                        }
                    }
                }
            }
        }
        .navigationTitle(medication.name)
        .navigationBarTitleDisplayMode(.inline)
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
