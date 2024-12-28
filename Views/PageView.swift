import SwiftUI

struct PageView: View {
    @Binding var page: Page
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(page.title)
                    .font(.largeTitle)
                ForEach(page.modules) { module in
                    ModuleView(module: module)
                }
            }
            .padding()
        }
    }
}
