import SwiftUI

// MARK: - SectionHeaderView
// A reusable section header with title and optional trailing action
// Consistent typography and spacing following design tokens

struct SectionHeaderView: View {
    // MARK: - Properties
    let title: String
    let subtitle: String?
    let actionTitle: String?
    let action: (() -> Void)?
    var showsDivider: Bool

    // MARK: - Initialization
    init(
        title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        showsDivider: Bool = true
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
        self.showsDivider = showsDivider
    }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs.value) {
            // Title
            HStack {
                Text(title)
                    .font(DesignTokens.TextStyle.h3)
                    .foregroundColor(DesignTokens.labelPrimary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DesignTokens.TextStyle.caption)
                        .foregroundColor(DesignTokens.labelSecondary)
                }
            }

            if showsDivider {
                Divider()
                    .frame(height: 1)
                    .background(DesignTokens.lowEmphasis)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview Provider
struct SectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DesignTokens.Spacing.xl.value) {
            SectionHeaderView(title: "Contacts", subtitle: "24 people", showsDivider: true)
            SectionHeaderView(title: "Favorites", showsDivider: true)
            SectionHeaderView(title: "Archived", showsDivider: false)
        }
        .padding(DesignTokens.Spacing.lg.value)
        .background(DesignTokens.canvas)
    }
}

// MARK: - Preview Provider (with action)
struct SectionHeaderViewWithAction_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeaderView(
            title: "Contacts",
            actionTitle: "Edit",
            action: {},
            showsDivider: true
        )
        .padding(DesignTokens.Spacing.lg.value)
        .background(DesignTokens.canvas)
    }