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
    var onPartyJoined: () -> Void
    @StateObject private var viewModel = JoinPartySheetViewModel()
    
    var body: some View {
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
                viewModel.addGuest(authUser: authUser) {
                    showJoinPartyView.toggle()
                    onPartyJoined()
                    print("Joined party successfully.")
                }
            })
            Spacer()
        }
        .background(
            LinearGradient(
                colors: Palette.gradientColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}
