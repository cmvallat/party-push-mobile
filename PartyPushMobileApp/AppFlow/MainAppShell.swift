import SwiftUI

// Entry point for all authenticated (logged-in) users. Wraps HomePage, HostFoodManagementPage, and GuestManagementPage in a persistent NavigationSplitView sidebar.
struct MainAppShell<Content: View>: View {
    let authUser: AuthUser
    @ObservedObject var appState: AppState
    @EnvironmentObject var sessionManager: SessionManager

    let content: () -> Content

    @State private var showSidebar = false
    @State private var showDeleteAccountConfirmation = false
    @State private var showLogoutConfirmation = false
    @State private var showPrivacyPolicySheet = false

    @State private var isDeletingAccount = false
    @State private var deleteAccountError: String? = nil

    var body: some View {
        ZStack(alignment: .topLeading) {
            content()
                .disabled(showSidebar)
                .blur(radius: showSidebar ? 2 : 0)
            
            Button {
                withAnimation {
                    showSidebar.toggle()
                }
            } label: {
                Image(systemName: "gearshape")
                    .imageScale(.large)
                    .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            }
            .zIndex(1)
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 0))
            
            if showSidebar {
                HStack(spacing: 0) {
                    sidebar
                        .frame(width: sidebarWidth)
                        .background(
                            LinearGradient(
                                colors: Palette.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .transition(.move(edge: .leading))
                        .zIndex(1)
                    Spacer(minLength: 0)
                }
                .background(Color.black.opacity(0.4).ignoresSafeArea())
                .onTapGesture {
                    withAnimation {
                        showSidebar = false
                    }
                }
                .zIndex(2)
            }
            
            if isDeletingAccount {
//                Color.black.opacity(0.4)
//                    .ignoresSafeArea()
//                    .zIndex(3)
//                ProgressView("Deleting account...")
//                    .padding()
//                    .background(.ultraThinMaterial)
//                    .cornerRadius(10)
//                    .zIndex(4)
                ProgressOverlay(message: "Deleting account...")
            }
        }
        .alert("Are you sure you want to delete your account? This will delete you account and all account data, and cannot be undone.", isPresented: $showDeleteAccountConfirmation) {
            Button("Delete Account", role: .destructive) {
                if !isDeletingAccount {
                    isDeletingAccount = true
                    APIService.deleteAllUserData(authUser: authUser) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                sessionManager.deleteCurrentUser(authUser: authUser) { deleteResult in
                                    DispatchQueue.main.async {
                                        isDeletingAccount = false
                                        if case .failure(let error) = deleteResult {
                                            deleteAccountError = error.localizedDescription
                                        }
                                    }
                                }
                            case .failure(let error):
                                isDeletingAccount = false
                                deleteAccountError = "Failed to delete user data: \(error.localizedDescription)"
                            }
                        }
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Are you sure you want to log out?", isPresented: $showLogoutConfirmation) {
            Button("Log Out", role: .destructive) {
                sessionManager.logout(authUser: authUser)
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Account Deletion Failed", isPresented: Binding<Bool>(
            get: { deleteAccountError != nil },
            set: { _ in deleteAccountError = nil }
        )) {
            Button("Cancel", role: .cancel) {}
        } message: {
            if let error = deleteAccountError {
                Text(error)
            }
        }
        .sheet(isPresented: $showPrivacyPolicySheet) {
            SafariView(url: URL(string: "https://livepartyhelper.com/privacy.html")!)
        }
    }

    var sidebarWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth < 450 ? screenWidth * 0.6 : 270
    }

    var sidebar: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        showSidebar = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                        .padding()
                }
            }
            Button("Privacy Policy") {
                showPrivacyPolicySheet = true
                withAnimation {
                    showSidebar = false
                }
            }
            .padding(.horizontal)
            Divider()
            Button(role: .destructive) {
                showDeleteAccountConfirmation = true
                withAnimation {
                    showSidebar = false
                }
            } label: {
                Text("Delete Account")
            }
            .padding(.horizontal)
            Button(role: .cancel) {
                showLogoutConfirmation = true
                withAnimation {
                    showSidebar = false
                }
            } label: {
                Text("Log Out")
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding(.top, 10)
    }
}

// Simple SafariView for web links (Privacy Policy)
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController { SFSafariViewController(url: url) }
    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}

#Preview {
    let mockUser = AuthUser()
    let mockAppState = AppState()
    let sessionManager = SessionManager()
    return MainAppShell(authUser: mockUser, appState: mockAppState) {
        Text("Main app content")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
    }
    .environmentObject(sessionManager)
}
