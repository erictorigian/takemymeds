import SwiftUI

struct DoseCardView: View {
    let dose: ScheduledDose
    let onTake: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: dose.medication.type.systemImage)
                    .foregroundStyle(dose.medication.type.color)
                VStack(alignment: .leading) {
                    Text(dose.medication.name).font(.headline)
                    if !dose.medication.dose.isEmpty {
                        Text(dose.medication.dose).font(.caption).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                statusBadge
            }

            Text(timeLabel).font(.caption).foregroundStyle(.secondary)

            if dose.isPending || dose.isOverdue {
                HStack {
                    Button("Mark Taken") { onTake() }
                        .buttonStyle(.borderedProminent)
                        .tint(dose.medication.type.color)
                    Button("Skip") { onSkip() }
                        .buttonStyle(.bordered)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var statusBadge: some View {
        if dose.isTaken {
            Label("Taken", systemImage: "checkmark.circle.fill")
                .font(.caption).foregroundStyle(.green)
        } else if dose.isSkipped {
            Label("Skipped", systemImage: "minus.circle.fill")
                .font(.caption).foregroundStyle(.orange)
        } else if dose.isOverdue {
            Label("Overdue", systemImage: "exclamationmark.circle.fill")
                .font(.caption).foregroundStyle(.red)
        }
    }

    private var timeLabel: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: dose.scheduledFor)
    }
}
