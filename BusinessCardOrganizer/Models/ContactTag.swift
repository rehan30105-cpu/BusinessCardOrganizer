import Foundation

// MARK: - ContactTag
// Enumeration of relationship tags for contacts
// Used for filtering, grouping, and display purposes
// Follows anti-ai-slop guidelines: no emoji, descriptive names only

public enum ContactTag: String, Codable, CaseIterable, Identifiable {
    // All available relationship tags
    case client
    case vendor
    case mentor
    case colleague
    case friend

    // Display name for UI
    public var displayName: String {
        switch self {
        case .client: return "Client"
        case .vendor: return "Vendor"
        case .mentor: return "Mentor"
        case .colleague: return "Colleague"
        case .friend: return "Friend"
        }
    }

    // System icon name (SF Symbols)
    public var iconName: String {
        switch self {
        case .client: return "building.columns"
        case .vendor: return "truck"
        case .mentor: return "bookmark"
        case .colleague: return "person.3"
        case .friend: return "heart"
        }
    }

    // Tag background color
    public var backgroundColor: Color {
        switch self {
        case .client: return Color(red: 0.95, green: 0.92, blue: 0.86)
        case .vendor: return Color(red: 0.91, green: 0.86, blue: 0.86)
        case .mentor: return Color(red: 0.86, green: 0.91, blue: 0.95)
        case .colleague: return Color(red: 0.86, green: 0.95, blue: 0.86)
        case .friend: return Color(red: 0.95, green: 0.86, blue: 0.92)
        }
    }

    // Tag text color
    public var textColor: Color {
        switch self {
        case .client: return Color(red: 0.6, green: 0.4, blue: 0.2)
        case .vendor: return Color(red: 0.7, green: 0.3, blue: 0.3)
        case .mentor: return Color(red: 0.2, green: 0.4, blue: 0.6)
        case .colleague: return Color(red: 0.2, green: 0.6, blue: 0.2)
        case .friend: return Color(red: 0.7, green: 0.2, blue: 0.4)
        }
    }

    // Identication - conform to Identifiable
    public var id: String { rawValue }

    // All available tags
    public static var allCases: [ContactTag] {
        [.client, .vendor, .mentor, .colleague, .friend]
    }
}

// MARK: - Preview Provider
struct ContactTag_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: DesignTokens.Spacing.sm.value) {
            ForEach(ContactTag.allCases) { tag in
                Text(tag.displayName)
                    .font(DesignTokens.TextStyle.caption)
                    .padding(.horizontal, DesignTokens.Spacing.sm.value)
                    .padding(.vertical, DesignTokens.Spacing.xs.value)
                    .background(tag.backgroundColor)
                    .foregroundColor(tag.textColor)
                    .cornerRadius(DesignTokens.Radius.pill.value)
                    .font(.caption2)
                    .fixedSize()
            }
        }
        .padding(DesignTokens.Spacing.lg.value)
        .background(DesignTokens.canvas)
    }
}