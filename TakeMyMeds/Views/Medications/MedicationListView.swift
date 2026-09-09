import SwiftUI
import SwiftData

struct MedicationListView: View {
    @Query(filter: #Predicate<Medication> { $0.active }, sort: \Medication.name) private var medications: [Medication]
    @Environment(\.modelContext) private var context
    @State private var showAdd = false

    private var grouped: [(MedicationType, [Medication])] {
        MedicationType.allCases.compactMap { type in
            let meds = medications.filter { $0.type == type }
            return meds.isEmpty ? nil : (type, meds)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(grouped, id: \.0) { type, meds in
                    Section {
                        ForEach(meds) { med in
                            NavigationLink(destination: MedicationDetailView(medication: med)) {
                                HStack {
                                    Image(systemName: type.systemImage).foregroundStyle(type.color)
                                    VStack(alignment: .leading) {
                                        Text(med.name).font(.headline)
                                        if !med.dose.isEmpty {
                                            Text(med.dose).font(.caption).foregroundStyle(.secondary)
                                        }
                                        if let schedule = med.schedule {
                                            Text(schedule.frequency.rawValue).font(.caption2).foregroundStyle(.tertiary)
                                        }
                                    }
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button("Archive", role: .destructive) { med.active = false }
                            }
                        }
                    } header: {
                        Label(type.rawValue, systemImage: type.systemImage).foregroundStyle(type.color)
                    }
                }
            }
            .navigationTitle("Medications")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) {
                MedicationFormView()
            }
        }
    }
}
