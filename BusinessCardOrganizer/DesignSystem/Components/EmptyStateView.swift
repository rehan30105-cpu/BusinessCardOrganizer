import SwiftUI

// MARK: - EmptyStateView
// Reference: anti-ai-slop-ui skill - avoids generic AI dashboard patterns
// Features a distinctive illustration area and descriptive text

struct EmptyStateView: View {
    let imageName: String
    let title: String
    let message: String
    let buttonTitle: String?
    let action: (() -> Void)?

    init(
        imageName: String,
        title: String,
        message: String,
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.imageName = imageName
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md.value) {
            // Icon area
            Image(systemName: imageName)
                .font(.system(size: 60, weight: .medium))
                .foregroundColor(DesignTokens.accentPrimary)
                .padding(.top, DesignTokens.Spacing.xl.value)

            // Title
            Text(title)
                .font(DesignTokens.TextStyle.h3)
                .foregroundColor(DesignTokens.labelPrimary)
                .multilineTextAlignment(.center)

            // Message
            Text(message)
                .font(DesignTokens.TextStyle.body)
                .foregroundColor(DesignTokens.labelSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignTokens.Spacing.lg.value)
                .fixedSize(horizontal: false, vertical: true)

            // Action button if provided
            if let buttonTitle = buttonTitle, let action = action {
                Button(action: action) {
                    Text(buttonTitle)
                        .font(DesignTokens.TextStyle.label)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignTokens.Spacing.md.value)
                        .background(DesignTokens.accentPrimary)
                        .cornerRadius(DesignTokens.Radius.md.value)
                        .shadow(color: DesignTokens.accentPrimary.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .padding(.top, DesignTokens.Spacing.xl.value)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.canvas)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(message)")
    }
}

// MARK: - Preview Provider
struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(
            imageName: "card",
            title: "No Contacts",
            message: "Add your first business card to get started.",
            buttonTitle: "Add Contact",
            action: {}
        )
        .previewLayout(.sizeThatFits)
        .padding(DesignTokens.Spacing.xxl.value)
        .background(DesignTokens.canvas)
    }
}