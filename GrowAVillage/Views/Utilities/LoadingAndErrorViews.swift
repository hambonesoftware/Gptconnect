import SwiftUI

struct LoadingView: View {
    var text: String = "Loading..."
    var showProgress: Bool = true
    
    var body: some View {
        VStack(spacing: 16) {
            if showProgress {
                ProgressView()
            }
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}

struct ErrorView: View {
    let error: Error
    let retryAction: (() -> Void)?
    
    init(error: Error, retryAction: (() -> Void)? = nil) {
        self.error = error
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.red)
            
            Text("An Error Occurred")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let retryAction {
                Button(action: retryAction) {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(.headline)
                }
                .buttonStyle(.bordered)
                .tint(.blue)
            }
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let buttonTitle: String?
    let buttonAction: (() -> Void)?
    let systemImage: String
    
    init(
        title: String,
        message: String,
        buttonTitle: String? = nil,
        buttonAction: (() -> Void)? = nil,
        systemImage: String = "doc.text"
    ) {
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
        self.systemImage = systemImage
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let buttonTitle, let buttonAction {
                Button(action: buttonAction) {
                    Text(buttonTitle)
                        .font(.headline)
                }
                .buttonStyle(.bordered)
                .tint(.blue)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ValidationErrorBadge: View {
    let message: String?
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message ?? "Invalid")
        }
        .font(.caption)
        .foregroundStyle(.red)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.red.opacity(0.1))
        .clipShape(Capsule())
    }
}

#Preview("Loading States") {
    VStack(spacing: 40) {
        LoadingView(text: "Loading data...")
            .frame(height: 200)
            .border(.gray.opacity(0.2))
        
        ErrorView(
            error: NSError(domain: "com.app", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Failed to load data"
            ]),
            retryAction: {}
        )
        .frame(height: 200)
        .border(.gray.opacity(0.2))
        
        EmptyStateView(
            title: "No Items",
            message: "Add your first item to get started",
            buttonTitle: "Add Item",
            buttonAction: {}
        )
        .frame(height: 200)
        .border(.gray.opacity(0.2))
        
        ValidationErrorBadge(message: "Invalid input")
    }
    .padding()
}
