import SwiftUI

struct ToggleInputView: View {
    @Binding var value: Bool
    var title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            Toggle(isOn: $value) {
                Text(title)
            }
        }
        .padding()
    }
}
