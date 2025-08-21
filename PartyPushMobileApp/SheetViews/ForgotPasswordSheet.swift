import SwiftUI

struct ForgotPasswordSheet: View {
    @Binding var email: String
    @Binding var isPresented: Bool
    @Binding var showResetCodeMessage: Bool

    var sessionManager: SessionManager

    @State private var resetStatus: String? = nil
    @State private var showResetPasswordSheet = false
    @State private var userForReset = AuthUser()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: Palette.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 15) {
                HStack {
                    Spacer()
                    DismissSheetButton {
                        isPresented = false
                    }
                }
                .padding(.top, 8)
                .padding(.trailing, 8)

                Text("Enter email")
                    .font(.system(size: 30, weight: .regular, design: .rounded))
                    .foregroundColor(Palette.deepTextColor)

                Text("Enter the email address associated with your account. We will send you a reset code which you can use to choose a new password.")
                    .font(.body)
                    .foregroundColor(Palette.deepTextColor)
                    .padding(.horizontal)

                CustomTextField(
                    text: $email,
                    placeholder: "Email"
                )
                .padding(.horizontal, 20)

                SubmitButton(title: "Send reset code") {
                    var user = AuthUser()
                    user.email = email

                    let result = sessionManager.sendPasswordResetCode(authUser: user)
                    resetStatus = result

                    if result == "Success" {
                        userForReset = user // save user for next sheet
                        showResetPasswordSheet = true
                    } else {
                        // Optional: error handling
                        print("Reset code failed: \(result)")
                    }
                }

                Spacer()
            }
            .padding()
            .sheet(isPresented: $showResetPasswordSheet) {
                PasswordResetSheet(authUser: userForReset, showPasswordResetView: $showResetPasswordSheet)
                    .environmentObject(sessionManager)
            }
        }
    }
}
