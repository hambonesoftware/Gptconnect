import SwiftUI

struct DateInputView: View {
    @Binding var value: Date
    var title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            DatePicker("", selection: $value, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
        }
        .padding()
    }
}
