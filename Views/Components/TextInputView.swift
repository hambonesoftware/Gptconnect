import SwiftUI

struct TextInputView: View {
    @Binding var value: String
    var title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            TextField("Enter text", text: $value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }
}
