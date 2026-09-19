import StoreKit
import Combine

/// StoreKit 2 wrapper for the one-time "Full Game" unlock (levels 4+).
/// Entitlement is mirrored into `PlayerStats.hasFullGame` so LevelData can stay synchronous.
@MainActor
final class StoreKitManager: ObservableObject {
    
    static let shared = StoreKitManager()
    static let fullGameID = "com.akash.colorthief.fullgame"
    
    @Published private(set) var fullGame: Product?
    @Published private(set) var hasFullGame: Bool = PlayerStats.hasFullGame
    @Published private(set) var isBusy = false
    @Published var lastError: String?
    
    private var updatesTask: Task<Void, Never>?
    
    private init() {
        updatesTask = listenForTransactions()
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }
    
    deinit { updatesTask?.cancel() }
    
    /// Localized price, e.g. "$1.99". Falls back while products load.
    var displayPrice: String { fullGame?.displayPrice ?? "$1.99" }
    
    // MARK: - Products
    
    func loadProducts() async {
        do {
            fullGame = try await Product.products(for: [Self.fullGameID]).first
        } catch {
            lastError = "Couldn't load the store. \(error.localizedDescription)"
        }
    }
    
    // MARK: - Purchase / restore
    
    /// Returns true when the purchase completed (not pending / cancelled).
    @discardableResult
    func purchaseFullGame() async -> Bool {
        if fullGame == nil { await loadProducts() }
        guard let product = fullGame else {
            lastError = "The store isn't available right now. Please try again later."
            return false
        }
        isBusy = true
        defer { isBusy = false }
        do {
            switch try await product.purchase() {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                setFullGame(true)
                return true
            case .pending:
                lastError = "Purchase is waiting for approval (Ask to Buy)."
                return false
            case .userCancelled:
                return false
            @unknown default:
                return false
            }
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }
    
    func restorePurchases() async {
        isBusy = true
        defer { isBusy = false }
        try? await AppStore.sync()
        await refreshEntitlements()
        if !hasFullGame { lastError = "No previous purchase found for this Apple ID." }
    }
    
    /// Checks current entitlements (call on launch and after restore).
    func refreshEntitlements() async {
        var owned = false
        for await result in Transaction.currentEntitlements {
            if let t = try? checkVerified(result), t.productID == Self.fullGameID, t.revocationDate == nil {
                owned = true
            }
        }
        setFullGame(owned)
    }
    
    // MARK: - Internals
    
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if let t = try? await self.checkVerified(result) {
                    await t.finish()
                    await self.refreshEntitlements()
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe): return safe
        case .unverified(_, let error): throw error
        }
    }
    
    private func setFullGame(_ value: Bool) {
        hasFullGame = value
        PlayerStats.hasFullGame = value
    }
}
