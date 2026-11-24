import Foundation

// MARK: - AuthenticationError
public enum AuthenticationError: LocalizedError {
    case failed
    case cancelled
    case biometryNotAvailable
    case biometryNotEnrolled
    case passcodeNotAvailable
    case passcodeIncorrect
    case tooManyFailedAttempts
    case sessionExpired
    case simulatorNotSupported
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .failed:
            return "Authentication failed"
        case .cancelled:
            return "Authentication cancelled"
        case .biometryNotAvailable:
            return "Biometry not available"
        case .biometryNotEnrolled:
            return "Biometry not enrolled"
        case .passcodeNotAvailable:
            return "Passcode not available"
        case .passcodeIncorrect:
            return "Passcode incorrect"
        case .tooManyFailedAttempts:
            return "Too many failed attempts. Try again later."
        case .sessionExpired:
            return "Session expired. Re-authenticate required."
        case .simulatorNotSupported:
            return "Biometry not supported on this device"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

// MARK: - AuthenticationServiceProtocol
// Protocol for authentication service dependency injection
// Clearly separates local app unlocking from cloud account authentication
@MainActor
public protocol AuthenticationServiceProtocol: Sendable {
    // Local app unlock - uses biometrics or passcode
    func authenticateLocal() async throws
    
    // Cloud account authentication - server-side credentials
    // This is separate from local app unlock and requires network
    func authenticateCloud() async throws
    
    // Passcode management
    func setupPasscode(_ passcode: String) throws
    func verifyPasscode(_ passcode: String) throws
    func resetPasscode() async throws
    
    // State management
    var authenticationState: AuthenticationState { get }
    var isPasscodeSet: Bool { get }
}
