import SwiftUI

struct NewPageView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: PageEditorViewModel
    
    init() {
        let dataManager = DataManager(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: PageEditorViewModel(dataManager: dataManager, page: Page(title: "", modules: [])))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Page Details") {
                    TextField("Title", text: $viewModel.title)
                        .textInputAutocapitalization(.words)
                }
                
                Section("Modules") {
                    ForEach(viewModel.modules) { module in
                        Text(module.title)
                    }
                    Button("Add Module") {
                        viewModel.addModule(Module(title: "New Module"))
                    }
                }
            }
            .navigationTitle("New Page")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        Task { await viewModel.savePage() }
                        dismiss()
                    }
                }
            }
        }
    }
}
