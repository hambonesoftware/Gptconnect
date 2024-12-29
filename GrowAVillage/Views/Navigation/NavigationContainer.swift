import SwiftUI
import SwiftData

struct NavigationContainer: View {
    @State private var router = AppRouter.shared
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } content: {
            if let selectedPage = router.selectedPage {
                PageContainerView(page: selectedPage)
            } else {
                ContentPlaceholderView()
            }
        } detail: {
            if router.selectedPage != nil {
                if let selectedModule = router.selectedModule {
                    ModuleDetailView(module: selectedModule)
                } else {
                    ModulePlaceholderView()
                }
            } else {
                DetailPlaceholderView()
            }
        }
        .navigationDestination(for: NavigationDestination.self) { destination in
            switch destination {
            case .page(let page):
                PageView(page: page)
            case .template(let template):
                PageTemplateView(template: template)
            case .module(let module):
                ModuleView(module: module)
            case .settings:
                SettingsView()
            }
        }
        .sheet(item: $router.activeSheet) { sheet in
            switch sheet {
            case .newPage:
                NewPageView()
            case .editPage(let page):
                PageEditorView(page: page)
            case .newModule:
                NewModuleView()
            case .settings:
                SettingsView()
            }
        }
        .alert(item: $router.activeAlert) { alert in
            switch alert {
            case .error(let error):
                Alert(
                    title: Text("Error"),
                    message: Text(error.localizedDescription),
                    dismissButton: .default(Text("OK"))
                )
            case .confirmation(let title, let message, let action):
                Alert(
                    title: Text(title),
                    message: Text(message),
                    primaryButton: .default(Text("OK"), action: action),
                    secondaryButton: .cancel()
                )
            case .destructive(let title, let message, let action):
                Alert(
                    title: Text(title),
                    message: Text(message),
                    primaryButton: .destructive(Text("Delete"), action: action),
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

// MARK: - Support Views
private struct ContentPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Select a page from the sidebar")
                .font(.headline)
        }
    }
}

private struct ModulePlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.2x2")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Select a module to view details")
                .font(.headline)
        }
    }
}

private struct DetailPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.3.layers.3d")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Select a page to view its modules")
                .font(.headline)
        }
    }
}

#Preview {
    NavigationContainer()
        .modelContainer(PreviewContainer.sample.container)
}
