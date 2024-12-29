import SwiftUI
import SwiftData

struct ComponentDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var component: Component
    @StateObject private var viewModel: ComponentDetailViewModel
    
    init(component: Component) {
        self.component = component
        let dataManager = DataManager(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: ComponentDetailViewModel(dataManager: dataManager, component: component))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Configuration")
                    .font(.headline)
                
                configurationDetails
            }
            
            if !component.isValid {
                ValidationErrorView(message: component.configuration?.errorMessage)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
        .contextMenu {
            Button {
                viewModel.showEditor = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button {
                Task {
                    await viewModel.duplicateComponent()
                }
            } label: {
                Label("Duplicate", systemImage: "plus.square.on.square")
            }
            
            Button(role: .destructive) {
                viewModel.confirmDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $viewModel.showEditor) {
            ComponentEditorView(component: component)
        }
        .alert("Delete Component", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteComponent()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this component? This action cannot be undone.")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.error?.localizedDescription ?? "An unknown error occurred")
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(component.title)
                    .font(.headline)
                
                if component.configuration?.isRequired == true {
                    Text("*")
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Text(component.type.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if let helperText = component.configuration?.helperText {
                Text(helperText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var configurationDetails: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let placeholder = component.configuration?.placeholder {
                DetailRow(title: "Placeholder", value: placeholder)
            }
            
            DetailRow(title: "Required", value: component.configuration?.isRequired == true ? "Yes" : "No")
            
            if case .picker = component.type {
                DetailRow(title: "Options", value: component.pickerOptions.joined(separator: ", "))
            }
            
            if let rules = component.configuration?.validationRules {
                DetailRow(title: "Validation Rules", value: "\(rules.count) rules")
            }
        }
        .font(.caption)
    }
}

private struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
        }
    }
}

private struct ValidationErrorView: View {
    let message: String?
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message ?? "Invalid input")
        }
        .font(.caption)
        .foregroundColor(.red)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.red.opacity(0.1))
        .cornerRadius(6)
    }
}

#Preview {
    ComponentDetailView(
        component: PreviewContainer.sample.container.mainContext.fetch(FetchDescriptor<Component>()).first!
    )
    .padding()
    .previewWith(.sample)
}
