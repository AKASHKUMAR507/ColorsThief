import Foundation

enum AppConfig {
    /// Public privacy policy page (source: docs/privacy.html in this repo, hosted with GitHub Pages).
    /// TODO: replace with the live URL, e.g. https://<github-user>.github.io/color-thief/privacy.html
    static let privacyPolicyURL = URL(string: "https://example.com/color-thief/privacy.html")!
    
    /// Shown nowhere yet; used by the privacy page's contact line once you fill it in.
    static let supportEmail     = "support@example.com"
}
