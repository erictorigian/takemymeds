import SwiftUI
import SwiftData

struct AsNeededRowView: View {
    let medication: Medication
    @State private var showSheet = false

    var body: some View {
        HStack {
            Image(systemName: medication.type.systemImage)
                .foregroundStyle(medication.type.color)
            VStack(alignment: .leading) {
                Text(medication.name).font(.headline)
                if !medication.dose.isEmpty {
                    Text(medication.dose).font(.caption).foregroundStyle(.secondary)
                }
                if let last = medication.lastTakenDate {
                    Text("Last taken: \(last.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption2).foregroundStyle(.tertiary)
                }
            }
            Spacer()
            Button { showSheet = true } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(medication.type.color)
            }
        }
        .sheet(isPresented: $showSheet) {
            QuickLogSheet(medication: medication)
        }
    }
}

struct QuickLogSheet: View {
    let medication: Medication
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var takenAt = Date()
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("When") {
                    DatePicker("Date & Time", selection: $takenAt, displayedComponents: [.date, .hourAndMinute])
                }
                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Log \(medication.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Log") {
                        let log = DoseLog(medication: medication, scheduledFor: nil, takenAt: takenAt, notes: notes)
                        context.insert(log)
                        dismiss()
                    }
                }
            }
        }
    }
}
