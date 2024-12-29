import SwiftUI
import SwiftData

struct ModuleSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Module.title) private var moduleTemplates: [Module]
    @StateObject private var viewModel: ModuleSelectionViewModel
    @State private var searchText = ""
    
    let onModuleSelected: (Module) -> Void
    
    init(onModuleSelected: @escaping (Module) -> Void) {
        self.onModuleSelected = onModuleSelected
        let dataManager = DataManager(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: ModuleSelectionViewModel(dataManager: dataManager))
    }
    
    var filteredModules: [Module] {
        if searchText.isEmpty {
            return moduleTemplates
        } else {
            return moduleTemplates.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if filteredModules.isEmpty {
                    EmptyStateView(
                        title: "No Module Templates",
                        message: "Create your first module template",
                        buttonTitle: "Create Template"
                    ) {
                        viewModel.showNewModuleSheet = true
                    }
                } else {
                    ForEach(filteredModules) { module in
                        ModuleTemplateRow(module: module)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectModule(module)
                            }
                            .contextMenu {
                                Button {
                                    selectModule(module)
                                } label: {
                                    Label("Select", systemImage: "checkmark.circle")
                                }
                                
                                Button {
                                    Task {
                                        await viewModel.duplicateModule(module)
                                    }
                                } label: {
                                    Label("Duplicate", systemImage: "plus.square.on.square")
                                }
                                
                                Button {
                                    viewModel.editModule(module)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive) {
                                    viewModel.confirmDelete(module)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .navigationTitle("Select Module")
            .searchable(text: $searchText, prompt: "Search modules")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showNewModuleSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showNewModuleSheet) {
                ModuleTemplateView()
            }
            .sheet(item: $viewModel.moduleToEdit) { module in
                ModuleTemplateView(module: module)
            }
            .alert("Delete Module", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    if let module = viewModel.moduleToDelete {
                        Task {
                            await viewModel.deleteModule(module)
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                if let module = viewModel.moduleToDelete {
                    Text("Are you sure you want to delete '\(module.title)'? This action cannot be undone.")
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.error?.localizedDescription ?? "An unknown error occurred")
            }
        }
    }
    
    private func selectModule(_ module: Module) {
        Task {
            if let duplicatedModule = await viewModel.duplicateForSelection(module) {
                onModuleSelected(duplicatedModule)
                dismiss()
            }
        }
    }
}

struct ModuleTemplateRow: View {
    let module: Module
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(module.title)
                .font(.headline)
            
            Text("\(module.components.count) components")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ModuleSelectionView { _ in }
        .modelContainer(PreviewContainer.sample.container)
}
