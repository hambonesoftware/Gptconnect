import SwiftUI
import SwiftData

struct ComponentEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ComponentEditorViewModel
    
    init(component: Component) {
        let dataManager = DataManager(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: ComponentEditorViewModel(dataManager: dataManager, component: component))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Component Details") {
                    TextField("Title", text: $viewModel.title)
                    
                    Text(viewModel.componentType.displayName)
                        .foregroundStyle(.secondary)
                }
                
                Section("Configuration") {
                    Toggle("Required", isOn: $viewModel.isRequired)
                    
                    TextField("Placeholder", text: $viewModel.placeholder)
                    
                    TextField("Helper Text", text: $viewModel.helperText)
                }
                
                if case .picker = viewModel.componentType {
                    Section("Picker Options") {
                        ForEach($viewModel.pickerOptions.indices, id: \.self) { index in
                            HStack {
                                TextField("Option \(index + 1)", text: $viewModel.pickerOptions[index])
                                
                                Button {
                                    viewModel.removeOption(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        Button("Add Option") {
                            viewModel.addOption()
                        }
                    }
                }
                
                Section("Validation") {
                    Toggle("Custom Error Message", isOn: $viewModel.hasCustomError)
                    
                    if viewModel.hasCustomError {
                        TextField("Error Message", text: $viewModel.errorMessage)
                    }
                    
                    switch viewModel.componentType {
                    case .text:
                        textValidationRules
                    case .number:
                        numberValidationRules
                    case .date:
                        dateValidationRules
                    case .toggle, .picker:
                        EmptyView()
                    }
                }
            }
            .navigationTitle("Edit Component")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.save()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.error?.localizedDescription ?? "An unknown error occurred")
        }
    }
    
    private var textValidationRules: some View {
        Group {
            Toggle("Minimum Length", isOn: $viewModel.hasMinLength)
            if viewModel.hasMinLength {
                Stepper("Min Length: \(viewModel.minLength)", value: $viewModel.minLength, in: 1...100)
            }
            
            Toggle("Maximum Length", isOn: $viewModel.hasMaxLength)
            if viewModel.hasMaxLength {
                Stepper("Max Length: \(viewModel.maxLength)", value: $viewModel.maxLength, in: 1...1000)
            }
            
            Toggle("Regex Pattern", isOn: $viewModel.hasRegex)
            if viewModel.hasRegex {
                TextField("Pattern", text: $viewModel.regexPattern)
            }
        }
    }
    
    private var numberValidationRules: some View {
        Group {
            Toggle("Minimum Value", isOn: $viewModel.hasMinValue)
            if viewModel.hasMinValue {
                TextField("Min Value", value: $viewModel.minValue, format: .number)
                    .keyboardType(.decimalPad)
            }
            
            Toggle("Maximum Value", isOn: $viewModel.hasMaxValue)
            if viewModel.hasMaxValue {
                TextField("Max Value", value: $viewModel.maxValue, format: .number)
                    .keyboardType(.decimalPad)
            }
        }
    }
    
    private var dateValidationRules: some View {
        Group {
            Toggle("Minimum Date", isOn: $viewModel.hasMinDate)
            if viewModel.hasMinDate {
                DatePicker("Min Date", selection: $viewModel.minDate, displayedComponents: .date)
            }
            
            Toggle("Maximum Date", isOn: $viewModel.hasMaxDate)
            if viewModel.hasMaxDate {
                DatePicker("Max Date", selection: $viewModel.maxDate, displayedComponents: .date)
            }
        }
    }
}

#Preview {
    ComponentEditorView(
        component: PreviewContainer.sample.container.mainContext.fetch(FetchDescriptor<Component>()).first!
    )
    .modelContainer(PreviewContainer.sample.container)
}
