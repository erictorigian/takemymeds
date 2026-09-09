import SwiftUI

struct MedTypeIcon: View {
    let type: MedicationType
    var size: CGFloat = 32

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.225, style: .continuous)
            .fill(type.color.gradient)
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: type.systemImage)
                    .foregroundStyle(.white)
                    .font(.system(size: size * 0.48, weight: .semibold))
            }
    }
}

struct StatusPill: View {
    let taken: Bool

    var body: some View {
        Label(taken ? "Taken" : "Skipped",
              systemImage: taken ? "checkmark" : "minus")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(taken ? .green : .orange)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background((taken ? Color.green : Color.orange).opacity(0.12),
                        in: Capsule())
    }
}
