import Foundation

enum AppConfig {
    /// Public privacy policy — a Notion page published to the web (Share ▸ Publish).
    /// Backup source of the same text: docs/privacy.html in the repo.
    static let privacyPolicyURL = URL(string: "https://www.notion.so/3e07065715f681428288fcbdec763520")!
    
    /// TODO: replace with the real support address (also update it on the privacy page).
    static let supportEmail     = "support@example.com"
}
