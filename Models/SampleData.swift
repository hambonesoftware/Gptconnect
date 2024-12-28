import Foundation

let sampleComponents = [
    Component(id: UUID(), type: .text, title: "Name", value: AnyCodable("")),
    Component(id: UUID(), type: .text, title: "Secret Name", value: AnyCodable("")),
    Component(id: UUID(), type: .number, title: "Age", value: AnyCodable(0.0)),
    Component(id: UUID(), type: .date, title: "Birthday", value: AnyCodable(Date())),
    Component(id: UUID(), type: .toggle, title: "Subscribe", value: AnyCodable(false)),
    Component(id: UUID(), type: .picker, title: "Gender", value: AnyCodable("Option 1"))
]

let sampleModules = [
    Module(id: UUID(), title: "Personal Information", components: sampleComponents)
]

let samplePage = Page(id: UUID(), title: "User Profile", modules: sampleModules)
