import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Page> { !$0.isTemplate },
           sort: \Page.updatedAt, order: .reverse) private var pages: [Page]
    @Query(filter: #Predicate<Page> { $0.isTemplate },
           sort: \Page.title) private var templates: [Page]
    
    @State private var viewModel: SidebarViewModel
    @State private var searchText = ""
    
    init() {
        let dataManager = DataManager(modelContext: modelContext)
        _viewModel = State(initialValue: SidebarViewModel(dataManager: dataManager))
    }
    
    var filteredPages: [Page] {
        if searchText.isEmpty { return pages }
        return pages.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        List(selection: $viewModel.selectedPage) {
            Section("Pages") {
                if filteredPages.isEmpty {
                    EmptyStateView(
                        title: "No Pages",
                        message: "Create your first page using a template",
                        buttonTitle: "Create Page"
                    ) {
                        AppRouter.shared.showSheet(.newPage)
                    }
                } else {
                    ForEach(filteredPages) { page in
                        PageRow(page: page)
                            .tag(page)
                            .contextMenu {
                                Button {
                                    AppRouter.shared.showSheet(.editPage(page))
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                
                                Button {
                                    Task {
                                        await viewModel.duplicatePage(page)
                                    }
                                } label: {
                                    Label("Duplicate", systemImage: "doc.on.doc")
                                }
                                
                                Button(role: .destructive) {
                                    viewModel.confirmDelete(page)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            
            Section("Templates") {
                ForEach(templates) { template in
                    TemplateRow(template: template)
                        .tag(template)
                }
                
                Button {
                    AppRouter.shared.showSheet(.newTemplate)
                } label: {
                    Label("New Template", systemImage: "plus")
                }
            }
            
            Section("Actions") {
                NavigationLink(value: NavigationDestination.settings) {
                    Label("Settings", systemImage: "gear")
                }
                
#if DEBUG
                Button {
                    AppRouter.shared.showSheet(.debug)
                } label: {
                    Label("Debug Menu", systemImage: "ladybug")
                }
#endif
            }
        }
        .navigationTitle("Menu")
        .searchable(text: $searchText, prompt: "Search pages")
        .toolbar {
            ToolbarItem {
                Button {
                    AppRouter.shared.showSheet(.newPage)
                } label: {
                    Label("New Page", systemImage: "plus")
                }
            }
        }
    }
}

struct PageRow: View {
    let page: Page
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(page.title)
                .font(.headline)
            HStack {
                Text("\(page.modules.count) modules")
                Text("•")
                Text(page.updatedAt.formatted(.relative(presentation: .named)))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

struct TemplateRow: View {
    let template: Page
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(template.title)
                .font(.headline)
            Text("\(template.modules.count) modules")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationSplitView {
        SidebarView()
    } detail: {
        Text("Select a page")
    }
    .modelContainer(PreviewContainer.sample.container)
}
