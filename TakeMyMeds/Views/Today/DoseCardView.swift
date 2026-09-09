import SwiftUI

struct DoseCardView: View {
    let dose: ScheduledDose
    let onTake: () -> Void
    let onSkip: () -> Void

    @State private var tookDose = false

    var body: some View {
        HStack(spacing: 14) {
            MedTypeIcon(type: dose.medication.type, size: 42)

            VStack(alignment: .leading, spacing: 3) {
                Text(dose.medication.name)
                    .font(.body.weight(.semibold))
                if !dose.medication.dose.isEmpty {
                    Text(dose.medication.dose)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text(dose.scheduledFor.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(dose.isOverdue ? .red : .secondary)
                    .monospacedDigit()
            }

            Spacer()

            completionControl
        }
        .padding(.vertical, 4)
        .sensoryFeedback(.success, trigger: tookDose)
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            if dose.isPending || dose.isOverdue {
                Button {
                    tookDose.toggle()
                    onTake()
                } label: {
                    Label("Take", systemImage: "checkmark")
                }
                .tint(.green)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if dose.isPending || dose.isOverdue {
                Button { onSkip() } label: {
                    Label("Skip", systemImage: "arrow.forward")
                }
                .tint(.orange)
            }
        }
    }

    @ViewBuilder
    private var completionControl: some View {
        if dose.isTaken {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.title2)
        } else if dose.isSkipped {
            Image(systemName: "minus.circle.fill")
                .foregroundStyle(.orange)
                .font(.title2)
        } else {
            Button {
                tookDose.toggle()
                onTake()
            } label: {
                Image(systemName: dose.isOverdue ? "exclamationmark.circle.fill" : "circle")
                    .foregroundStyle(dose.isOverdue ? Color.red : Color(.systemGray3))
                    .font(.title2)
            }
            .buttonStyle(.plain)
        }
    }
}
