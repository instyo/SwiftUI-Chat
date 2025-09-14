//
//  RegisterView.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 14/09/25.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var auth: AuthViewModel

    @Binding var showingLogin: Bool
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Logo/Title
            VStack(spacing: 8) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Join us today")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Input Fields
            VStack(spacing: 16) {
                CustomTextField(title: "Full name", text: $fullName, type: .name)
                CustomTextField(title: "Email", text: $email, type: .email)
                CustomTextField(title: "Password", text: $password, type: .password)
                CustomTextField(title: "Confirm password", text: $confirmPassword, type: .password)
            }
            .padding(.horizontal)
            
            // Register Button
            Button(action: handleRegister) {
                HStack {
                    Text("Create Account")
                    if isLoading {
                        ProgressView()
                    }
                }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(!isFormValid)
            .opacity(isFormValid ? 1.0 : 0.6)
            
            Spacer()
            
            // Login Link
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.secondary)
                
                Button("Sign In") {
                    showingLogin = true
                }
                .foregroundColor(.blue)
                .fontWeight(.medium)
            }
            .padding(.bottom, 30)
        }
        .navigationBarHidden(true)
        .alert("Info", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("successful") {
                    // Clear form and go to login
                    clearForm()
                    showingLogin = true
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var isFormValid: Bool {
        !fullName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty
    }
    
    private func handleRegister() {
        // Validation
        guard !fullName.isEmpty else {
            alertMessage = "Please enter your full name"
            showAlert = true
            return
        }
        
        guard email.contains("@") && email.contains(".") else {
            alertMessage = "Please enter a valid email address"
            showAlert = true
            return
        }
        
        guard password.count >= 6 else {
            alertMessage = "Password must be at least 6 characters long"
            showAlert = true
            return
        }
        
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match"
            showAlert = true
            return
        }
        
        isLoading = true
        auth.signUp(email: email, password: password, displayName: fullName) { err in
            isLoading = false
            
            if let error = err {
                alertMessage = error.localizedDescription
                showAlert = true
            } else {
                print("Nice")
            }
        }
    }
    
    private func clearForm() {
        fullName = ""
        email = ""
        password = ""
        confirmPassword = ""
    }
}
