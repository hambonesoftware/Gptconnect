import SwiftUI

struct FormHeaderView: View {
    let title: String
    let subtitle: String?
    
    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct FormRow: View {
    let label: String
    let systemImage: String?
    let value: String
    
    init(_ label: String, value: String, systemImage: String? = nil) {
        self.label = label
        self.value = value
        self.systemImage = systemImage
    }
    
    var body: some View {
        HStack {
            if let systemImage {
                Label(label, systemImage: systemImage)
            } else {
                Text(label)
            }
            
            Spacer()
            
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

struct FormRowNavigationLink<Destination: View>: View {
    let label: String
    let systemImage: String?
    @ViewBuilder let destination: () -> Destination
    
    init(_ label: String, systemImage: String? = nil, @ViewBuilder destination: @escaping () -> Destination) {
        self.label = label
        self.systemImage = systemImage
        self.destination = destination
    }
    
    var body: some View {
        NavigationLink {
            destination()
        } label: {
            if let systemImage {
                Label(label, systemImage: systemImage)
            } else {
                Text(label)
            }
        }
    }
}

struct FormSectionHeader: View {
    let text: String
    let systemImage: String?
    let color: Color?
    
    init(_ text: String, systemImage: String? = nil, color: Color? = nil) {
        self.text = text
        self.systemImage = systemImage
        self.color = color
    }
    
    var body: some View {
        HStack {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(color ?? .primary)
            }
            
            Text(text.uppercased())
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color ?? .primary)
        }
    }
}

struct FormValidationMessage: View {
    let type: MessageType
    let text: String
    
    enum MessageType {
        case error
        case warning
        case info
        
        var systemImage: String {
            switch self {
            case .error: "exclamationmark.triangle"
            case .warning: "exclamationmark.circle"
            case .info: "info.circle"
            }
        }
        
        var color: Color {
            switch self {
            case .error: .red
            case .warning: .orange
            case .info: .blue
            }
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: type.systemImage)
            Text(text)
        }
        .font(.caption)
        .foregroundStyle(type.color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(type.color.opacity(0.1))
        .cornerRadius(6)
    }
}

#Preview("Form Utilities") {
    Form {
        Section {
            FormHeaderView("Personal Information", subtitle: "Basic user details")
            FormRow("Name", value: "John Doe", systemImage: "person")
            FormRow("Age", value: "30")
        }
        
        Section(header: FormSectionHeader("Account", systemImage: "person.circle", color: .blue)) {
            FormRowNavigationLink("Settings", systemImage: "gear") {
                Text("Settings")
            }
        }
        
        Section {
            VStack(alignment: .leading) {
                FormValidationMessage(type: .error, text: "Required field is missing")
                FormValidationMessage(type: .warning, text: "Password is weak")
                FormValidationMessage(type: .info, text: "Profile is 80% complete")
            }
        }
    }
}
