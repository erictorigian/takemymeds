import SwiftUI
import SwiftData

struct MedicationListView: View {
    @Query(filter: #Predicate<Medication> { $0.active }, sort: \Medication.name) private var medications: [Medication]
    @State private var showAdd = false

    private var grouped: [(MedicationType, [Medication])] {
        MedicationType.allCases.compactMap { type in
            let meds = medications.filter { $0.type == type }
            return meds.isEmpty ? nil : (type, meds)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if medications.isEmpty {
                    ContentUnavailableView(
                        "No Medications",
                        systemImage: "pill.circle",
                        description: Text("Tap + to add your first medication.")
                    )
                } else {
                    List {
                        ForEach(grouped, id: \.0) { type, meds in
                            Section {
                                ForEach(meds) { med in
                                    NavigationLink(destination: MedicationDetailView(medication: med)) {
                                        MedRow(medication: med)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button("Archive", role: .destructive) { med.active = false }
                                            .tint(.red)
                                    }
                                }
                            } header: {
                                Label(type.rawValue, systemImage: type.systemImage)
                                    .foregroundStyle(type.color)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Medications")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                MedicationFormView()
            }
        }
    }
}

private struct MedRow: View {
    let medication: Medication

    var body: some View {
        HStack(spacing: 14) {
            MedTypeIcon(type: medication.type, size: 38)

            VStack(alignment: .leading, spacing: 3) {
                Text(medication.name)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)

                Group {
                    if !medication.dose.isEmpty, let schedule = medication.schedule {
                        Text("\(medication.dose) · \(schedule.frequency.rawValue)")
                    } else if !medication.dose.isEmpty {
                        Text(medication.dose)
                    } else if let schedule = medication.schedule {
                        Text(schedule.frequency.rawValue)
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
