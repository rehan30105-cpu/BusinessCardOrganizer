import SwiftUI
import Combine

// MARK: - DashboardViewModel
// ViewModel for the dashboard screen
// Observes contact data and provides statistics for display
// Follows MVVM pattern - pure Swift, no UI framework dependencies in the model

@MainActor
@Observable
class DashboardViewModel {
    // MARK: - Properties
    var authenticationState: AuthenticationState = .unauthenticated
    var contacts: [Contact] = []
    var favoriteCount: Int = 0
    var totalCount: Int = 0
    var isLoading: Bool = false
    var errorMessage: String?
    var showsEmptyState: Bool {
        contacts.isEmpty && !isLoading
    }

    // Dependencies (injected)
    var contactService: ContactServiceProtocol?
    var authenticationService: AuthenticationServiceProtocol?

    // Private cancellables for Combine
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init() {}

    // MARK: - Computed Properties
    var statsText: String {
        "\(totalCount) contacts\(favoriteCount > 0 ? ", \(favoriteCount) favorites" : "")"
    }

    // MARK: - Actions

    // Load contacts from service
    func loadContacts() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            contacts = try await contactService?.fetchContacts() ?? []
            totalCount = contacts.count
            favoriteCount = contacts.filter { $0.isFavorite }.count
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // Authenticate user
    func authenticate() async {
        guard authenticationState != .authenticating else { return }
        authenticationState = .authenticating

        do {
            try await authenticationService?.authenticate()
            authenticationState = .authenticated
        } catch {
            authenticationState = .failed
            errorMessage = error.localizedDescription
        }
    }

    // Logout user
    func logout() async {
        authenticationState = .unauthenticated
        contacts.removeAll()
        totalCount = 0
        favoriteCount = 0
    }

    // Refresh data
    func refresh() async {
        await loadContacts()
    }
}
