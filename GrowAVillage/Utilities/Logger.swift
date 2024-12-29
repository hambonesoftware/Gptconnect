import Foundation
import OSLog

enum LogCategory: String {
    case app = "App"
    case data = "Data"
    case ui = "UI"
    case network = "Network"
    case error = "Error"
}

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case critical = "CRITICAL"
}

@Observable
final class AppLogger {
    static let shared = AppLogger()
    private let logger: Logger
    private var logEntries: [LogEntry] = []
    
    private init() {
        self.logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "AppLogger")
    }
    
    func log(
        _ message: String,
        category: LogCategory,
        level: LogLevel = .info,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let entry = LogEntry(
            timestamp: Date(),
            category: category,
            level: level,
            message: message,
            file: file,
            function: function,
            line: line
        )
        
        logEntries.append(entry)
        
        let logMessage = "\(entry.formattedTimestamp) [\(category.rawValue)][\(level.rawValue)] \(message)"
        
        switch level {
        case .debug:
            logger.debug("\(logMessage)")
        case .info:
            logger.info("\(logMessage)")
        case .warning:
            logger.warning("\(logMessage)")
        case .error:
            logger.error("\(logMessage)")
        case .critical:
            logger.critical("\(logMessage)")
        }
        
#if DEBUG
        print(logMessage)
#endif
    }
    
    func error(
        _ error: Error,
        category: LogCategory,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            error.localizedDescription,
            category: category,
            level: .error,
            file: file,
            function: function,
            line: line
        )
    }
    
    func exportLogs() -> String {
        logEntries
            .map { entry in
                "\(entry.formattedTimestamp) [\(entry.category.rawValue)][\(entry.level.rawValue)] \(entry.message)"
            }
            .joined(separator: "\n")
    }
    
    func clearLogs() {
        logEntries.removeAll()
    }
}

struct LogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let category: LogCategory
    let level: LogLevel
    let message: String
    let file: String
    let function: String
    let line: Int
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: timestamp)
    }
}
