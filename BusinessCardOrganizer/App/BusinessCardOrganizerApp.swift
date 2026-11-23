import SwiftUI

// MARK: - BusinessCardOrganizerApp
// Application entry point
// - Uses XcodeGen for project generation
// - Portrait orientation only (iOS 17+)
// - MVVM architecture with dependency injection
// - No code signing required for simulator builds
// - Shared scheme for test target

@main
struct BusinessCardOrganizerApp: App {
    // MARK: - State Properties
    @State private var dashboardViewModel: DashboardViewModel
    @State private var contactListViewModel: ContactListViewModel
    @State private var coordinator: AppCoordinator

    // MARK: - Initialization
    init() {
        let dashboardVM = DashboardViewModel()
        let contactListVM = ContactListViewModel()
        _dashboardViewModel = State(initialValue: dashboardVM)
        _contactListViewModel = State(initialValue: contactListVM)
        _coordinator = State(initialValue: AppCoordinator(
            dashboardViewModel: dashboardVM,
            contactListViewModel: contactListVM
        ))
    }

    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
                .environment(dashboardViewModel)
                .environment(contactListViewModel)
                .environment(coordinator)
                .onAppear {
                    Task { await dashboardViewModel.loadContacts() }
                }
        }
    }
}
