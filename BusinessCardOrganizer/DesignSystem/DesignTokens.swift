import SwiftUI

// MARK: - Design Tokens - Premium Utilitarian Minimalism
// Reference: "minimalist-ui" skill from installed skills catalog

public enum DesignTokens {
    // Canvas / Background
    public static let canvas = Color(.systemBackground)
    public static let canvasDisabled = Color(.secondarySystemBackground)
    public static let canvasLowEmphasis = Color(.tertiarySystemBackground)

    // Primary Surface
    public static let surface = Color(.systemBackground)
    public static let surfaceDisabled = Color(.secondarySystemBackground)

    // Structural borders/dividers
    public static let separator = Color(.separator)
    public static let lowEmphasis = Color(red: 0.91, green: 0.91, blue: 0.91)

    // Label colors - following anti-ai-slop guidelines (no Inter/Roboto/OpenSans)
    public static let labelPrimary = Color(.label)
    public static let labelSecondary = Color(.secondaryLabel)
    public static let labelTertiary = Color(.tertiaryLabel)

    // Accent colors - desaturated pastels for tags and accents
    public static let accentPrimary = Color(.systemBlue)
    public static let accentSuccess = Color(.systemGreen)
    public static let accentWarning = Color(.systemOrange)
    public static let accentDestructive = Color(.systemRed)

    // Background alternatives for sections/variants
    public static let secondaryBackground = Color(.secondarySystemBackground)
    public static let tertiaryBackground = Color(.tertiarySystemBackground)

    // MARK: - Spacing Scale
    /// Consistent spacing scale following anti-ai-slop guidelines
    public enum Spacing: CGFloat, CaseIterable {
        case xs = 4
        case sm = 8
        case md = 16
        case lg = 24
        case xl = 32
        case xxl = 48

        public var value: CGFloat { rawValue }
    }

    // MARK: - Corner Radius
    public enum Radius: CGFloat, CaseIterable {
        case sm = 6
        case md = 8
        case lg = 12
        case xl = 16
        case pill = 9999  // For pill-shaped elements

        public var value: CGFloat { rawValue }
    }

    // MARK: - Typography Architecture
    // SF Pro system fonts, no banned typefaces
    public enum TextStyle {
        // H1 - Hero headings
        public static let h1 = Font.system(size: 34, weight: .bold, design: .default)
        // H2 - Section headings
        public static let h2 = Font.system(size: 28, weight: .semibold, design: .default)
        // H3 - Subsection headings
        public static let h3 = Font.system(size: 22, weight: .semibold, design: .default)
        // Body - Main text
        public static let body = Font.system(size: 17, weight: .regular, design: .default)
        // Caption - Secondary text
        public static let caption = Font.system(size: 12, weight: .medium, design: .default)
        // Caption2 - Smaller auxiliary text
        public static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
        // Label - Button/control labels
        public static let label = Font.system(size: 13, weight: .medium, design: .default)
        // Footnote - Tiny text
        public static let footnote = Font.system(size: 11, weight: .regular, design: .default)
    }

    // MARK: - Motion / Animation
    public enum AnimationTime: TimeInterval {
        case fast = 0.15
        case medium = 0.25
        case slow = 0.4
        case mediumSpring = 0.35
    }

    // MARK: - Shadow Styles (subtle, never heavy)
    public enum Shadow {
        case none
        case sm(radius: CGFloat = 4, x: CGFloat = 0, y: CGFloat = 2, color: Color = .black.opacity(0.08))
        case lg(radius: CGFloat = 8, x: CGFloat = 0, y: CGFloat = 4, color: Color = .black.opacity(0.12))

        public var uiColor: Color {
            switch self {
            case .none:
                return Color.clear
            case .sm(_, _, _, let color), .lg(_, _, _, let color):
                return color
            }
        }
    }

    // MARK: - Feature Flags / States
    public enum UIState {
        case idle
        case loading
        case loaded
        case error(String)
        case empty
        case skeleton
    }

    // MARK: - Layout Margins per Screen Type
    public enum LayoutMargins {
        case `default`
        case compact
        case expanded

        public var horizontal: CGFloat {
            switch self {
            case .default: return Spacing.lg.value
            case .compact: return Spacing.md.value
            case .expanded: return Spacing.xxl.value
            }
        }

        public var vertical: CGFloat {
            switch self {
            case .default: return Spacing.xl.value
            case .compact: return Spacing.md.value
            case .expanded: return Spacing.xxl.value
            }
        }
    }
}

// MARK: - Top-Level Typealiases for Backward Compatibility
public typealias Spacing = DesignTokens.Spacing
public typealias Radius = DesignTokens.Radius
public typealias TextStyle = DesignTokens.TextStyle
public typealias AnimationTime = DesignTokens.AnimationTime
public typealias Shadow = DesignTokens.Shadow
public typealias UIState = DesignTokens.UIState
public typealias LayoutMargins = DesignTokens.LayoutMargins