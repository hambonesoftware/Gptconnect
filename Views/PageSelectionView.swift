import SwiftUI

struct PageSelectionView: View {
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            List(dataManager.pages) { page in
                Button(action: {
                    dataManager.selectedPage = page
                }) {
                    Text(page.title)
                }
            }
            .navigationTitle("Select a Page")
        }
    }
}
