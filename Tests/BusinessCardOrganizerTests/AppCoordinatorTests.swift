import XCTest
import SwiftUI
@testable import BusinessCardOrganizer

@MainActor
final class AppCoordinatorTests: XCTestCase {

    var dashboardViewModel: DashboardViewModel!
    var contactListViewModel: ContactListViewModel!
    var coordinator: AppCoordinator!

    override func setUp() {
        super.setUp()
        dashboardViewModel = DashboardViewModel()
        contactListViewModel = ContactListViewModel()
        coordinator = AppCoordinator(
            dashboardViewModel: dashboardViewModel,
            contactListViewModel: contactListViewModel
        )
    }

    override func tearDown() {
        coordinator = nil
        dashboardViewModel = nil
        contactListViewModel = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertTrue(coordinator.navigationPath.isEmpty)
        XCTAssertIdentical(coordinator.dashboardViewModel, dashboardViewModel)
        XCTAssertIdentical(coordinator.contactListViewModel, contactListViewModel)
    }

    func testNavigateAppendsDestination() {
        XCTAssertEqual(coordinator.navigationPath.count, 0)

        coordinator.navigate(to: .addContact)
        XCTAssertEqual(coordinator.navigationPath.count, 1)

        let contact = Contact(name: "Test User")
        coordinator.navigate(to: .detail(contact: contact))
        XCTAssertEqual(coordinator.navigationPath.count, 2)

        coordinator.navigate(to: .filters(tag: .mentor))
        XCTAssertEqual(coordinator.navigationPath.count, 3)
    }

    func testPopRemovesLastDestination() {
        coordinator.navigate(to: .addContact)
        coordinator.navigate(to: .filters(tag: nil))
        XCTAssertEqual(coordinator.navigationPath.count, 2)

        coordinator.pop()
        XCTAssertEqual(coordinator.navigationPath.count, 1)

        coordinator.pop()
        XCTAssertEqual(coordinator.navigationPath.count, 0)
    }

    func testPopOnEmptyPathDoesNotCrash() {
        XCTAssertTrue(coordinator.navigationPath.isEmpty)
        coordinator.pop()
        XCTAssertTrue(coordinator.navigationPath.isEmpty)
    }

    func testPopToRootResetsPath() {
        let contact = Contact(name: "Jane")
        coordinator.navigate(to: .addContact)
        coordinator.navigate(to: .detail(contact: contact))
        coordinator.navigate(to: .filters(tag: .client))
        XCTAssertEqual(coordinator.navigationPath.count, 3)

        coordinator.popToRoot()
        XCTAssertTrue(coordinator.navigationPath.isEmpty)
        XCTAssertEqual(coordinator.navigationPath.count, 0)
    }

    func testDestinationEqualityAndHashing() {
        let contact = Contact(name: "Alice")
        let dest1 = AppCoordinator.Destination.detail(contact: contact)
        let dest2 = AppCoordinator.Destination.detail(contact: contact)
        let dest3 = AppCoordinator.Destination.addContact
        let dest4 = AppCoordinator.Destination.filters(tag: .friend)

        XCTAssertEqual(dest1, dest2)
        XCTAssertNotEqual(dest1, dest3)
        XCTAssertNotEqual(dest3, dest4)

        var set = Set<AppCoordinator.Destination>()
        set.insert(dest1)
        set.insert(dest2)
        set.insert(dest3)
        set.insert(dest4)
        XCTAssertEqual(set.count, 3)
    }
}
