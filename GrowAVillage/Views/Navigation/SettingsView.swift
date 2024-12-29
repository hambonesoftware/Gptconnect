import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: SettingsViewModel
    
    init() {
        let dataManager = DataManager(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: SettingsViewModel(dataManager: dataManager))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    ForEach(viewModel.userPreferences.keys.sorted(), id: \.self) { key in
                        TextField(key, text: Binding(
                            get: { viewModel.userPreferences[key] as? String ?? "" },
                            set: { viewModel.updatePreference(key: key, value: $0) }
                        ))
                    }
                }
                Button("Reset to Defaults") {
                    viewModel.resetPreferences()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
