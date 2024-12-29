import SwiftUI
import SwiftData

struct ModuleDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var module: Module
    @StateObject private var viewModel: ModuleDetailViewModel
    
    init(module: Module) {
        self.module = module
        let dataManager = DataManager(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: ModuleDetailViewModel(dataManager: dataManager, module: module))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                componentsList
            }
            .padding()
        }
        .navigationTitle(module.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        Task {
                            await viewModel.saveModule()
                        }
                    } label: {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }
                    
                    Button {
                        Task {
                            await viewModel.saveAsTemplate()
                        }
                    } label: {
                        Label("Save as Template", systemImage: "doc.badge.plus")
                    }
                    
                    Button {
                        Task {
                            await viewModel.duplicateModule()
                        }
                    } label: {
                        Label("Duplicate", systemImage: "plus.square.on.square")
                    }
                    
                    Button {
                        viewModel.showModuleEditor = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        viewModel.confirmDelete()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $viewModel.showModuleEditor) {
            ModuleEditorView(module: module)
        }
        .alert("Delete Module", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteModule()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this module? This action cannot be undone.")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.error?.localizedDescription ?? "An unknown error occurred")
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(module.title)
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                if !module.isValid {
                    Text("Invalid Input")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.red.opacity(0.1))
                        .foregroundColor(.red)
                        .clipShape(Capsule())
                }
            }
            
            Text("\(module.components.count) components")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var componentsList: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            ForEach(module.components) { component in
                ComponentDetailView(component: component)
                
                if component.id != module.components.last?.id {
                    Divider()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ModuleDetailView(
            module: PreviewContainer.sample.container.mainContext.fetch(FetchDescriptor<Module>()).first!
        )
    }
    .modelContainer(PreviewContainer.sample.container)
}
