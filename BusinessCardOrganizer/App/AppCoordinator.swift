import SwiftUI

@MainActor
@Observable
final class AppCoordinator {

    // MARK: - Navigation State

    var navigationPath = NavigationPath()

    // MARK: - Dependencies

    let dashboardViewModel: DashboardViewModel
    let contactListViewModel: ContactListViewModel

    // MARK: - Initialization

    init(
        dashboardViewModel: DashboardViewModel,
        contactListViewModel: ContactListViewModel
    ) {
        self.dashboardViewModel = dashboardViewModel
        self.contactListViewModel = contactListViewModel
    }

    // MARK: - Navigation Actions

    func navigate(to destination: Destination) {
        navigationPath.append(destination)
    }

    func pop() {
        guard !navigationPath.isEmpty else {
            return
        }

        navigationPath.removeLast()
    }

    func popToRoot() {
        navigationPath = NavigationPath()
    }

    // MARK: - Navigation Destinations

    enum Destination: Hashable {
        case detail(contact: Contact)
        case addContact
        case filters(tag: ContactTag?)
    }
}
