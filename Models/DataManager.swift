import Foundation

class DataManager: ObservableObject {
    @Published var pages: [Page] = []
    @Published var selectedPage: Page?
    @Published var isEditing: Bool = false
    
    func loadPages() {
        print("Loading pages data from file.")
        if let loadedPages: [Page] = PersistenceManager.shared.load("pages.json", as: [Page].self) {
            self.pages = loadedPages
            print("Pages data loaded successfully.")
        } else {
            print("Failed to load pages data. Creating default pages data.")
            createDefaultPagesData()
            savePages() // Save the default pages data if loading fails
        }
    }
    
    func savePages() {
        print("Saving pages data to file.")
        PersistenceManager.shared.save(pages, to: "pages.json")
        print("Pages data saved successfully.")
    }
    
    private func createDefaultPagesData() {
        let sampleComponents = [
            Component(id: UUID(), type: .text, title: "Name", value: AnyCodable("")),
            Component(id: UUID(), type: .number, title: "Age", value: AnyCodable(0.0)),
            Component(id: UUID(), type: .date, title: "Birthday", value: AnyCodable(Date())),
            Component(id: UUID(), type: .toggle, title: "Subscribe", value: AnyCodable(false)),
            Component(id: UUID(), type: .picker, title: "Gender", value: AnyCodable("Option 1"))
        ]
        
        let sampleModules = [
            Module(id: UUID(), title: "Personal Information", components: sampleComponents)
        ]
        
        let samplePage1 = Page(id: UUID(), title: "User Profile 1", modules: sampleModules)
        let samplePage2 = Page(id: UUID(), title: "User Profile 2", modules: sampleModules)
        
        self.pages = [samplePage1, samplePage2]
        print("Default pages data created with actual UUIDs.")
    }
}
