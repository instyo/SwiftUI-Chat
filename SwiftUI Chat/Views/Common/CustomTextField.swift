//
//  InputType.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 14/09/25.
//


import SwiftUI

// MARK: - Input Type Enum
enum InputType {
    case name
    case text
    case email
    case password
    case number
    case phone
    case search
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .email:
            return .emailAddress
        case .number:
            return .numberPad
        case .phone:
            return .phonePad
        default:
            return .default
        }
    }
    
    var textContentType: UITextContentType? {
        switch self {
        case .email:
            return .emailAddress
        case .password:
            return .password
        case .phone:
            return .telephoneNumber
        default:
            return nil
        }
    }
    
    var autocapitalization: TextInputAutocapitalization {
        switch self {
        case .email:
            return .never
        case .password:
            return .never
        default:
            return .sentences
        }
    }
}

// MARK: - Custom TextField View
struct CustomTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let type: InputType
    let isRequired: Bool
    
    @State private var isSecured = true
    @State private var isEditing = false
    @FocusState private var isFocused: Bool
    
    init(
        title: String,
        placeholder: String = "",
        text: Binding<String>,
        type: InputType = .text,
        isRequired: Bool = false
    ) {
        self.title = title
        self.placeholder = placeholder.isEmpty ? title : placeholder
        self._text = text
        self.type = type
        self.isRequired = isRequired
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title with required indicator
            if !title.isEmpty {
                HStack(spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    if isRequired {
                        Text("*")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                    }
                }
            }
            
            // Input field container
            HStack(spacing: 12) {
                // Leading icon
                if let icon = iconForType {
                    Image(systemName: icon)
                        .foregroundColor(isFocused ? .accentColor : .secondary)
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 20)
                }
                
                // Text field
                Group {
                    if type == .password && isSecured {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .textFieldStyle(PlainTextFieldStyle())
                .keyboardType(type.keyboardType)
                .textContentType(type.textContentType)
                .textInputAutocapitalization(type.autocapitalization)
                .autocorrectionDisabled(type == .email || type == .password)
                .focused($isFocused)
                .onChange(of: isFocused) { focused in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditing = focused
                    }
                }
                
                // Trailing button (password visibility toggle)
                if type == .password {
                    Button(action: { isSecured.toggle() }) {
                        Image(systemName: isSecured ? "eye.slash" : "eye")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Clear button for other types
                else if !text.isEmpty && isFocused {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isFocused ? Color.accentColor : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .scaleEffect(isFocused ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isFocused)
        }
    }
    
    private var iconForType: String? {
        switch type {
        case .name:
            return "person"
        case .email:
            return "envelope"
        case .password:
            return "lock"
        case .phone:
            return "phone"
        case .search:
            return "magnifyingglass"
        case .number:
            return "number"
        default:
            return "text.cursor"
        }
    }
}
