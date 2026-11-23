import Foundation
import SwiftUI

// MARK: - AuthenticationState
// State enum for tracking authentication status
// Used across the app to gate UI and manage auth flows
// Reference: LocalAuthentication + Keychain patterns

public enum AuthenticationState: String, Codable, Equatable {
    // Authentication states
    case unauthenticated   // User has not authenticated
    case authenticating    // Currently authenticating (biometrics/passcode)
    case authenticated     // Successfully authenticated
    case failed            // Authentication failed
    case locked            // Too many failed attempts, locked out
    case sessionExpired    // Session expired, re-auth required

    // Computed properties
    public var isAuthenticated: Bool {
        switch self {
        case .authenticated: return true
        default: return false
        }
    }

    public var isUnauthenticated: Bool {
        switch self {
        case .unauthenticated: return true
        default: return false
        }
    }

    public var showsBiometrics: Bool {
        switch self {
        case .unauthenticated, .failed, .locked: return true
        default: return false
        }
    }

    public var showsPasscode: Bool {
        switch self {
        case .unauthenticated, .failed, .locked: return true
        default: return false
        }
    }

    // Color associated with state (for UI)
    var uiColor: Color {
        switch self {
        case .authenticated: return DesignTokens.accentSuccess
        case .authenticating: return DesignTokens.accentPrimary
        case .failed: return DesignTokens.accentDestructive
        case .locked: return DesignTokens.accentWarning
        case .unauthenticated, .sessionExpired: return DesignTokens.labelTertiary
        }
    }

    var systemImage: String {
        switch self {
        case .authenticated: return "checkmark.shield"
        case .authenticating: return "ellipsis.shield"
        case .failed: return "xmark.shield"
        case .locked: return "lock.shield"
        case .unauthenticated: return "questionmark.shield"
        case .sessionExpired: return "clock.shield"
        }
    }

    // Haptic feedback type
    var hapticType: String {
        switch self {
        case .authenticated: "success"
        case .failed: "error"
        case .locked: "warning"
        default: "notification"
        }
    }

    // Equity: conformance for SwiftUI bindings and Swift Data
    public static func == (lhs: AuthenticationState, rhs: AuthenticationState) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

// MARK: - AuthenticationState+Extensions
public extension AuthenticationState {
    // Check if state requires re-authentication
    var requiresReauth: Bool {
        switch self {
        case .sessionExpired, .locked: return true
        default: return false
        }
    }

    // Friendly description for UI
    var friendlyDescription: String {
        switch self {
        case .authenticated: return "You're signed in"
        case .unauthenticated: return "Sign in to access your contacts"
        case .authenticating: return "Verifying identity..."
        case .failed: return "Authentication failed. Please try again."
        case .locked: return "Too many failed attempts. Try again later."
        case .sessionExpired: return "Your session has expired"
        }
    }
}

// MARK: - AuthenticationState+UI
extension AuthenticationState {
    // Background color for the state
    var backgroundColor: Color {
        switch self {
        case .authenticated: return DesignTokens.canvas.opacity(0.95)
        case .authenticating: return DesignTokens.canvas
        case .failed: return DesignTokens.canvasLowEmphasis
        case .locked: return DesignTokens.canvasLowEmphasis
        case .unauthenticated, .sessionExpired: return DesignTokens.canvas
        }
    }

    // Text color for the state
    var textColor: Color {
        switch self {
        case .authenticated: return DesignTokens.accentPrimary
        case .authenticating: return DesignTokens.accentPrimary
        case .failed: return DesignTokens.accentDestructive
        case .locked: return DesignTokens.accentWarning
        case .unauthenticated, .sessionExpired: return DesignTokens.labelPrimary
        }
    }
}