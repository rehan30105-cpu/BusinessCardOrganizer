import Foundation
import SwiftUI

// MARK: - Contact
// Core data model for a business contact
// Codable for JSON persistence
// Identifiable for SwiftUI List integration
// Uses UUID for stable identifiers
// Includes timestamps for creation and modification

public struct Contact: Identifiable, Codable, Equatable, Hashable {
    // MARK: - Properties
    public let id: UUID
    public var name: String
    public var company: String
    public var jobTitle: String?
    public var email: String?
    public var phone: String?
    public var website: String?
    public var tags: [ContactTag]
    public var isFavorite: Bool
    public var profileImageURL: URL?

    // MARK: - Timestamps
    public var createdAt: Date
    public var updatedAt: Date

    // MARK: - Computed Properties

    /// Initials for avatar placeholder
    public var initials: String {
        let formatter = PersonNameComponentsFormatter()
        let components = formatter.personNameComponents(from: name)
        let initials = (components?.firstName?.first ?? "") + (components?.lastName?.first ?? "")
        return String(initials).uppercased()
    }

    /// Searchable text for contact search functionality
    public var searchableText: String {
        [
            name,
            company,
            email ?? "",
            phone ?? "",
            website ?? ""
        ]
        .compactMap { $0 }
        .joined(separator: " ")
    }

    // Toggle favorite status
    mutating func toggleFavorite() {
        isFavorite.toggle()
        updatedAt = Date()
    }

    // Check if contact has a specific tag
    func hasTag(_ tag: ContactTag) -> Bool {
        tags.contains(tag)
    }

    // Tag filter text
    var tagFilterText: String {
        tags.map { $0.displayName }.joined(separator: ", ")
    }

    // MARK: - Initialization
    public init(
        id: UUID = UUID(),
        name: String,
        company: String = "",
        jobTitle: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        website: String? = nil,
        tags: [ContactTag] = [],
        isFavorite: Bool = false,
        profileImageURL: URL? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.company = company
        self.jobTitle = jobTitle
        self.email = email
        self.phone = phone
        self.website = website
        self.tags = tags.isEmpty ? [.allCases.first!] : tags  // Default to first tag
        self.isFavorite = isFavorite
        self.profileImageURL = profileImageURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Equatable Conformance
    public static func == (lhs: Contact, rhs: Contact) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Hashable conformance
    public func hash(into hasher: inout Hasher) {
        hasher.insert(id)
    }
}

// MARK: - Contact+Preview
// Preview logic removed - requires full project setup

// MARK: - Contact+Extension
extension Contact {
    /// Static example for previews
    static var example: Contact {
        Contact(
            name: "Jordan Reyes",
            company: "Acme Studios",
            email: "jordan.reyes@acme-studios.com",
            phone: "(415) 555-0123",
            website: "https://acme-studios.com",
            tags: [.client, .colleague],
            isFavorite: true
        )
    }

    static var example2: Contact {
        Contact(
            name: "Maria Santos",
            company: "VertiQ Solutions",
            phone: "+1 (555) 234-5678",
            tags: [.vendor, .mentor]
        )
    }
}

// MARK: - Contact+Extension for Preview
// Preview provider logic removed - requires full project setup