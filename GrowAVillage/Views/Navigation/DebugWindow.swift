import SwiftUI

struct DebugWindow: View {
    @Environment(\.modelContext) private var modelContext
    @State private var debugMessages: [String] = []
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            Button("Toggle Debug") {
                isExpanded.toggle()
            }
            if isExpanded {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(debugMessages, id: \.self) { message in
                            Text(message).font(.caption).foregroundColor(.gray)
                        }
                    }
                }
                .frame(maxHeight: 200)
                .padding()
                .background(Color.black.opacity(0.8))
            }
        }
        .onAppear {
            loadDebugMessages()
        }
    }
    
    private func loadDebugMessages() {
        // Simulating fetching debug messages
        debugMessages = ["Debug message 1", "Debug message 2", "Debug message 3"]
    }
}
