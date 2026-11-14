import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showRegister = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("GeoCircle")
                            .font(.title2.weight(.bold))
                        Text("Sign in to track your group geofences and receive location alerts.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Account")) {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.password)
                }
                
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button {
                        Task { await viewModel.submit() }
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("Sign In")
                                    .fontWeight(.medium)
                            }
                            Spacer()
                        }
                    }
                    .disabled(!viewModel.isInputValid || viewModel.isLoading)
                }
                
                Section {
                    Button("Create a new account") {
                        showRegister = true
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Sign In")
            .sheet(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
}
