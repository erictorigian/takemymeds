import SwiftUI
import SwiftData

struct BottleFormView: View {
    let medication: Medication
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var openedAt = Date()
    @State private var totalDoses = 10
    @State private var lotNumber = ""
    @State private var expiresAt = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var hasExpiry = true
    @State private var maxOpenDays = 28
    @State private var hasMaxOpenDays = true
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Bottle Info") {
                    TextField("Lot Number", text: $lotNumber)
                    Stepper("Total Doses: \(totalDoses)", value: $totalDoses, in: 1...500)
                    DatePicker("Opened Date", selection: $openedAt, displayedComponents: .date)
                }

                Section("Expiration") {
                    Toggle("Has Expiry Date", isOn: $hasExpiry)
                    if hasExpiry {
                        DatePicker("Expiry Date", selection: $expiresAt, displayedComponents: .date)
                    }
                    Toggle("Max Open Days", isOn: $hasMaxOpenDays)
                    if hasMaxOpenDays {
                        Stepper("Max Open: \(maxOpenDays) days", value: $maxOpenDays, in: 1...365)
                    }
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Open New Bottle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Open") { save() }
                }
            }
        }
    }

    private func save() {
        if let existing = medication.currentBottle {
            existing.isCurrent = false
            existing.closedAt = Date()
        }

        let bottle = InjectionBottle(
            medication: medication,
            openedAt: openedAt,
            totalDoses: totalDoses,
            lotNumber: lotNumber.isEmpty ? nil : lotNumber,
            expiresAt: hasExpiry ? expiresAt : nil,
            maxOpenDays: hasMaxOpenDays ? maxOpenDays : nil,
            notes: notes.isEmpty ? nil : notes
        )
        context.insert(bottle)
        medication.bottles.append(bottle)
        dismiss()
    }
}
