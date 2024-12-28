import SwiftUI

struct PageEditorView: View {
    @Binding var page: Page
    
    var body: some View {
        Form {
            Section(header: Text("Page Title")) {
                TextField("Title", text: $page.title)
            }
            ForEach($page.modules) { $module in
                Section(header: Text(module.title)) {
                    ForEach($module.components) { $component in
                        switch component.type {
                        case .text:
                            TextField(component.title, text: Binding(
                                get: { component.value.value as? String ?? "" },
                                set: { component.value.value = $0 }
                            ))
                        case .number:
                            TextField(component.title, value: Binding(
                                get: { component.value.value as? Double ?? 0.0 },
                                set: { component.value.value = $0 }
                            ), formatter: NumberFormatter())
                        case .date:
                            DatePicker(component.title, selection: Binding(
                                get: { component.value.value as? Date ?? Date() },
                                set: { component.value.value = $0 }
                            ))
                        case .toggle:
                            Toggle(component.title, isOn: Binding(
                                get: { component.value.value as? Bool ?? false },
                                set: { component.value.value = $0 }
                            ))
                        case .picker:
                            Picker(component.title, selection: Binding(
                                get: { component.value.value as? String ?? "Option 1" },
                                set: { component.value.value = $0 }
                            )) {
                                Text("Option 1").tag("Option 1")
                                Text("Option 2").tag("Option 2")
                                Text("Option 3").tag("Option 3")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Edit Page")
    }
}
