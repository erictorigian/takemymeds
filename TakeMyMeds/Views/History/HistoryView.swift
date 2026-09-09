import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \DoseLog.takenAt, order: .reverse) private var logs: [DoseLog]
    @Environment(\.modelContext) private var context
    @State private var exportType: ExportType? = nil
    @State private var shareItems: [Any] = []
    @State private var showShare = false

    enum ExportType: Identifiable {
        case doses, bottles
        var id: Self { self }
    }

    private var groupedLogs: [(String, [DoseLog])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        let grouped = Dictionary(grouping: logs) { log in
            formatter.string(from: log.takenAt)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedLogs, id: \.0) { day, dayLogs in
                    Section(day) {
                        ForEach(dayLogs) { log in
                            LogRow(log: log)
                        }
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            if let url = CSVExporter.exportDoseHistory(logs: logs) {
                                shareItems = [url]
                                showShare = true
                            }
                        } label: {
                            Label("Export Dose History", systemImage: "tablecells")
                        }
                        Button {
                            if let url = CSVExporter.exportBottleHistory(context: context) {
                                shareItems = [url]
                                showShare = true
                            }
                        } label: {
                            Label("Export Bottle History", systemImage: "cross.vial")
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showShare) {
                ShareSheet(items: shareItems)
            }
        }
    }
}

struct LogRow: View {
    let log: DoseLog

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(log.medication?.name ?? "Unknown").font(.headline)
                if let med = log.medication {
                    Text(med.type.rawValue).font(.caption).foregroundStyle(.secondary)
                }
                if let bottleLot = log.bottle?.lotNumber {
                    Text("Lot: \(bottleLot)").font(.caption2).foregroundStyle(.tertiary)
                }
                if let notes = log.notes, !notes.isEmpty {
                    Text(notes).font(.caption).foregroundStyle(.secondary).italic()
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(log.takenAt, style: .time).font(.caption)
                if log.skipped {
                    Label("Skipped", systemImage: "minus.circle.fill")
                        .font(.caption2).foregroundStyle(.orange)
                } else {
                    Label("Taken", systemImage: "checkmark.circle.fill")
                        .font(.caption2).foregroundStyle(.green)
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
