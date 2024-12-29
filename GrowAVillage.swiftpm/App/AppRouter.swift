import SwiftUI
import SwiftData

@Observable
final class AppRouter: ObservableObject {
    static let shared = AppRouter()
    private init() {}
    
    // Navigation state
    var selectedPage: Page?
    var selectedModule: Module?
    var navigationPath = NavigationPath()
    
    // Sheet presentation
    var activeSheet: Sheet?
    
    // Alert presentation
    var activeAlert: Alert?
    
    // MARK: - Navigation
    func navigateToPage(_ page: Page) {
        selectedPage = page
        selectedModule = nil
    }
    
    func navigateToModule(_ module: Module) {
        selectedModule = module
    }
    
    func clearSelection() {
        selectedPage = nil
        selectedModule = nil
    }
    
    // MARK: - Sheet Management
    enum Sheet: Identifiable {
        case newPage
        case editPage(Page)
        case newModule
        case editModule(Module)
        case settings
        case debug
        
        var id: String {
            switch self {
            case .newPage: return "newPage"
            case .editPage(let page): return "editPage-\(page.id)"
            case .newModule: return "newModule"
            case .editModule(let module): return "editModule-\(module.id)"
            case .settings: return "settings"
            case .debug: return "debug"
            }
        }
    }
    
    func showSheet(_ sheet: Sheet) {
        activeSheet = sheet
    }
    
    func dismissSheet() {
        activeSheet = nil
    }
    
    // MARK: - Alert Management
    enum Alert: Identifiable {
        case error(Error)
        case confirmation(title: String, message: String, action: () -> Void)
        case destructive(title: String, message: String, action: () -> Void)
        
        var id: String {
            switch self {
            case .error: return "error"
            case .confirmation: return "confirmation"
            case .destructive: return "destructive"
            }
        }
    }
    
    func showAlert(_ alert: Alert) {
        activeAlert = alert
    }
    
    func dismissAlert() {
        activeAlert = nil
    }
    
    // MARK: - Error Handling
    func handleError(_ error: Error) {
        showAlert(.error(error))
        AppLogger.shared.error(error, category: .error)
    }
    
    // MARK: - State Management
    func reset() {
        selectedPage = nil
        selectedModule = nil
        navigationPath.removeLast(navigationPath.count)
        activeSheet = nil
        activeAlert = nil
    }
}
