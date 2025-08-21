//
//  JoinPartySheet.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 7/7/25.
//

import SwiftUI

struct JoinPartySheet: View {
    let authUser: AuthUser
    @Binding var showJoinPartyView: Bool
    @ObservedObject var appState: AppState
    var onPartyJoined: () -> Void
    @EnvironmentObject var sessionManager: SessionManager
    @State private var lastSavedHost: Host? = nil

    @StateObject private var viewModel = JoinPartySheetViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: Palette.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack(spacing: 22) {
                HStack {
                    Spacer()
                    DismissSheetButton(onDismiss: {
                        showJoinPartyView = false
                    })
                }
                .padding(.top, 8)
                .padding(.trailing, 8)
                
                Text("Join a Party")
                    .font(.system(.title, weight: .bold))
                    .foregroundColor(Palette.deepTextColor)
                    .padding(.bottom, 8)
                
                VStack(spacing: 16) {
                    Group {
                        CustomTextField(text: $viewModel.partyCode, placeholder: "Party Code")
                        CustomTextField(text: $viewModel.guestName, placeholder: "Your Name")
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.horizontal, 0)
                
                SubmitButton(action: {
                    dismissKeyboard()
                    viewModel.getHost { host in
                        guard let host = host else { return } // errorMessage is already set in the view model so it will alert
                        lastSavedHost = host
                        viewModel.addGuest(authUser: authUser) {
                            sessionManager.showGuest(host: host, authUser: authUser, appState: appState)
                            showJoinPartyView.toggle()
                            onPartyJoined()
                        }
                    }
                })
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
//                ZStack {
//                    Color.black.opacity(0.7).ignoresSafeArea()
//                    ProgressView("Joining party...")
////                        .foregroundColor(.white)
////                        .padding()
////                        .background(Color.black.opacity(0.8))
////                        .cornerRadius(12)
////                        .shadow(radius: 10)
//                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
//                }
                ProgressOverlay(message: "Joining party...")
            }
        }
    }
}
