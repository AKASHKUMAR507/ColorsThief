import Foundation

enum AppConfig {
    /// Public privacy policy URL — needed only for App Store Connect's "Privacy Policy URL" field.
    /// Inside the app the policy is shown by PrivacyPolicyView (same text; source in PrivacyPolicyText).
    static let privacyPolicyURL = URL(string: "https://akashkumar507.github.io/ColorsThief/privacy.html")!
    
    /// Landing / support page (also the App Store Connect Support URL).
    static let websiteURL       = URL(string: "https://akashkumar507.github.io/ColorsThief/")!
    
    /// TODO: replace with the real support address (also update it on the privacy page).
    static let supportEmail     = "support@example.com"
}
