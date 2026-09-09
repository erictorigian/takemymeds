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
                    Button("Close This Bottle") { closeCurrentBottle(current) }
                        .foregroundStyle(.red)
                }
            } else {
                Section {
                    Button { showOpenBottle = true } label: {
                        Label("Open New Bottle", systemImage: "plus.circle.fill")
                    }
                }
            }

            let history = sortedBottles.filter { !$0.isCurrent }
            if !history.isEmpty {
                Section("Bottle History") {
                    ForEach(history) { bottle in
                        BottleRow(bottle: bottle)
                    }
                }
            }
        }
        .navigationTitle("Bottles: \(medication.name)")
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

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if let lot = bottle.lotNumber, !lot.isEmpty {
                    Text("Lot: \(lot)").font(.headline)
                } else {
                    Text("No Lot #").font(.headline).foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(bottle.dosesTaken)/\(bottle.totalDoses) doses")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let opened = bottle.openedAt {
                Text("Opened: \(opened.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption).foregroundStyle(.secondary)
            }

            if let closed = bottle.closedAt {
                Text("Closed: \(closed.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption).foregroundStyle(.tertiary)
            } else if bottle.isCurrent {
                Text("Age: \(bottle.ageInDays) days").font(.caption).foregroundStyle(.secondary)
            }

            if let exp = bottle.expiresAt {
                Text("Expires: \(exp.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption).foregroundStyle(bottle.isExpiredByDate ? .red : .secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
