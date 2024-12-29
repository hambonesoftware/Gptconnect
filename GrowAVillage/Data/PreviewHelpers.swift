import SwiftUI
import SwiftData

struct PreviewContainer {
    let container: ModelContainer
    
    init(_ types: any PersistentModel.Type...) {
        let schema = Schema(types)
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create preview container: \(error.localizedDescription)")
        }
    }
    
    func add(_ items: any PersistentModel...) {
        items.forEach { container.mainContext.insert($0) }
    }
}

extension PreviewContainer {
    static var sample: PreviewContainer {
        let container = PreviewContainer(Page.self, Module.self, Component.self)
        
        // Create sample data
        let textComponent = Component(
            type: .text,
            title: "Name",
            value: AnyCodable("John Doe"),
            configuration: ComponentConfiguration(
                isRequired: true,
                placeholder: "Enter your name",
                helperText: "Your full name"
            )
        )
        
        let numberComponent = Component(
            type: .number,
            title: "Age",
            value: AnyCodable(30),
            configuration: ComponentConfiguration(
                isRequired: true,
                placeholder: "Enter your age"
            )
        )
        
        let dateComponent = Component(
            type: .date,
            title: "Birthday",
            value: AnyCodable(Date()),
            configuration: ComponentConfiguration(
                isRequired: true,
                helperText: "Your date of birth"
            )
        )
        
        let toggleComponent = Component(
            type: .toggle,
            title: "Subscribe",
            value: AnyCodable(false),
            configuration: ComponentConfiguration(
                helperText: "Receive notifications"
            )
        )
        
        let pickerComponent = Component(
            type: .picker,
            title: "Gender",
            value: AnyCodable("Male"),
            configuration: ComponentConfiguration(
                isRequired: true,
                pickerOptions: ["Male", "Female", "Other"]
            )
        )
        
        let personalInfoModule = Module(
            title: "Personal Information",
            components: [textComponent, numberComponent, dateComponent]
        )
        
        let preferencesModule = Module(
            title: "Preferences",
            components: [toggleComponent, pickerComponent]
        )
        
        let page = Page(
            title: "User Profile",
            modules: [personalInfoModule, preferencesModule]
        )
        
        let template = Page(
            title: "Profile Template",
            modules: [personalInfoModule],
            isTemplate: true
        )
        
        container.add(page, template)
        return container
    }
}

extension View {
    func previewWith(_ container: PreviewContainer) -> some View {
        self.modelContainer(container.container)
    }
}

#if DEBUG
extension PreviewContainer {
    static func createSampleData(in context: ModelContext) {
        // Create the same sample data as above
        let textComponent = Component(
            type: .text,
            title: "Name",
            value: AnyCodable("John Doe"),
            configuration: ComponentConfiguration(
                isRequired: true,
                placeholder: "Enter your name",
                helperText: "Your full name"
            )
        )
        
        let numberComponent = Component(
            type: .number,
            title: "Age",
            value: AnyCodable(30),
            configuration: ComponentConfiguration(
                isRequired: true,
                placeholder: "Enter your age"
            )
        )
        
        let module = Module(
            title: "Personal Information",
            components: [textComponent, numberComponent]
        )
        
        let page = Page(
            title: "User Profile",
            modules: [module]
        )
        
        context.insert(page)
    }
}
