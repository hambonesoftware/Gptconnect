import SwiftUI

struct PickerInputView: View {
    @Binding var value: String
    var title: String
    var options: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            Picker(selection: $value, label: Text(title)) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
        .padding()
    }
}
