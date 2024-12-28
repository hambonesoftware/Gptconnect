import SwiftUI

struct SidebarView: View {
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        List {
            Section(header: Text("Pages")) {
                ForEach(dataManager.pages) { page in
                    Button(action: {
                        dataManager.selectedPage = page
                    }) {
                        Text(page.title)
                    }
                }
            }
            Section(header: Text("Actions")) {
                Button(action: {
                    // Action to edit the selected page
                    dataManager.isEditing = true
                }) {
                    Text("Edit Selected Page")
                }
                .disabled(dataManager.selectedPage == nil)
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Menu")
    }
}
