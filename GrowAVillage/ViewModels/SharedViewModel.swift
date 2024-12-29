import SwiftUI
import SwiftData

@Observable
final class SharedViewModel {
    static let shared = SharedViewModel()
    private let logger = AppLogger.shared
    private let analytics = Analytics.shared
    
    private init() {}
    
    // MARK: - User Preferences
    var autosaveEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "autosaveEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "autosaveEnabled") }
    }
    
    var defaultTemplate: String? {
        get { UserDefaults.standard.string(forKey: "defaultTemplate") }
        set { UserDefaults.standard.set(newValue, forKey: "defaultTemplate") }
    }
    
    var showValidation: Bool {
        get { UserDefaults.standard.bool(forKey: "showValidation") }
        set { UserDefaults.standard.set(newValue, forKey: "showValidation") }
    }
    
    // MARK: - Theme & Appearance
    var isDarkMode: Bool {
        get { UserDefaults.standard.bool(forKey: "isDarkMode") }
        set {
            UserDefaults.standard.set(newValue, forKey: "isDarkMode")
            applyTheme()
        }
    }
    
    var accentColor: Color {
        get {
            if let colorHex = UserDefaults.standard.string(forKey: "accentColor") {
                return Color(hex: colorHex) ?? .blue
            }
            return .blue
        }
        set {
            if let hexString = newValue.toHex() {
                UserDefaults.standard.set(hexString, forKey: "accentColor")
                applyTheme()
            }
        }
    }
    
    // MARK: - App State
    var isFirstLaunch: Bool {
        get { UserDefaults.standard.bool(forKey: "hasLaunchedBefore") == false }
        set { UserDefaults.standard.set(!newValue, forKey: "hasLaunchedBefore") }
    }
    
    var lastBackupDate: Date? {
        get { UserDefaults.standard.object(forKey: "lastBackupDate") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "lastBackupDate") }
    }
    
    // MARK: - App Settings
    var backupFrequency: BackupFrequency {
        get {
            if let rawValue = UserDefaults.standard.string(forKey: "backupFrequency"),
               let frequency = BackupFrequency(rawValue: rawValue) {
                return frequency
            }
            return .weekly
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "backupFrequency") }
    }
    
    enum BackupFrequency: String, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case never = "Never"
    }
    
    // MARK: - Methods
    private func applyTheme() {
        logger.log("Theme updated - Dark Mode: \(isDarkMode), Accent Color: \(accentColor.toHex() ?? "default")", category: .app)
        analytics.track(.userAction("theme_updated", [
            "dark_mode": isDarkMode,
            "accent_color": accentColor.toHex() ?? "default"
        ]))
    }
    
    func resetPreferences() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        
        // Reset to defaults
        autosaveEnabled = true
        isDarkMode = false
        accentColor = .blue
        showValidation = true
        backupFrequency = .weekly
        
        logger.log("User preferences reset to defaults", category: .app)
        analytics.track(.userAction("reset_preferences", [:]))
    }
    
    func shouldBackup() -> Bool {
        guard backupFrequency != .never else { return false }
        
        guard let lastBackup = lastBackupDate else {
            return true
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        switch backupFrequency {
        case .daily:
            return !calendar.isDate(lastBackup, inSameDayAs: now)
        case .weekly:
            let weekDifference = calendar.dateComponents([.weekOfYear], from: lastBackup, to: now)
            return weekDifference.weekOfYear ?? 0 >= 1
        case .monthly:
            let monthDifference = calendar.dateComponents([.month], from: lastBackup, to: now)
            return monthDifference.month ?? 0 >= 1
        case .never:
            return false
        }
    }
}

// MARK: - Color Extensions
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
    
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                      lroundf(r * 255),
                      lroundf(g * 255),
                      lroundf(b * 255)
        )
    }
}
