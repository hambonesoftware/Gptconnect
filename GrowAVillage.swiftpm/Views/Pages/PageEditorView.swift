import SwiftUI
import SwiftData

struct PageEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var page: Page
    @StateObject private var viewModel: PageEditorViewModel
    
    init(page: Page) {
        self.page = page
        let dataManager = DataManager(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: PageEditorViewModel(dataManager: dataManager, page: page))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Page Details") {
                    TextField("Title", text: $viewModel.title)
                        .textInputAutocapitalization(.words)
                }
                
                Section("Modules") {
                    if viewModel.modules.isEmpty {
                        EmptyStateView(
                            title: "No Modules",
                            message: "Add your first module to get started",
                            buttonTitle: "Add Module"
                        ) {
                            viewModel.showModuleSheet = true
                        }
                    } else {
                        ForEach($viewModel.modules) { $module in
                            ModuleEditorRow(module: module)
                        }
                        .onMove { indices, newOffset in
                            viewModel.modules.move(fromOffsets: indices, toOffset: newOffset)
                        }
                        .onDelete { indices in
                            viewModel.modules.remove(atOffsets: indices)
                        }
                    }
                    
                    Button {
                        viewModel.showModuleSheet = true
                    } label: {
                        Label("Add Module", systemImage: "plus.circle")
                    }
                }
                
                Section {
                    Button {
                        viewModel.resetToDefaults()
                    } label: {
                        Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Edit Page")
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
                            await viewModel.savePage()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.isValid)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    EditButton()
                }
            }
            .sheet(isPresented: $viewModel.showModuleSheet) {
                ModuleSelectionView { module in
                    viewModel.addModule(module)
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

struct ModuleEditorRow: View {
    let module: Module
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(module.title)
                .font(.headline)
            
            HStack {
                Text("\(module.components.count) components")
                if !module.isValid {
                    Text("•")
                    Text("Invalid Input")
                        .foregroundStyle(.red)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    PageEditorView(page: PreviewContainer.sample.container.mainContext.fetch(FetchDescriptor<Page>()).first!)
        .modelContainer(PreviewContainer.sample.container)
}
