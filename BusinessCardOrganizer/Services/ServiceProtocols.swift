import Foundation

// MARK: - ContactServiceProtocol
// Protocol for contact service dependency injection
@MainActor
public protocol ContactServiceProtocol {
    func fetchContacts() async throws -> [Contact]
}

// MARK: - AuthenticationServiceProtocol
// Protocol for authentication service dependency injection
@MainActor
public protocol AuthenticationServiceProtocol {
    func authenticate() async throws
}
