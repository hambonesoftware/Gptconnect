import SwiftUI

struct TextInputView: View {
    @Binding var text: String
    var placeholder: String?
    var isValid: Bool
    
    var body: some View {
        TextField(placeholder ?? "Enter text", text: $text)
            .textFieldStyle(.roundedBorder)
            .overlay {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isValid ? .clear : .red, lineWidth: 1)
            }
    }
}

struct NumberInputView: View {
    @Binding var value: Double
    var placeholder: String?
    var isValid: Bool
    
    var body: some View {
        TextField(placeholder ?? "Enter number", value: $value, format: .number)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.decimalPad)
            .overlay {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isValid ? .clear : .red, lineWidth: 1)
            }
    }
}

struct DateInputView: View {
    @Binding var date: Date
    var isValid: Bool
    
    var body: some View {
        DatePicker(
            "",
            selection: $date,
            displayedComponents: [.date]
        )
        .labelsHidden()
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .stroke(isValid ? .clear : .red, lineWidth: 1)
        }
    }
}

struct ToggleInputView: View {
    @Binding var isOn: Bool
    var isValid: Bool
    
    var body: some View {
        Toggle("", isOn: $isOn)
            .labelsHidden()
            .tint(isValid ? .accentColor : .red)
    }
}

struct PickerInputView: View {
    @Binding var selection: String
    var options: [String]
    var isValid: Bool
    
    var body: some View {
        Picker("", selection: $selection) {
            ForEach(options, id: \.self) { option in
                Text(option).tag(option)
            }
        }
        .pickerStyle(.menu)
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .stroke(isValid ? .clear : .red, lineWidth: 1)
        }
    }
}

// MARK: - Previews
#Preview("Input Views") {
    VStack(spacing: 20) {
        TextInputView(
            text: .constant("Sample text"),
            placeholder: "Enter text",
            isValid: true
        )
        
        NumberInputView(
            value: .constant(42),
            placeholder: "Enter number",
            isValid: true
        )
        
        DateInputView(
            date: .constant(Date()),
            isValid: true
        )
        
        ToggleInputView(
            isOn: .constant(true),
            isValid: true
        )
        
        PickerInputView(
            selection: .constant("Option 1"),
            options: ["Option 1", "Option 2", "Option 3"],
            isValid: true
        )
    }
    .padding()
}
