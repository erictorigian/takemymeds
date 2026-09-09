import SwiftUI
import SwiftData

struct BottleManagerView: View {
    let medication: Medication
    @Environment(\.modelContext) private var context
    @State private var showOpenBottle = false

    private var sortedBottles: [InjectionBottle] {
        medication.bottles.sorted { ($0.openedAt ?? .distantPast) > ($1.openedAt ?? .distantPast) }
    }

    var body: some View {
        List {
            if let current = medication.currentBottle {
                Section("Active Bottle") {
                    BottleRow(bottle: current)

                    if current.isExpired {
                        Label("Bottle Expired", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    } else if let days = current.daysUntilExpiry, days <= 7 {
                        Label("Expires in \(days) days", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                    }

                    Button(role: .destructive) {
                        closeCurrentBottle(current)
                    } label: {
                        Label("Close This Bottle", systemImage: "xmark.circle")
                    }
                }
            } else {
                Section {
                    Button {
                        showOpenBottle = true
                    } label: {
                        Label("Open New Bottle", systemImage: "plus.circle.fill")
                            .foregroundStyle(medication.type.color)
                    }
                } footer: {
                    Text("You must open a bottle before logging injectable doses.")
                }
            }

            let history = sortedBottles.filter { !$0.isCurrent }
            if !history.isEmpty {
                Section("History") {
                    ForEach(history) { bottle in
                        BottleRow(bottle: bottle)
                    }
                }
            }
        }
        .navigationTitle("Bottles")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if medication.currentBottle == nil {
                ToolbarItem(placement: .primaryAction) {
                    Button { showOpenBottle = true } label: { Image(systemName: "plus") }
                }
            }
        }
        .sheet(isPresented: $showOpenBottle) {
            BottleFormView(medication: medication)
        }
    }

    private func closeCurrentBottle(_ bottle: InjectionBottle) {
        bottle.closedAt = Date()
        bottle.isCurrent = false
    }
}

struct BottleRow: View {
    let bottle: InjectionBottle

    private var fillFraction: Double {
        guard bottle.totalDoses > 0 else { return 0 }
        return Double(bottle.dosesRemaining) / Double(bottle.totalDoses)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                if let lot = bottle.lotNumber, !lot.isEmpty {
                    Text("Lot \(lot)").font(.headline)
                } else {
                    Text("No Lot #").font(.headline).foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(bottle.dosesRemaining) of \(bottle.totalDoses) remaining")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            if bottle.isCurrent {
                ProgressView(value: fillFraction)
                    .tint(fillFraction <= 0.2 ? .red : fillFraction <= 0.4 ? .orange : .green)
                    .animation(.easeInOut, value: fillFraction)
            }

            HStack(spacing: 16) {
                if let opened = bottle.openedAt {
                    Label(opened.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if bottle.isCurrent {
                    Label("\(bottle.ageInDays)d open", systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let closed = bottle.closedAt {
                    Label(closed.formatted(date: .abbreviated, time: .omitted), systemImage: "xmark.circle")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            if let exp = bottle.expiresAt {
                Label(exp.formatted(date: .abbreviated, time: .omitted), systemImage: "exclamationmark.circle")
                    .font(.caption)
                    .foregroundStyle(bottle.isExpiredByDate ? .red : .secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
