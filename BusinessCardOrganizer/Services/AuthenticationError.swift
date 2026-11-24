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
