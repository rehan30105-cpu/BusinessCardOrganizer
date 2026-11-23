import SwiftUI

// MARK: - FavoriteButton
// A tappable star button for marking contacts as favorites
// Uses SF Symbols for distinctive icons (no emoji)
// Supports selected/unselected states with animation

struct FavoriteButton: View {
    // MARK: - Properties
    @Binding var isFavorite: Bool
    let action: (() -> Void)?
    var size: CGFloat

    // MARK: - Initialization
    init(
        isFavorite: Binding<Bool>,
        action: (() -> Void)? = nil,
        size: CGFloat = 24
    ) {
        self._isFavorite = isFavorite
        self.action = action
        self.size = size
    }

    // MARK: - Body
    var body: some View {
        Button(action: {
            isFavorite.toggle()
            action?()
        }) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .font(.system(size: size, weight: .regular))
                .foregroundColor(isFavorite ? DesignTokens.accentPrimary : DesignTokens.labelTertiary)
                .scaleEffect(isFavorite ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isFavorite)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorite ? "Favorite" : "Not favorite")
        .accessibilityHint("Double-tap to toggle favorite status")
    }
}

// MARK: - Preview Provider
struct FavoriteButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DesignTokens.Spacing.md.value) {
            FavoriteButton(isFavorite: .constant(true))
            FavoriteButton(isFavorite: .constant(false))
        }
        .padding(DesignTokens.Spacing.lg.value)
        .background(DesignTokens.canvas)
    }
}

// MARK: - Extension for Convenience
extension View {
    func favoriteButton(isFavorite: Binding<Bool>, action: (() -> Void)? = nil) -> some View {
        FavoriteButton(isFavorite: isFavorite, action: action)
    }
}