import SwiftUI

@main
struct MyAppApp: App {
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SidebarView(dataManager: dataManager)
                if let selectedPage = dataManager.selectedPage {
                    if dataManager.isEditing {
                        PageEditorView(page: Binding(
                            get: { selectedPage },
                            set: { dataManager.selectedPage = $0 }
                        ))
                        .onAppear {
                            print("App appeared, loading pages data.")
                            dataManager.loadPages()
                        }
                        .onDisappear {
                            print("App disappeared, saving pages data.")
                            dataManager.savePages()
                        }
                    } else {
                        PageView(page: Binding(
                            get: { selectedPage },
                            set: { dataManager.selectedPage = $0 }
                        ))
                        .onAppear {
                            print("App appeared, loading pages data.")
                            dataManager.loadPages()
                        }
                        .onDisappear {
                            print("App disappeared, saving pages data.")
                            dataManager.savePages()
                        }
                    }
                } else {
                    Text("Select a page from the menu.")
                        .onAppear {
                            print("App appeared, loading pages data.")
                            dataManager.loadPages()
                        }
                        .onDisappear {
                            print("App disappeared, saving pages data.")
                            dataManager.savePages()
                        }
                }
            }
        }
    }
}
