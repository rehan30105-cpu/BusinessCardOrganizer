import SwiftUI
import Combine

// MARK: - ContactListViewModel
// ViewModel for the contact list screen
// Provides search, filtering, and contact management operations
// Follows MVVM pattern with @Observable for SwiftUI integration

@MainActor
@Observable
class ContactListViewModel {
    // MARK: - Properties
    var contacts: [Contact] = []
    var originalContacts: [Contact] = []  // For reset/filter reset
    var isLoading: Bool = false
    var errorMessage: String?
    var searchText: String = ""
    var selectedTag: ContactTag?
    var selectedFavoriteOnly: Bool = false
    var showsEmptyState: Bool {
        filteredContacts.isEmpty && !isLoading
    }

    // Dependencies
    var contactService: ContactServiceProtocol?
    var authenticationService: AuthenticationServiceProtocol?

    // Private cancellables
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init() {}

    // MARK: - Computed Properties

    // Filtered contacts based on search and tag filters
    var filteredContacts: [Contact] {
        var result = originalContacts

        // Apply favorite filter
        if selectedFavoriteOnly {
            result = result.filter { $0.isFavorite }
        }

        // Apply tag filter
        if let tag = selectedTag {
            result = result.filter { tagsContains(tag, in: $0.tags) }
        }

        // Apply search text filter
        if !searchText.isEmpty {
            result = result.filter { contact in
                contact.searchableText.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    // Tag count for a contact
    var tagFilterText: String {
        guard let tag = selectedTag else { return "" }
        return "Filter: \(tag.displayName)"
    }

    // Search placeholder text
    var searchPlaceholder: String {
        "Search names, companies, phones..."
    }

    var toolbarTrailingItems: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: DesignTokens.Spacing.sm.value) {
                if selectedFavoriteOnly {
                    Button("All") {
                        selectedFavoriteOnly = false
                    }
                    .font(DesignTokens.TextStyle.caption)
                    .foregroundColor(selectedFavoriteOnly ? DesignTokens.accentPrimary : DesignTokens.labelSecondary)
                }

                if !selectedFavoriteOnly && selectedTag == nil {
                    Button("Tags") { /* tag filter action */ }
                        .font(DesignTokens.TextStyle.caption)
                        .foregroundColor(DesignTokens.labelSecondary)
                }
            }
        }
    }

    // MARK: - Actions

    // Load contacts from service
    func loadContacts() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            originalContacts = try await contactService?.fetchContacts() ?? []
            contacts = originalContacts
            // Remove any existing tag/favorite filters on fresh load
            selectedTag = nil
            selectedFavoriteOnly = false
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // Add a new contact
    func addContact(_ contact: Contact) async {
        var updatedContacts = originalContacts
        updatedContacts.append(contact)
        originalContacts = updatedContacts
        contacts = updatedContacts
        // Keep search state, but reset tag filters
        selectedTag = nil
    }

    // Remove a contact
    func removeContact(_ contact: Contact) async {
        var updatedContacts = originalContacts
        updatedContacts.removeAll { $0.id == contact.id }
        originalContacts = updatedContacts
        contacts = updatedContacts
    }

    // Toggle favorite for a contact
    func toggleFavorite(_ contact: Contact) async {
        var updatedContacts = originalContacts
        if let index = updatedContacts.firstIndex(where: { $0.id == contact.id }) {
            updatedContacts[index].isFavorite.toggle()
        }
        originalContacts = updatedContacts
        contacts = updatedContacts
    }

    // Set tag filter
    func setTagFilter(_ tag: ContactTag?) {
        selectedTag = tag
        // When tag filter is set, clear favorite-only filter
        if selectedFavoriteOnly && selectedTag != nil {
            selectedFavoriteOnly = false
        }
    }

    // Toggle favorite-only filter
    func setFavoriteFilter(_ isOn: Bool) {
        selectedFavoriteOnly = isOn
        if isOn {
            selectedTag = nil
        }
    }

    // Refresh data
    func refresh() async {
        await loadContacts()
    }

    // Helper: check if contact has a specific tag
    private func tagsContains(_ tag: ContactTag, in contact: Contact) -> Bool {
        contact.tags.contains(tag)
    }
}
