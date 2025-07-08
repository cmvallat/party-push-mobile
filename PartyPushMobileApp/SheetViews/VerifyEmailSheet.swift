//
//  VerifyEmailSheet.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 7/8/25.
//

import SwiftUI

struct VerifyEmailSheet: View {
    @Binding var code: String
    @Binding var isPresented: Bool
    @Binding var showResendCodeMessage: Bool
    @Binding var resendCodeMessage: String
    
    var authUser: AuthUser
    var sessionManager: SessionManager
    var viewModel: SignUpPageViewModel

//    var onVerify: (String) -> Void

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
                        isPresented.toggle()
                    })
                }
                .padding(.top, 8)
                .padding(.trailing, 8)
                
                Text("Verify code")
                    .font(.system(size: 30, weight: .regular, design: .rounded))
                    .foregroundColor(Palette.deepTextColor)
                
                Text("Enter the verification code from your email")
                    .font(.body)
                    .foregroundColor(Palette.deepTextColor)
                
                Group{
                    CustomTextField(
                        text: $code,
                        placeholder: "Verification Code",
                    )
                }
                .padding(.horizontal, 20)
                
                SubmitButton(title: "Verify code", action: {
                    viewModel.verifyEmail(sessionManager: sessionManager, authUser: viewModel.authUser, confirmationCode: code)
                })
                
                SubmitButton(title: "Resend code", action: {
                    resendCodeMessage = sessionManager.resendCode(authUser: authUser)
                    if showResendCodeMessage {
                        showResendCodeMessage = false
                    }
                    withAnimation(.easeInOut(duration: 5)) {
                        showResendCodeMessage.toggle()
                    }
                })
                .alert(
                    resendCodeMessage,
                    isPresented: $showResendCodeMessage
                ) {
                    Button("Ok") {
                        showResendCodeMessage = false
                    }
                }
                Spacer()
            } // end of VStack
        } // end of ZStack
    }
}

#Preview {
    VerifyEmailSheet(
        code: .constant(""),
        isPresented: .constant(true),
        showResendCodeMessage: .constant(false),
        resendCodeMessage: .constant("Success!"),
        authUser: AuthUser(),
        sessionManager: SessionManager(),
        viewModel: SignUpPageViewModel()
    )
}

