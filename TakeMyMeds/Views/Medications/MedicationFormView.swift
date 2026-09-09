import SwiftUI
import SwiftData

struct MedicationFormView: View {
    var medication: Medication? = nil
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var type = MedicationType.vitamin
    @State private var dose = ""
    @State private var notes = ""
    @State private var frequency = ScheduleFrequency.daily
    @State private var times: [String] = ["08:00"]
    @State private var anchorDate = Date()

    var isEditing: Bool { medication != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Medication") {
                    TextField("Name", text: $name)
                    Picker("Type", selection: $type) {
                        ForEach(MedicationType.allCases, id: \.self) { t in
                            Label(t.rawValue, systemImage: t.systemImage).tag(t)
                        }
                    }
                    TextField("Dose (e.g. 500mg)", text: $dose)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Schedule") {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(ScheduleFrequency.allCases, id: \.self) { f in
                            Text(f.rawValue).tag(f)
                        }
                    }
                    .onChange(of: frequency) { _, new in times = new.defaultTimes }

                    if frequency != .asNeeded {
                        ForEach(times.indices, id: \.self) { i in
                            TimePicker(label: times.count > 1 ? "Time \(i + 1)" : "Time", timeString: $times[i])
                        }
                    }

                    if frequency == .biWeekly {
                        DatePicker("First Dose Date", selection: $anchorDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Medication" : "Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { loadExisting() }
        }
    }

    private func loadExisting() {
        guard let med = medication else { return }
        name = med.name
        type = med.type
        dose = med.dose
        notes = med.notes
        if let sched = med.schedule {
            frequency = sched.frequency
            times = sched.times
            anchorDate = sched.anchorDate ?? Date()
        }
    }

    private func save() {
        if let med = medication {
            med.name = name
            med.type = type
            med.dose = dose
            med.notes = notes
            if let sched = med.schedule {
                sched.frequency = frequency
                sched.times = times
                sched.anchorDate = frequency == .biWeekly ? anchorDate : nil
            }
        } else {
            let med = Medication(name: name, type: type, dose: dose, notes: notes)
            context.insert(med)
            let sched = MedSchedule(
                frequency: frequency,
                times: frequency == .asNeeded ? [] : times,
                anchorDate: frequency == .biWeekly ? anchorDate : nil
            )
            sched.medication = med
            med.schedule = sched
            context.insert(sched)
        }
        dismiss()
    }
}

struct TimePicker: View {
    let label: String
    @Binding var timeString: String

    private var binding: Binding<Date> {
        Binding(
            get: { ScheduleEngine.date(for: timeString, on: Date()) ?? Date() },
            set: { timeString = ScheduleEngine.timeString(from: $0) }
        )
    }

    var body: some View {
        DatePicker(label, selection: binding, displayedComponents: .hourAndMinute)
    }
}
