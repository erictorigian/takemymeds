import Foundation

enum CSVExporter {
    static func exportDoseHistory(from medications: [Medication]) -> String {
        var rows: [[String]] = [["Date", "Time", "Medication", "Type", "Dose", "Status", "Notes", "Bottle Lot"]]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short

        let allLogs = medications.flatMap { med in
            med.doseLogs.map { (med, $0) }
        }.sorted { $0.1.takenAt < $1.1.takenAt }

        for (med, log) in allLogs {
            rows.append([
                dateFormatter.string(from: log.takenAt),
                timeFormatter.string(from: log.takenAt),
                med.name,
                med.type.rawValue,
                med.dose,
                log.skipped ? "Skipped" : "Taken",
                log.notes,
                log.bottle?.lotNumber ?? ""
            ])
        }
        return rows.map { $0.map(csvEscape).joined(separator: ",") }.joined(separator: "\n")
    }

    static func exportBottleHistory(from medications: [Medication]) -> String {
        var rows: [[String]] = [["Medication", "Lot Number", "Opened", "Closed", "Total Doses", "Doses Used", "Doses Remaining", "Age (days)", "Expiry Date", "Max Open Days", "Notes"]]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short

        let bottles = medications.flatMap { med in
            med.bottles.map { (med, $0) }
        }.sorted { $0.1.openedAt < $1.1.openedAt }

        for (med, bottle) in bottles {
            rows.append([
                med.name,
                bottle.lotNumber,
                dateFormatter.string(from: bottle.openedAt),
                bottle.closedAt.map { dateFormatter.string(from: $0) } ?? "",
                "\(bottle.totalDoses)",
                "\(bottle.dosesTaken)",
                "\(bottle.dosesRemaining)",
                "\(bottle.ageInDays)",
                bottle.expiresAt.map { dateFormatter.string(from: $0) } ?? "",
                bottle.maxOpenDays.map { "\($0)" } ?? "",
                bottle.notes
            ])
        }
        return rows.map { $0.map(csvEscape).joined(separator: ",") }.joined(separator: "\n")
    }

    private static func csvEscape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return value
    }
}
