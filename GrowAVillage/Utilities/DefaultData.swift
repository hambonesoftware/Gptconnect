import Foundation
import SwiftData

struct DefaultDataProvider {
    static func createDefaultData(in context: ModelContext) {
        createDefaultTemplates(in: context)
        createDefaultPages(in: context)
    }
    
    static func createDefaultTemplates(in context: ModelContext) {
        // Personal Information Template
        let personalComponents = [
            Component(
                type: .text,
                title: "Full Name",
                value: AnyCodable(""),
                configuration: ComponentConfiguration(
                    isRequired: true,
                    placeholder: "Enter your full name",
                    helperText: "Your legal full name"
                )
            ),
            Component(
                type: .date,
                title: "Date of Birth",
                value: AnyCodable(Date()),
                configuration: ComponentConfiguration(
                    isRequired: true,
                    helperText: "Your date of birth"
                )
            ),
            Component(
                type: .picker,
                title: "Gender",
                value: AnyCodable("Prefer not to say"),
                configuration: ComponentConfiguration(
                    pickerOptions: ["Male", "Female", "Non-binary", "Prefer not to say"]
                )
            )
        ]
        
        let personalModule = Module(
            title: "Personal Information",
            components: personalComponents
        )
        
        // Contact Information Template
        let contactComponents = [
            Component(
                type: .text,
                title: "Email",
                value: AnyCodable(""),
                configuration: ComponentConfiguration(
                    isRequired: true,
                    placeholder: "Enter your email",
                    helperText: "Your primary email address"
                )
            ),
            Component(
                type: .text,
                title: "Phone",
                value: AnyCodable(""),
                configuration: ComponentConfiguration(
                    placeholder: "Enter your phone number",
                    helperText: "Your contact phone number"
                )
            ),
            Component(
                type: .picker,
                title: "Preferred Contact",
                value: AnyCodable("Email"),
                configuration: ComponentConfiguration(
                    pickerOptions: ["Email", "Phone", "Either"]
                )
            )
        ]
        
        let contactModule = Module(
            title: "Contact Information",
            components: contactComponents
        )
        
        // Preferences Template
        let preferencesComponents = [
            Component(
                type: .toggle,
                title: "Receive Newsletter",
                value: AnyCodable(false),
                configuration: ComponentConfiguration(
                    helperText: "Subscribe to our newsletter"
                )
            ),
            Component(
                type: .toggle,
                title: "Email Notifications",
                value: AnyCodable(true),
                configuration: ComponentConfiguration(
                    helperText: "Receive email notifications"
                )
            )
        ]
        
        let preferencesModule = Module(
            title: "Preferences",
            components: preferencesComponents
        )
        
        // Create Templates
        let templates = [
            Page(
                title: "Basic Profile",
                modules: [personalModule],
                isTemplate: true
            ),
            Page(
                title: "Full Profile",
                modules: [personalModule, contactModule, preferencesModule],
                isTemplate: true
            ),
            Page(
                title: "Contact Form",
                modules: [contactModule],
                isTemplate: true
            )
        ]
        
        templates.forEach { context.insert($0) }
    }
    
    static func createDefaultPages(in context: ModelContext) {
        let sampleComponents = [
            Component(
                type: .text,
                title: "Sample Text",
                value: AnyCodable("Sample Value"),
                configuration: ComponentConfiguration(
                    isRequired: true,
                    placeholder: "Enter text",
                    helperText: "This is a sample text field"
                )
            ),
            Component(
                type: .number,
                title: "Sample Number",
                value: AnyCodable(42),
                configuration: ComponentConfiguration(
                    placeholder: "Enter number"
                )
            )
        ]
        
        let sampleModule = Module(
            title: "Sample Module",
            components: sampleComponents
        )
        
        let samplePage = Page(
            title: "Welcome Page",
            modules: [sampleModule],
            isTemplate: false
        )
        
        context.insert(samplePage)
    }
}
