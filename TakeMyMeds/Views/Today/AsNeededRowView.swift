import SwiftUI
import SwiftData

struct AsNeededRowView: View {
    let medication: Medication
    @State private var showSheet = false

    var body: some View {
        HStack(spacing: 14) {
            MedTypeIcon(type: medication.type, size: 38)

            VStack(alignment: .leading, spacing: 3) {
                Text(medication.name)
                    .font(.body.weight(.semibold))
                if !medication.dose.isEmpty {
                    Text(medication.dose)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if let last = medication.lastTakenDate {
                    Text("Last: \(last.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }

            Spacer()

            Button {
                showSheet = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(medication.type.color)
                    .font(.title2)
            }
            .buttonStyle(.plain)
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
            .navigationTitle(medication.name)
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
