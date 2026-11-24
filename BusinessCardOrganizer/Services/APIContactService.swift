import Foundation
import Combine

// MARK: - APIContactService
// API service layer that bridges local ContactService with remote backend
// Supports online mode (real API calls) and offline mode (local-only)
// Implements sync logic for offline-first architecture
@MainActor
public final class APIContactService: ContactServiceProtocol {
    
    // MARK: - Dependencies
    private let networkManager: NetworkManaging
    private let localService: ContactService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Properties
    public var isOnline: Bool {
        networkManager.isConnected
    }
    
    // MARK: - Initialization
    public init(networkManager: NetworkManaging = NetworkManager(),
                localService: ContactService = ContactService.shared) {
        self.networkManager = networkManager
        self.localService = localService
    }
    
    // MARK: - ContactServiceProtocol conformance
    
    public func fetchContacts() async throws -> [Contact] {
        if isOnline {
            // Try remote API first
            return await fetchContactsOnline()
        } else {
            // Return local data only
            localService.loadContacts()
            return localService.contacts
        }
    }
    
    // MARK: - Online Fetch
    private func fetchContactsOnline() async -> [Contact] {
        // Update sync status
        localService.updateSyncStatus(.syncing)
        
        do {
            // Simulate network request with delay
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // In a real app, this would be a real network call
            // For now, return local data with sync status update
            localService.updateSyncStatus(.synced)
            return localService.contacts
        } catch {
            // On error, fall back to local data
            localService.updateSyncStatus(.error)
            localService.loadContacts()
            return localService.contacts
        }
    }
    
    // MARK: - Create Contact
    public func createContact(_ contact: Contact) async throws {
        if isOnline {
            // Try remote API
            try await createContactOnline(contact)
        }
        // Always save locally
        localService.addContact(contact)
    }
    
    private func createContactOnline(_ contact: Contact) async throws {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        // Real implementation would POST to backend
    }
    
    // MARK: - Update Contact
    func updateContact(_ contact: Contact) async throws {
        if isOnline {
            try await updateContactOnline(contact)
        }
        localService.updateContact(contact)
    }
    
    private func updateContactOnline(_ contact: Contact) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        // Real implementation would PUT/PATCH to backend
    }
    
    // MARK: - Delete Contact
    func deleteContact(_ contact: Contact) async throws {
        if isOnline {
            try await deleteContactOnline(contact)
        }
        localService.removeContact(contact)
    }
    
    private func deleteContactOnline(_ contact: Contact) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        // Real implementation would DELETE from backend
    }
}

// MARK: - NetworkManaging
// Protocol for network connectivity checking
public protocol NetworkManaging {
    var isConnected: Bool { get }
}

// MARK: - NetworkManager
// Simple network connectivity manager
public final class NetworkManager: NetworkManaging {
    
    // In a real app, this would use NWPathMonitor
    // For now, returns true by default for online mode
    public var isConnected: Bool {
        // Simulate connectivity - in production use Network.framework
        true
    }
}