import Foundation

enum AnalyticsEvent {
    case appLaunch
    case pageView(String)
    case moduleView(String)
    case componentInteraction(String, String)
    case saveAction(String)
    case error(String, Error)
    case userAction(String, [String: Any])
    
    var name: String {
        switch self {
        case .appLaunch: return "app_launch"
        case .pageView: return "page_view"
        case .moduleView: return "module_view"
        case .componentInteraction: return "component_interaction"
        case .saveAction: return "save_action"
        case .error: return "error"
        case .userAction: return "user_action"
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .appLaunch:
            return [:]
        case .pageView(let pageName):
            return ["page_name": pageName]
        case .moduleView(let moduleName):
            return ["module_name": moduleName]
        case .componentInteraction(let componentId, let action):
            return ["component_id": componentId, "action": action]
        case .saveAction(let itemType):
            return ["item_type": itemType]
        case .error(let context, let error):
            return [
                "context": context,
                "error_description": error.localizedDescription,
                "error_domain": (error as NSError).domain,
                "error_code": (error as NSError).code
            ]
        case .userAction(let action, let parameters):
            return ["action": action] + parameters
        }
    }
}

protocol AnalyticsProvider {
    func track(_ event: AnalyticsEvent)
}

final class Analytics {
    static let shared = Analytics()
    private var providers: [AnalyticsProvider] = []
    
    private init() {
        setupDefaultProviders()
    }
    
    func register(_ provider: AnalyticsProvider) {
        providers.append(provider)
    }
    
    func track(_ event: AnalyticsEvent) {
        providers.forEach { $0.track(event) }
        
#if DEBUG
        let parametersDescription = event.parameters
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")
        print("📊 Analytics: \(event.name) {\(parametersDescription)}")
#endif
    }
    
    private func setupDefaultProviders() {
#if DEBUG
        register(DebugAnalyticsProvider())
#endif
    }
}

#if DEBUG
struct DebugAnalyticsProvider: AnalyticsProvider {
    func track(_ event: AnalyticsEvent) {
        // Debug logging is handled in Analytics.track
    }
}
#endif

// Helper operators for dictionary merging
func +<Key, Value>(lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
    var result = lhs
    rhs.forEach { result[$0] = $1 }
    return result
}
