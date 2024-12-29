import SwiftUI
import SwiftData

struct ModuleEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ModuleEditorViewModel
    
    init(module: Module) {
        let dataManager = DataManager(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: ModuleEditorViewModel(dataManager: dataManager, module: module))
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
                            message: "Add components to your module",
                            buttonTitle: "Add Component"
                        ) {
                            viewModel.showComponentSheet = true
                        }
                    } else {
                        ForEach($viewModel.components) { $component in
                            ComponentEditorRow(component: component)
                                .contextMenu {
                                    Button {
                                        viewModel.editComponent(component)
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    
                                    Button {
                                        viewModel.duplicateComponent(component)
                                    } label: {
                                        Label("Duplicate", systemImage: "plus.square.on.square")
                                    }
                                    
                                    Button(role: .destructive) {
                                        viewModel.confirmDeleteComponent(component)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                        .onMove { source, destination in
                            viewModel.components.move(fromOffsets: source, toOffset: destination)
                        }
                    }
                    
                    Button {
                        viewModel.showComponentSheet = true
                    } label: {
                        Label("Add Component", systemImage: "plus.circle")
                    }
                }
                
                if !viewModel.components.isEmpty {
                    Section {
                        Button {
                            viewModel.resetToDefaults()
                        } label: {
                            Label("Reset All Values", systemImage: "arrow.counterclockwise")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Edit Module")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
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
            .sheet(item: $viewModel.componentToEdit) { component in
                ComponentEditorView(component: component) { updatedComponent in
                    viewModel.updateComponent(updatedComponent)
                }
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
                    Text("Are you sure you want to delete '\(component.title)'? This action cannot be undone.")
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.error?.localizedDescription ?? "An unknown error occurred")
            }
        }
    }
}

struct ComponentEditorRow: View {
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
                if !component.isValid {
                    Text("•")
                    Text("Invalid")
                        .foregroundColor(.red)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ModuleEditorView(
        module: PreviewContainer.sample.container.mainContext.fetch(FetchDescriptor<Module>()).first!
    )
    .modelContainer(PreviewContainer.sample.container)
}
