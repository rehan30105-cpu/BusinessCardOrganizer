import XCTest
import SwiftUI
@testable import BusinessCardOrganizer

final class ContactTagTests: XCTestCase {

    func testAllCasesCompleteness() {
        let allCases = ContactTag.allCases
        XCTAssertEqual(allCases.count, 5)
        XCTAssertTrue(allCases.contains(.client))
        XCTAssertTrue(allCases.contains(.vendor))
        XCTAssertTrue(allCases.contains(.mentor))
        XCTAssertTrue(allCases.contains(.colleague))
        XCTAssertTrue(allCases.contains(.friend))
    }

    func testDisplayNames() {
        XCTAssertEqual(ContactTag.client.displayName, "Client")
        XCTAssertEqual(ContactTag.vendor.displayName, "Vendor")
        XCTAssertEqual(ContactTag.mentor.displayName, "Mentor")
        XCTAssertEqual(ContactTag.colleague.displayName, "Colleague")
        XCTAssertEqual(ContactTag.friend.displayName, "Friend")
    }

    func testIconNamesAreValidSFSymbols() {
        for tag in ContactTag.allCases {
            XCTAssertFalse(tag.iconName.isEmpty, "Icon name for \(tag) should not be empty")
        }
        XCTAssertEqual(ContactTag.client.iconName, "building.columns")
        XCTAssertEqual(ContactTag.vendor.iconName, "truck")
        XCTAssertEqual(ContactTag.mentor.iconName, "bookmark")
        XCTAssertEqual(ContactTag.colleague.iconName, "person.3")
        XCTAssertEqual(ContactTag.friend.iconName, "heart")
    }

    func testIdentifiableConformance() {
        for tag in ContactTag.allCases {
            XCTAssertEqual(tag.id, tag.rawValue)
        }
    }

    func testColorsAreDefined() {
        for tag in ContactTag.allCases {
            _ = tag.backgroundColor
            _ = tag.textColor
        }
    }
}
