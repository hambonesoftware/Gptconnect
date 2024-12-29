import SwiftUI
import SwiftData

struct ModuleView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var module: Module
    @StateObject private var viewModel: ModuleViewModel
    
    init(module: Module) {
        self.module = module
        let dataManager = DataManager(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: ModuleViewModel(dataManager: dataManager, module: module))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
                .onTapGesture {
                    withAnimation {
                        module.isExpanded.toggle()
                    }
                }
            
            if module.isExpanded {
                componentsList
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 1)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.error?.localizedDescription ?? "An unknown error occurred")
        }
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(module.title)
                    .font(.headline)
                
                Text("\(module.components.count) components")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: module.isExpanded ? "chevron.up" : "chevron.down")
                .foregroundStyle(.secondary)
        }
    }
    
    private var componentsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(module.components) { component in
                ComponentView(component: component)
                
                if component.id != module.components.last?.id {
                    Divider()
                }
            }
        }
    }
}

#Preview {
    let module = Module(
        title: "Sample Module",
        components: [
            Component(type: .text, title: "Name", value: AnyCodable("")),
            Component(type: .number, title: "Age", value: AnyCodable(0.0)),
            Component(type: .date, title: "Birthday", value: AnyCodable(Date()))
        ]
    )
    
    return ScrollView {
        ModuleView(module: module)
            .padding()
    }
    .previewWith(.sample)
}
