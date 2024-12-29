import SwiftUI
import SwiftData

struct ModuleTemplateView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ModuleTemplateViewModel
    
    init(module: Module? = nil) {
        let dataManager = DataManager(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: ModuleTemplateViewModel(dataManager: dataManager, module: module))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Module Details") {
                    TextField("Title", text: $viewModel.title)
                        .textInputAutocapitalization(.words)
                }
                
                Section("Components") {
                    if viewModel.components.isEmpty {
                        EmptyStateView(
                            title: "No Components",
                            message: "Add your first component to get started",
                            buttonTitle: "Add Component"
                        ) {
                            viewModel.showComponentSheet = true
                        }
                    } else {
                        ForEach($viewModel.components) { $component in
                            ComponentTemplateRow(component: component)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        viewModel.confirmDelete(component)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                        .onMove { indices, newOffset in
                            viewModel.components.move(fromOffsets: indices, toOffset: newOffset)
                        }
                    }
                    
                    Button {
                        viewModel.showComponentSheet = true
                    } label: {
                        Label("Add Component", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Module" : "New Module")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.isEditing ? "Save" : "Create") {
                        Task {
                            await viewModel.save()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.isValid)
                }
                
                if !viewModel.components.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showComponentSheet) {
                ComponentCreatorView { component in
                    viewModel.addComponent(component)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.error?.localizedDescription ?? "An unknown error occurred")
            }
            .alert("Delete Component", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    if let component = viewModel.componentToDelete {
                        viewModel.deleteComponent(component)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                if let component = viewModel.componentToDelete {
                    Text("Are you sure you want to delete '\(component.title)'?")
                }
            }
        }
    }
}

struct ComponentTemplateRow: View {
    let component: Component
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(component.title)
                .font(.headline)
            
            HStack {
                Text(component.type.displayName)
                if component.configuration?.isRequired == true {
                    Text("•")
                    Text("Required")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ModuleTemplateView()
        .modelContainer(PreviewContainer.sample.container)
}
