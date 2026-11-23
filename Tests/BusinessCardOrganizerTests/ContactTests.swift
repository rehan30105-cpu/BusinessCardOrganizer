import XCTest
@testable import BusinessCardOrganizer

final class ContactTests: XCTestCase {

    func testContactDefaultInitialization() {
        let contact = Contact(name: "Jane Doe")

        XCTAssertEqual(contact.name, "Jane Doe")
        XCTAssertEqual(contact.company, "")
        XCTAssertNil(contact.jobTitle)
        XCTAssertNil(contact.email)
        XCTAssertNil(contact.phone)
        XCTAssertNil(contact.website)
        XCTAssertFalse(contact.isFavorite)
        XCTAssertEqual(contact.tags, [.client]) // Defaults to first tag if empty
        XCTAssertFalse(contact.id.uuidString.isEmpty)
    }

    func testContactCustomInitialization() {
        let customId = UUID()
        let tags: [ContactTag] = [.mentor, .friend]
        let contact = Contact(
            id: customId,
            name: "Alex Morgan",
            company: "Tech Corp",
            jobTitle: "Senior Architect",
            email: "alex@techcorp.com",
            phone: "+1-555-0199",
            website: "https://techcorp.com",
            tags: tags,
            isFavorite: true
        )

        XCTAssertEqual(contact.id, customId)
        XCTAssertEqual(contact.name, "Alex Morgan")
        XCTAssertEqual(contact.company, "Tech Corp")
        XCTAssertEqual(contact.jobTitle, "Senior Architect")
        XCTAssertEqual(contact.email, "alex@techcorp.com")
        XCTAssertEqual(contact.phone, "+1-555-0199")
        XCTAssertEqual(contact.website, "https://techcorp.com")
        XCTAssertEqual(contact.tags, tags)
        XCTAssertTrue(contact.isFavorite)
    }

    func testInitialsComputation() {
        let twoNames = Contact(name: "John Doe")
        XCTAssertEqual(twoNames.initials, "JD")

        let singleName = Contact(name: "Cher")
        XCTAssertEqual(singleName.initials, "C")
    }

    func testSearchableTextContainsAllFields() {
        let contact = Contact(
            name: "Taylor Swift",
            company: "Music Inc",
            email: "taylor@music.com",
            phone: "555-1234",
            website: "https://taylorswift.com"
        )

        let text = contact.searchableText
        XCTAssertTrue(text.contains("Taylor Swift"))
        XCTAssertTrue(text.contains("Music Inc"))
        XCTAssertTrue(text.contains("taylor@music.com"))
        XCTAssertTrue(text.contains("555-1234"))
        XCTAssertTrue(text.contains("https://taylorswift.com"))
    }

    func testToggleFavorite() {
        var contact = Contact(name: "Sam Wilson", isFavorite: false)
        let initialDate = contact.updatedAt

        contact.toggleFavorite()
        XCTAssertTrue(contact.isFavorite)
        XCTAssertGreaterThanOrEqual(contact.updatedAt, initialDate)

        contact.toggleFavorite()
        XCTAssertFalse(contact.isFavorite)
    }

    func testEquatableAndHashable() {
        let id = UUID()
        let contact1 = Contact(id: id, name: "Person A", company: "Alpha")
        let contact2 = Contact(id: id, name: "Person B", company: "Beta")
        let contact3 = Contact(name: "Person C")

        XCTAssertEqual(contact1, contact2)
        XCTAssertNotEqual(contact1, contact3)

        var hasher1 = Hasher()
        contact1.hash(into: &hasher1)
        var hasher2 = Hasher()
        contact2.hash(into: &hasher2)
        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())
    }

    func testHasTagAndTagFilterText() {
        let contact = Contact(name: "Jordan Lee", tags: [.vendor, .colleague])

        XCTAssertTrue(contact.hasTag(.vendor))
        XCTAssertTrue(contact.hasTag(.colleague))
        XCTAssertFalse(contact.hasTag(.friend))
        XCTAssertEqual(contact.tagFilterText, "Vendor, Colleague")
    }
}
