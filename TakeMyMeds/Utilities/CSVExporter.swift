import Foundation
import SwiftData

enum CSVExporter {
    static func exportDoseHistory(logs: [DoseLog]) -> URL? {
        var rows: [[String]] = [["Date", "Time", "Medication", "Type", "Dose", "Status", "Notes", "Bottle Lot"]]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short

        for log in logs.sorted(by: { $0.takenAt < $1.takenAt }) {
            let med = log.medication
            rows.append([
                dateFormatter.string(from: log.takenAt),
                timeFormatter.string(from: log.takenAt),
                med?.name ?? "",
                med?.type.rawValue ?? "",
                med?.dose ?? "",
                log.skipped ? "Skipped" : "Taken",
                log.notes,
                log.bottle.flatMap { $0.lotNumber } ?? ""
            ])
        }
        return writeCSV(rows: rows, filename: "dose_history")
    }

    static func exportBottleHistory(context: ModelContext) -> URL? {
        let descriptor = FetchDescriptor<InjectionBottle>()
        guard let bottles = try? context.fetch(descriptor) else { return nil }

        var rows: [[String]] = [["Medication", "Lot Number", "Opened", "Closed", "Total Doses", "Doses Used", "Doses Remaining", "Age (days)", "Expiry Date", "Max Open Days", "Notes"]]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short

        let sorted = bottles.sorted {
            ($0.openedAt ?? .distantPast) < ($1.openedAt ?? .distantPast)
        }

        for bottle in sorted {
            rows.append([
                bottle.medication?.name ?? "",
                bottle.lotNumber ?? "",
                bottle.openedAt.map { dateFormatter.string(from: $0) } ?? "",
                bottle.closedAt.map { dateFormatter.string(from: $0) } ?? "",
                "\(bottle.totalDoses)",
                "\(bottle.dosesTaken)",
                "\(bottle.dosesRemaining)",
                "\(bottle.ageInDays)",
                bottle.expiresAt.map { dateFormatter.string(from: $0) } ?? "",
                bottle.maxOpenDays.map { "\($0)" } ?? "",
                bottle.notes ?? ""
            ])
        }
        return writeCSV(rows: rows, filename: "bottle_history")
    }

    private static func writeCSV(rows: [[String]], filename: String) -> URL? {
        let csv = rows.map { $0.map(csvEscape).joined(separator: ",") }.joined(separator: "\n")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(filename).csv")
        try? csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private static func csvEscape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return value
    }
}
