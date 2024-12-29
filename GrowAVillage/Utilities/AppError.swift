import Foundation

enum AppError: LocalizedError {
    // Data Errors
    case dataNotFound
    case invalidData
    case saveFailed(Error)
    case loadFailed(Error)
    case deleteFailed(Error)
    
    // Validation Errors
    case invalidValue(String)
    case requiredFieldMissing(String)
    case invalidFormat(String)
    case outOfRange(String)
    
    // Model Errors
    case modelContextMissing
    case modelValidationFailed(String)
    case modelRelationshipError(String)
    
    // General Errors
    case unknown(Error)
    case custom(String)
    
    var errorDescription: String? {
        switch self {
        case .dataNotFound:
            return "The requested data could not be found"
        case .invalidData:
            return "The data is invalid or corrupted"
        case .saveFailed(let error):
            return "Failed to save data: \(error.localizedDescription)"
        case .loadFailed(let error):
            return "Failed to load data: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete data: \(error.localizedDescription)"
        case .invalidValue(let field):
            return "Invalid value provided for \(field)"
        case .requiredFieldMissing(let field):
            return "\(field) is required"
        case .invalidFormat(let message):
            return "Invalid format: \(message)"
        case .outOfRange(let message):
            return "Value out of range: \(message)"
        case .modelContextMissing:
            return "SwiftData context is missing"
        case .modelValidationFailed(let message):
            return "Validation failed: \(message)"
        case .modelRelationshipError(let message):
            return "Relationship error: \(message)"
        case .unknown(let error):
            return error.localizedDescription
        case .custom(let message):
            return message
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .dataNotFound:
            return "Please check if the data exists and try again"
        case .invalidData:
            return "Please ensure the data is in the correct format"
        case .saveFailed:
            return "Please try saving again"
        case .loadFailed:
            return "Please check your connection and try again"
        case .deleteFailed:
            return "Please try deleting again"
        case .invalidValue:
            return "Please check the input value and try again"
        case .requiredFieldMissing:
            return "Please fill in all required fields"
        case .invalidFormat:
            return "Please check the format and try again"
        case .outOfRange:
            return "Please enter a value within the allowed range"
        case .modelContextMissing:
            return "Please ensure the app is properly initialized"
        case .modelValidationFailed:
            return "Please check the input values and try again"
        case .modelRelationshipError:
            return "Please check the related items and try again"
        case .unknown:
            return "Please try the operation again"
        case .custom:
            return "Please try again or contact support if the issue persists"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .saveFailed(let error),
                .loadFailed(let error),
                .deleteFailed(let error):
            return error.localizedDescription
        case .unknown(let error):
            return error.localizedDescription
        default:
            return nil
        }
    }
}

// MARK: - Error Handling Extensions
extension Error {
    var asAppError: AppError {
        (self as? AppError) ?? .unknown(self)
    }
}

extension Result {
    var asAppError: AppError? {
        if case .failure(let error) = self {
            return error.asAppError
        }
        return nil
    }
}
