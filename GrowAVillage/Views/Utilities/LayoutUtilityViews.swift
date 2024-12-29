import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 10
    var shadowRadius: CGFloat = 1
    
    init(
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 10,
        shadowRadius: CGFloat = 1,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(radius: shadowRadius)
    }
}

struct Badge: View {
    let text: String
    let color: Color
    
    init(_ text: String, color: Color = .blue) {
        self.text = text
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

struct IconBadge: View {
    let systemImage: String
    let text: String
    let color: Color
    
    init(systemImage: String, text: String, color: Color = .blue) {
        self.systemImage = systemImage
        self.text = text
        self.color = color
    }
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
            Text(text)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .foregroundStyle(color)
        .clipShape(Capsule())
    }
}

struct DividerWithText: View {
    let text: String
    
    var body: some View {
        HStack {
            line
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
            line
        }
    }
    
    private var line: some View {
        VStack { Divider() }
    }
}

struct HeaderWithButton<ButtonLabel: View>: View {
    let title: String
    let subtitle: String?
    let buttonAction: () -> Void
    let buttonLabel: ButtonLabel
    
    init(
        _ title: String,
        subtitle: String? = nil,
        @ViewBuilder buttonLabel: () -> ButtonLabel,
        buttonAction: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttonLabel = buttonLabel()
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        HStack(alignment: subtitle == nil ? .center : .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: buttonAction) {
                buttonLabel
            }
        }
    }
}

#Preview("Layout Utilities") {
    ScrollView {
        VStack(spacing: 20) {
            CardView {
                Text("Card Content")
            }
            
            Badge("New")
            Badge("Warning", color: .orange)
            Badge("Error", color: .red)
            
            IconBadge(systemImage: "checkmark.circle.fill", text: "Done")
            IconBadge(systemImage: "exclamationmark.triangle.fill", text: "Warning", color: .orange)
            
            DividerWithText(text: "OR")
            
            HeaderWithButton("Section Title", subtitle: "Optional subtitle") {
                Image(systemName: "plus")
            } buttonAction: {
                // Button action
            }
        }
        .padding()
    }
}
