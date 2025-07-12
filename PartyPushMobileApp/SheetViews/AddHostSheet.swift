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
    @ObservedObject var appState: AppState
    var onPartyAdded: () -> Void
    @StateObject private var viewModel = AddHostSheetViewModel()
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        ZStack {
            LinearGradient(
                colors: Palette.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
            .ignoresSafeArea()

            VStack(spacing: 15) {
                HStack {
                    Spacer()
                    DismissSheetButton(onDismiss: {
                        showAddPartyView.toggle()
                    })
                }
                .padding(.top, 8)
                .padding(.trailing, 8)

                Text("Create New Party")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(Palette.deepTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Group {
                    CustomTextField(text: $viewModel.partyName, placeholder: "Party Name")
                    CustomTextField(text: $viewModel.partyCode, placeholder: "Party Code")
                    CustomTextField(text: $viewModel.desc, placeholder: "Description (optional)")
                }
                .padding(.horizontal, 20)
                
                SubmitButton(action: {
                    dismissKeyboard()
                    viewModel.addHost(authUser: authUser) {
                        // recreate the Host object that was created in the VM to call DB
                        let host = Host(username: authUser.username, party_name: viewModel.partyName, party_code: viewModel.partyCode, invite_only: 1)
                        
                        // clear values to we start the new view with a clean appState
                        appState.endedPartyCode = nil
                        appState.kickedGuestUsername = nil
                        appState.needToRefresh = false
                        
                        // show the new view and dismiss the sheet
                        sessionManager.showHost(host: host, authUser: authUser, appState: appState)
                        showAddPartyView.toggle()
                        onPartyAdded() // Reload the parties after successful creation
                    }})

                Spacer()
            }
        }
        .overlay(loadingOverlay)
        .alert("Error", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
                .foregroundColor(Palette.deepTextColor)
        }
    }

    private var loadingOverlay: some View {
        Group {
            if viewModel.isLoading {
                ProgressOverlay(message: "Creating party...")
            }
        }
    }
}

//#Preview {
//    AddHostSheet(authUser: AuthUser(), showAddPartyView: .constant(true)) {}
//}
