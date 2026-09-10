import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \DoseLog.takenAt, order: .reverse) private var logs: [DoseLog]
    @Environment(\.modelContext) private var context
    @State private var shareItems: [Any] = []
    @State private var showShare = false

    private var groupedLogs: [(Date, [DoseLog])] {
        let grouped = Dictionary(grouping: logs) { log in
            Calendar.current.startOfDay(for: log.takenAt)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    var body: some View {
        NavigationStack {
            Group {
                if logs.isEmpty {
                    ContentUnavailableView(
                        "No History Yet",
                        systemImage: "clock",
                        description: Text("Dose logs will appear here after you mark medications taken.")
                    )
                } else {
                    List {
                        ForEach(groupedLogs, id: \.0) { day, dayLogs in
                            Section(day.formatted(.dateTime.weekday(.wide).month().day())) {
                                ForEach(dayLogs) { log in
                                    LogRow(log: log)
                                }
                            }
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
        HStack(spacing: 12) {
            if let med = log.medication {
                MedTypeIcon(type: med.type, size: 32)
            } else {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(Color(.systemGray4))
                    .frame(width: 32, height: 32)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(log.medication?.name ?? "Unknown")
                    .font(.body.weight(.semibold))
                if let bottle = log.bottle, let bottleLot = bottle.lotNumber {
                    Text("Lot \(bottleLot)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if !log.notes.isEmpty {
                    Text(log.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(log.takenAt.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                StatusPill(taken: !log.skipped)
            }
        }
        .padding(.vertical, 2)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
