import SwiftUI

struct NumberInputView: View {
    @Binding var value: Double
    var title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            TextField("Enter number", value: $value, formatter: NumberFormatter())
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }
}
