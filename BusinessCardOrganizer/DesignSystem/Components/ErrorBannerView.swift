import SwiftUI

// MARK: - ErrorBannerView
// A dismissable banner for displaying error messages with consistent styling
// Follows anti-ai-slop guidelines: no generic gradients, no neon colors

struct ErrorBannerView: View {
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    @Binding var isPresented: Bool

    init(
        title: String,
        message: String,
        actionTitle: String? = "Dismiss",
        action: (() -> Void)? = nil,
        isPresented: Binding<Bool>
    ) {
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
        _isPresented = isPresented
    }

    var body: some View {
        HStack(alignment: .center, spacing: DesignTokens.Spacing.md.value) {
            // Icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(DesignTokens.accentWarning)
                .frame(width: 24, height: 24)

            // Content
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs.value) {
                Text(title)
                    .font(DesignTokens.TextStyle.caption)
                    .foregroundColor(DesignTokens.labelPrimary)
                Text(message)
                    .font(DesignTokens.TextStyle.caption2)
                    .foregroundColor(DesignTokens.labelSecondary)
            }

            Spacer()

            // Action button
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle) {
                    action()
                    isPresented = false
                }
                .font(DesignTokens.TextStyle.caption2)
                .foregroundColor(DesignTokens.accentWarning)
            }
        }
        .padding(.vertical, DesignTokens.Spacing.sm.value)
        .padding(.horizontal, DesignTokens.Spacing.md.value)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md.value)
                .fill(DesignTokens.canvasLowEmphasis)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.md.value)
                        .stroke(DesignTokens.accentWarning.opacity(0.3), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(message)")
        .accessibilityAddTraits(.isAlert)
    }
}

// MARK: - Preview Provider
struct ErrorBannerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DesignTokens.Spacing.lg.value) {
            ErrorBannerView(
                title: "Network Error",
                message: "Could not connect to server. Please try again.",
                isPresented: .constant(true)
            )

            ErrorBannerView(
                title: "Saved",
                message: "Your contact has been saved successfully.",
                actionTitle: "OK",
                isPresented: .constant(true)
            )
        }
        .padding(DesignTokens.Spacing.xl.value)
        .background(DesignTokens.canvas)
    }
}