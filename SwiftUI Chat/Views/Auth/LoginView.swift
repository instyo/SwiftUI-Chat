//
//  LoginView.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 14/09/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel

    @Binding var showingLogin: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Logo/Title
            VStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Sign in to your account")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Input Fields
            VStack(spacing: 16) {
                CustomTextField(title: "Email", text: $email, type: .email, isRequired: true)
                CustomTextField(title: "Password", text: $password, type: .password, isRequired: true)
            }
            .padding(.horizontal)
            
            // Login Button
            Button(action: handleLogin) {
                HStack {
                    Text("Sign In")
                    if isLoading {
                        ProgressView()
                    }
                }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(email.isEmpty || password.isEmpty || isLoading)
            .opacity(email.isEmpty || password.isEmpty || isLoading ? 0.6 : 1.0)
            
            Spacer()
            
            // Register Link
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.secondary)
                
                Button("Sign Up") {
                    showingLogin = false
                }
                .foregroundColor(.blue)
                .fontWeight(.medium)
            }
            .padding(.bottom, 30)
        }
        .navigationBarHidden(true)
        .alert("Info", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleLogin() {
        // Basic validation
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in all fields"
            showAlert = true
            return
        }
        
        guard email.contains("@") && email.contains(".") else {
            alertMessage = "Please enter a valid email address"
            showAlert = true
            return
        }
        
        isLoading = true
        
        auth.signIn(email: email, password: password) { err in
            isLoading = false
            
            if let error = err {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
}

