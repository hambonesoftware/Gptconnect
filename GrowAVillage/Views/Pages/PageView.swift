import SwiftUI
import SwiftData

struct PageView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var page: Page
    @StateObject private var viewModel: PageViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(page: Page) {
        self.page = page
        let dataManager = DataManager(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: PageViewModel(dataManager: dataManager, page: page))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                modulesList
            }
            .padding()
        }
        .navigationTitle(page.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        Task { await viewModel.savePage() }
                    } label: {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }
                    
                    Button {
                        Task { await viewModel.createTemplate() }
                    } label: {
                        Label("Save as Template", systemImage: "doc.badge.plus")
                    }
                    
                    Button {
                        AppRouter.shared.showSheet(.editPage(page))
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
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                LoadingView()
            }
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
                Text(page.title)
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                validationBadge
            }
            
            Text("Last updated \(page.updatedAt.formatted())")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var modulesList: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            ForEach(page.modules) { module in
                ModuleView(module: module)
            }
        }
    }
    
    @ViewBuilder
    private var validationBadge: some View {
        if !page.isValid {
            Text("Invalid Input")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.red.opacity(0.1))
                .foregroundStyle(.red)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    NavigationStack {
        PageView(page: PreviewContainer.sample.container.mainContext.fetch(FetchDescriptor<Page>()).first!)
    }
    .modelContainer(PreviewContainer.sample.container)
}
