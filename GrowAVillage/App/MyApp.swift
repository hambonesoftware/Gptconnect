import SwiftUI
import SwiftData

@main
struct MyApp: App {
    @StateObject private var router = AppRouter.shared
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                Page.self,
                Module.self,
                Component.self,
                ComponentConfiguration.self
            ])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            // Initialize managers
            _ = AppLogger.shared
            _ = Analytics.shared
            
            // Create default data if needed
            checkAndCreateDefaultData()
            
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .environment(\.modelContext, container.mainContext)
                .environmentObject(router)
        }
    }
    
    private func checkAndCreateDefaultData() {
        Task {
            let context = container.mainContext
            let descriptor = FetchDescriptor<Page>()
            
            do {
                let count = try context.fetchCount(descriptor)
                if count == 0 {
                    DefaultDataProvider.createDefaultData(in: context)
                    try context.save()
                }
            } catch {
                print("Error checking/creating default data: \(error)")
            }
        }
    }
}
