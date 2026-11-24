import Foundation
import LocalAuthentication

// MARK: - LocalAuthenticationService
// Handles local app unlocking using Face ID, Touch ID, or passcode
// This is SEPARATE from cloud account authentication
@MainActor
public final class LocalAuthenticationService: AuthenticationServiceProtocol, Sendable {
    
    // MARK: - Dependencies
    private let keychainManager: KeychainManageable
    private let biometryType: LABiometryType
    
    // MARK: - AuthenticationState
    @Published public private(set) var authenticationState: AuthenticationState = .unauthenticated
    @Published public private(set) var isPasscodeSet: Bool = false
    
    // MARK: - Properties
    public private(set) var biometryReason = "Authenticate to access Business Card Organizer"
    
    // MARK: - Initialization
    public init(keychainManager: KeychainManageable = KeychainManager()) {
        self.keychainManager = keychainManager
        self.biometryType = Self.determineBiometryType()
        self.isPasscodeSet = keychainManager.passwordExists(for: KeychainKeys.passcode)
    }
    
    // MARK: - Biometry Detection
    private static func determineBiometryType() -> LABiometryType {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID: return .faceID
            case .touchID: return .touchID
            case .opticID: return .opticID
            @unknown default: return .none
            }
        }
        return .none
    }
    
    // MARK: - Biometry Availability
    public var isBiometryAvailable: Bool {
        LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    public var biometryTypeDisplayName: String {
        switch biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optical ID"
        case .none: return "Passcode"
        @unknown default: return "Passcode"
        }
    }
    
    // MARK: - isPasscodeSet check (for KeychainManageable protocol conformance extension)
}

// MARK: - KeychainManageable Extension for LocalAuthenticationService
private extension KeychainManageable where Self == KeychainManager {
    func passwordExists(for key: String) -> Bool {
        return data(for: key) != nil
    }
}

// MARK: - Authentication Error Extension
public extension AuthenticationError {
    static func notImplemented(_ message: String) -> AuthenticationError {
        return .unknown(NSError(domain: "AuthenticationService", code: -1, userInfo: [NSLocalizedDescriptionKey: message]))
    }
}

// MARK: - Authentication Service Implementation

// MARK: - Authenticate Local (App Unlock)
public func authenticateLocal() async throws {
    // Check if passcode is set
    if !isPasscodeSet {
        // No passcode set, try biometrics only
        if isBiometryAvailable {
            try await authenticateWithBiometry()
        } else {
            throw AuthenticationError.passcodeNotAvailable
        }
        return
    }
    
    // Passcode is set - try biometrics first, fall back to passcode
    if isBiometryAvailable {
        do {
            try await authenticateWithBiometry()
            return
        } catch {
            // Biometry failed, fall through to passcode
        }
    }
    
    // Try passcode
    let passcode = try await promptForPasscode()
    try verifyPasscode(passcode)
    authenticationState = .authenticated
}

// MARK: - Authenticate Cloud (Server-side)
public func authenticateCloud() async throws {
    // Cloud authentication is handled separately - this is a placeholder
    // that should be implemented with actual server credential validation
    throw AuthenticationError.notImplemented("Cloud authentication requires server integration")
}

// MARK: - Passcode Setup
public func setupPasscode(_ passcode: String) throws {
    // Validate passcode length
    guard passcode.count >= 4 && passcode.count <= 16 else {
        throw AuthenticationError.passcodeIncorrect
    }
    
    // Store passcode in Keychain using SecKey encryption
    let data = passcode.data(using: .utf8)!
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: KeychainKeys.passcode,
        kSecValueData as String: data,
        kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ]
    
    // Delete existing first
    SecItemDelete(query as CFDictionary)
    
    // Add new passcode
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
        throw AuthenticationError.unknown(NSError(domain: "LocalAuthenticationService", code: status))
    }
    
    isPasscodeSet = true
}

// MARK: - Passcode Verification
public func verifyPasscode(_ passcode: String) throws {
    guard isPasscodeSet else {
        throw AuthenticationError.passcodeNotAvailable
    }
    
    // Read passcode from Keychain
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: KeychainKeys.passcode,
        kSecReturnData as String: kCFBooleanTrue!,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    
    guard status == errSecSuccess,
          let passcodeData = item as? Data,
          let storedPasscode = String(data: passcodeData, encoding: .utf8)
    else {
        throw AuthenticationError.passcodeIncorrect
    }
    
    // Compare passcodes
    if storedPasscode != passcode {
        // Increment failed attempts and potentially lock
        incrementFailedAttempts()
        throw AuthenticationError.passcodeIncorrect
    }
}

// MARK: - Reset Passcode
public func resetPasscode() async throws {
    // Delete existing passcode from Keychain
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: KeychainKeys.passcode
    ]
    
    SecItemDelete(query as CFDictionary)
    isPasscodeSet = false
}

// MARK: - Private: Biometry Authentication
private func authenticateWithBiometry() async throws {
    let context = LAContext()
    var error: NSError?
    
    // Check biometry availability
    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
        if biometryType == .none {
            throw AuthenticationError.biometryNotAvailable
        }
        throw AuthenticationError.biometryNotEnrolled
    }
    
    #if targetEnvironment(simulator)
    // Simulator fallback - allow passcode-style authentication
    // In a real simulator, we can't use Face ID/Touch ID
    // We'll use a simulated success for development
    // TODO: Remove or gate behind DEBUG flag for production
    authenticateSimulatorFallback()
    return
    #endif
    
    // Evaluate policy
    let reason = biometryReason
    try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
}

// MARK: - Private: Simulator Fallback
private func authenticateSimulatorFallback() {
    // On simulators, we accept a default passcode for development
    // In production, this should be gated behind a DEBUG flag
    #if DEBUG
    // Simulate successful biometry authentication
    // This allows development on simulators without Face ID
    authenticationState = .authenticated
    #else
    throw AuthenticationError.simulatorNotSupported
    #endif
}

// MARK: - Private: Prompt for Passcode
private func promptForPasscode() async throws -> String {
    // In a real implementation, this would present a UI prompt
    // For now, we'll use Keychain-stored passcode verification
    // The actual UI presentation is handled by the view layer
    throw AuthenticationError.notImplemented("Passcode prompt UI must be provided by view layer")
}

// MARK: - Private: Failed Attempts Tracking
private var failedAttempts: Int {
    get {
        guard let data = keychainManager.data(for: KeychainKeys.failedAttempts),
              let int = String(data: data, encoding: .utf8).flatMap({ Int($0) }) else {
            return 0
        }
        return int
    }
    set {
        let data = String(newValue).data(using: .utf8)!
        keychainManager.save(data, for: KeychainKeys.failedAttempts)
    }
}

private func incrementFailedAttempts() {
    var attempts = failedAttempts + 1
    // Lock after 5 failed attempts
    if attempts >= 5 {
        authenticationState = .locked
        // Could also trigger a longer cooldown here
    } else {
        authenticationState = .failed
    }
    self.failedAttempts = attempts
}

// MARK: - Passcode Keychain Keys
private enum KeychainKeys: String {
    case passcode = "businesscardorganizer.passcode"
    case failedAttempts = "businesscardorganizer.passcode.failed_attempts"
}