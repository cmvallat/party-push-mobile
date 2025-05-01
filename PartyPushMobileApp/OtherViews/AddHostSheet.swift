//
//  AddHostSheet.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 9/15/24.
//

import SwiftUI

struct AddHostSheet: View {
    let authUser: AuthUser
    @Binding var showAddPartyView: Bool
    var onPartyAdded: () -> Void
    @StateObject private var viewModel = AddHostViewModel()

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { showAddPartyView.toggle() }) {
                    Label("", systemImage: "xmark.circle.fill")
                }
            }
            .padding(.top, 5)

            Spacer()

            Text("Create New Party")
                .multilineTextAlignment(.center)
                .font(.title)
                .padding([.leading, .trailing], 15)

            TextField("Party Name", text: $viewModel.partyName)
                .textFieldStyle(.roundedBorder)
                .padding([.leading, .trailing], 15)

            TextField("Party Code", text: $viewModel.partyCode)
                .textFieldStyle(.roundedBorder)
                .padding([.leading, .trailing], 15)

            Toggle(isOn: $viewModel.inviteOnly) {
                Text("Private party")
            }
            .toggleStyle(StyleHelpers.CheckboxToggleStyle())
            .padding()

            Button {
                viewModel.addHost(authUser: authUser) {
                    showAddPartyView.toggle()
                    onPartyAdded() // Reload the parties after successful creation
                }
            } label: {
                Label("Submit", systemImage: "arrowshape.turn.up.forward.fill")
                    .tint(Color(red: 0, green: 0.65, blue: 0))
            }
            .disabled(viewModel.isLoading)

            Spacer()
        }
        .background(Gradient(colors: [.blue, .pink]).opacity(0.2))
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView("Creating party...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
            }
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }
}


//#Preview {
//    AddHostSheet(authUser: AuthUser(), showAddPartyView: .constant(true))
//}
