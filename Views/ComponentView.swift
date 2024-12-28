import SwiftUI

struct ComponentView: View {
    var component: Component
    
    var body: some View {
        switch component.type {
        case .text:
            if let value = component.value.value as? String {
                TextInputView(value: .constant(value), title: component.title)
            } else {
                Text("Invalid value for text input")
            }
        case .number:
            if let value = component.value.value as? Double {
                NumberInputView(value: .constant(value), title: component.title)
            } else {
                Text("Invalid value for number input")
            }
        case .date:
            if let value = component.value.value as? Date {
                DateInputView(value: .constant(value), title: component.title)
            } else {
                Text("Invalid value for date input")
            }
        case .toggle:
            if let value = component.value.value as? Bool {
                ToggleInputView(value: .constant(value), title: component.title)
            } else {
                Text("Invalid value for toggle input")
            }
        case .picker:
            if let value = component.value.value as? String {
                PickerInputView(value: .constant(value), title: component.title, options: ["Option 1", "Option 2", "Option 3"])
            } else {
                Text("Invalid value for picker input")
            }
        }
    }
}
