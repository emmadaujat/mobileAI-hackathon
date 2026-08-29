import SwiftUI

struct AppIconTileView: View {
    let tile: AppTile
    let isHighlighted: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(tile.tint.gradient)
                    .frame(width: 60, height: 60)
                    .shadow(color: isHighlighted ? tile.tint.opacity(0.9) : .clear, radius: 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white, lineWidth: isHighlighted ? 3 : 0)
                    )
                Image(systemName: tile.systemImage)
                    .foregroundStyle(.white)
                    .font(.system(size: 24, weight: .medium))
            }
            .scaleEffect(isHighlighted ? 1.12 : 1.0)

            Text(tile.displayName)
                .font(.caption2)
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(tile.displayName)
        .accessibilityHint(tile.explanation)
        .accessibilityAddTraits(.isButton)
    }
}
