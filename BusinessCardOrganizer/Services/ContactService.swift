import Foundation

// MARK: - ContactService
// Handles local persistence of contacts using UserDefaults and JSON encoding
// Serves as the local data layer, complementing the cloud contact fetching
@MainActor
public final class ContactService {
    
    // MARK: - UserDefaults Keys
    private enum Keys: String {
        case contacts = "saved_contacts"
        case syncStatus = "sync_status"
        case lastSync = "last_sync_date"
    }
    
    // MARK: - Sync Status
    public enum SyncStatus: String, Codable {
        case notSynced
        case syncing
        case synced
        case error
    }
    
    // MARK: - Shared Instance
    public static let shared = ContactService()
    
    // MARK: - Private Initialization
    private init() {}
    
    // MARK: - Properties
    public private(set) var contacts: [Contact] = []
    public private(set) var syncStatus: SyncStatus = .notSynced
    public var lastSyncDate: Date?
    
    // MARK: - Initialization
    public func loadContacts() {
        guard let data = UserDefaults.standard.data(forKey: Keys.contacts.rawValue),
              let decoded = try? JSONDecoder().decode([Contact].self, from: data)
        else {
            contacts = []
            return
        }
        self.contacts = decoded
    }
    
    // MARK: - Save
    public func saveContacts() {
        let encoded = try? JSONEncoder().encode(contacts)
        UserDefaults.standard.set(encoded, forKey: Keys.contacts.rawValue)
    }
    
    // MARK: - Sync Status
    public func updateSyncStatus(_ status: SyncStatus) {
        syncStatus = status
        let encoded = try? JSONEncoder().encode(syncStatus)
        UserDefaults.standard.set(encoded, forKey: Keys.syncStatus.rawValue)
        
        if status == .synced {
            lastSyncDate = Date()
            let encodedDate = try? JSONEncoder().encode(lastSyncDate)
            UserDefaults.standard.set(encodedDate, forKey: Keys.lastSync.rawValue)
        }
    }
    
    // MARK: - Add Contact
    public mutating func addContact(_ contact: Contact) {
        contacts.append(contact)
        saveContacts()
        updateSyncStatus(.syncing)
    }
    
    // MARK: - Remove Contact
    public mutating func removeContact(_ contact: Contact) {
        contacts.removeAll { $0.id == contact.id }
        saveContacts()
        updateSyncStatus(.syncing)
    }
    
    // MARK: - Update Contact
    public mutating func updateContact(_ contact: Contact) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index] = contact
            saveContacts()
            updateSyncStatus(.syncing)
        }
    }
    
    // MARK: - Toggle Favorite
    public mutating func toggleFavorite(for contact: Contact) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index].isFavorite.toggle()
            contacts[index].updatedAt = Date()
            saveContacts()
            updateSyncStatus(.syncing)
        }
    }
    
    // MARK: - Load with Sync
    public func loadWithSync() async {
        updateSyncStatus(.syncing)
        loadContacts()
        updateSyncStatus(.synced)
    }

// MARK: - ContactServiceProtocol
// Protocol for contact service dependency injection
// Used for both local persistence and cloud fetching
public protocol ContactServiceProtocol: Sendable {
    func fetchContacts() async throws -> [Contact]
}