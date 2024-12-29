import SwiftUI

struct NewModuleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ModuleEditorViewModel
    
    init() {
        let dataManager = DataManager(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: ModuleEditorViewModel(dataManager: dataManager, module: Module(title: "")))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Module Details") {
                    TextField("Title", text: $viewModel.title)
                        .textInputAutocapitalization(.words)
                }
            }
            .navigationTitle("New Module")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        Task { await viewModel.saveModule() }
                        dismiss()
                    }
                }
            }
        }
    }
}
