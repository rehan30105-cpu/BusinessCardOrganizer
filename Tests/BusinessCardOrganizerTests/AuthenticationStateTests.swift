import XCTest
import SwiftUI
@testable import BusinessCardOrganizer

final class AuthenticationStateTests: XCTestCase {

    func testIsAuthenticated() {
        XCTAssertTrue(AuthenticationState.authenticated.isAuthenticated)
        XCTAssertFalse(AuthenticationState.unauthenticated.isAuthenticated)
        XCTAssertFalse(AuthenticationState.authenticating.isAuthenticated)
        XCTAssertFalse(AuthenticationState.failed.isAuthenticated)
        XCTAssertFalse(AuthenticationState.locked.isAuthenticated)
        XCTAssertFalse(AuthenticationState.sessionExpired.isAuthenticated)
    }

    func testIsUnauthenticated() {
        XCTAssertTrue(AuthenticationState.unauthenticated.isUnauthenticated)
        XCTAssertFalse(AuthenticationState.authenticated.isUnauthenticated)
        XCTAssertFalse(AuthenticationState.authenticating.isUnauthenticated)
        XCTAssertFalse(AuthenticationState.failed.isUnauthenticated)
        XCTAssertFalse(AuthenticationState.locked.isUnauthenticated)
        XCTAssertFalse(AuthenticationState.sessionExpired.isUnauthenticated)
    }

    func testBiometricAndPasscodeVisibility() {
        XCTAssertTrue(AuthenticationState.unauthenticated.showsBiometrics)
        XCTAssertTrue(AuthenticationState.failed.showsBiometrics)
        XCTAssertTrue(AuthenticationState.locked.showsBiometrics)
        XCTAssertFalse(AuthenticationState.authenticated.showsBiometrics)
        XCTAssertFalse(AuthenticationState.authenticating.showsBiometrics)

        XCTAssertTrue(AuthenticationState.unauthenticated.showsPasscode)
        XCTAssertTrue(AuthenticationState.failed.showsPasscode)
        XCTAssertTrue(AuthenticationState.locked.showsPasscode)
        XCTAssertFalse(AuthenticationState.authenticated.showsPasscode)
    }

    func testRequiresReauth() {
        XCTAssertTrue(AuthenticationState.sessionExpired.requiresReauth)
        XCTAssertTrue(AuthenticationState.locked.requiresReauth)
        XCTAssertFalse(AuthenticationState.authenticated.requiresReauth)
        XCTAssertFalse(AuthenticationState.unauthenticated.requiresReauth)
        XCTAssertFalse(AuthenticationState.failed.requiresReauth)
        XCTAssertFalse(AuthenticationState.authenticating.requiresReauth)
    }

    func testUiPropertiesExhaustiveness() {
        let allStates: [AuthenticationState] = [
            .unauthenticated,
            .authenticating,
            .authenticated,
            .failed,
            .locked,
            .sessionExpired
        ]

        for state in allStates {
            _ = state.uiColor
            _ = state.systemImage
            _ = state.backgroundColor
            _ = state.textColor
            _ = state.hapticType
            XCTAssertFalse(state.friendlyDescription.isEmpty)
        }
    }
}
