import SwiftUI

@Observable
final class SettingsViewModel {
    private let dataManager: DataManager
    private let logger = AppLogger.shared
    private let analytics = Analytics.shared
    
    var userPreferences: [String: Any]  // Stores settings as key-value pairs
    var error: Error?
    var showError = false
    var isLoading = false
    var hasUnsavedChanges = false
    
    init(dataManager: DataManager, initialPreferences: [String: Any] = [:]) {
        self.dataManager = dataManager
        self.userPreferences = initialPreferences
    }
    
    // MARK: - Validation
    var isValid: Bool {
        !userPreferences.keys.contains { $0.isEmpty }
    }
    
    // MARK: - Operations
    func updatePreference(key: String, value: Any) {
        userPreferences[key] = value
        hasUnsavedChanges = true
    }
    
    func resetPreferences() {
        userPreferences.removeAll()
        hasUnsavedChanges = true
    }
    
    @MainActor
    func savePreferences() async {
        guard isValid else {
            logger.log("Invalid preferences. Save operation aborted.")
            showError = true
            return
        }
        
        isLoading = true
        do {
            try await dataManager.savePreferences(userPreferences)
            hasUnsavedChanges = false
            analytics.trackEvent("Preferences Saved")
        } catch {
            logger.log("Error saving preferences: \(error)")
            self.error = error
            showError = true
        }
        isLoading = false
    }
}
