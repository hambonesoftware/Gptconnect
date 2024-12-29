import SwiftUI
import SwiftData

struct ComponentView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var component: Component
    @StateObject private var viewModel: ComponentViewModel
    
    init(component: Component) {
        self.component = component
        let dataManager = DataManager(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: ComponentViewModel(dataManager: dataManager, component: component))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(component.title)
                    .font(.headline)
                
                if component.configuration?.isRequired == true {
                    Text("*")
                        .foregroundColor(.red)
                        .font(.headline)
                }
                
                Spacer()
                
                if !component.isValid {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                }
            }
            
            inputView
            
            if let helperText = component.configuration?.helperText {
                Text(helperText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if !component.isValid {
                Text(component.configuration?.errorMessage ?? "Invalid input")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.error?.localizedDescription ?? "An unknown error occurred")
        }
    }
    
    @ViewBuilder
    private var inputView: some View {
        switch component.type {
        case .text:
            TextInputView(
                text: $viewModel.stringValue,
                placeholder: component.configuration?.placeholder,
                isValid: component.isValid
            )
            
        case .number:
            NumberInputView(
                value: $viewModel.numberValue,
                placeholder: component.configuration?.placeholder,
                isValid: component.isValid
            )
            
        case .date:
            DateInputView(
                date: $viewModel.dateValue,
                isValid: component.isValid
            )
            
        case .toggle:
            ToggleInputView(
                isOn: $viewModel.boolValue,
                isValid: component.isValid
            )
            
        case .picker:
            PickerInputView(
                selection: $viewModel.stringValue,
                options: component.pickerOptions,
                isValid: component.isValid
            )
        }
    }
}

#Preview {
    let component = Component(
        type: .text,
        title: "Sample Component",
        value: AnyCodable("Sample Value"),
        configuration: ComponentConfiguration(
            isRequired: true,
            placeholder: "Enter value",
            helperText: "This is a helper text"
        )
    )
    
    return VStack {
        ComponentView(component: component)
        Divider()
        ComponentView(component: Component(type: .number, title: "Age", value: AnyCodable(25)))
        Divider()
        ComponentView(component: Component(type: .date, title: "Birthday", value: AnyCodable(Date())))
    }
    .padding()
    .previewWith(.sample)
}
