import SwiftUI

//struct DeepLinkPartyCode: Identifiable, Equatable {
//    let code: String
//    var id: String { code }
//}

struct HomePage: View {
    @EnvironmentObject var sessionManager: SessionManager
    let authUser: AuthUser
    @ObservedObject var appState: AppState
    
    @State private var showHostSheet = false
    @State private var showJoinSheet = false
    @State private var showLogoutConfirmation = false
    
//    @State private var pendingDeepLinkPartyCode: DeepLinkPartyCode? = nil

    
    // For Join Party sheet
    @State private var partyCode = ""
    @State private var guestName = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: Palette.gradientColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                VStack(spacing: 6) {
                    Text("Party Push")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(Palette.deepTextColor)
                    
                    Rectangle()
                        .frame(width: 80, height: 3)
                        .foregroundColor(Palette.accentRed)
                        .cornerRadius(1.5)
                }
                .padding(.top, 64)
                
                Spacer()
                
                // main image
                Image(systemName: "music.note.house.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .foregroundColor(Palette.accentBlue)
                    .shadow(color: Palette.accentBlue.opacity(0.6), radius: 8, x: 0, y: 3)
                    .padding(.bottom, 16)
                
                Spacer()
                
                // join and add buttons
                VStack(spacing: 20) {
                    Button(action: { showJoinSheet = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Palette.accentBlue)
                            Text("Join Party")
                                .font(.system(.title2, weight: .bold))
                                .foregroundColor(Palette.deepTextColor)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Palette.lighterButtonBackground)
                        .cornerRadius(25)
                        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
                    }
                    
                    Button(action: { showHostSheet = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Palette.accentPurple)
                            Text("Host Party")
                                .font(.system(.title2, weight: .bold))
                                .foregroundColor(Palette.deepTextColor)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Palette.lighterButtonBackground)
                        .cornerRadius(25)
                        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer(minLength: 0)
                
                // Logout button
                Button(action: { showLogoutConfirmation = true }) {
                    Text("Log Out")
                        .font(.system(.headline, weight: .semibold))
                        .foregroundColor(Palette.mutedAccent)
                }
                .padding(.bottom, 36)
                .alert("Are you sure you want to log out?", isPresented: $showLogoutConfirmation) {
                    Button("Log Out", role: .destructive) {
                        sessionManager.logout(authUser: authUser)
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
            // sheets
            .sheet(isPresented: $showHostSheet) {
                AddHostSheet(authUser: authUser, showAddPartyView: $showHostSheet, appState: appState) {
                }
                .background(
                    LinearGradient(
                        colors: Palette.gradientColors,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
                .presentationDetents([.large])
            }
            .sheet(isPresented: $showJoinSheet) {
                JoinPartySheet(authUser: authUser, showJoinPartyView: $showJoinSheet, appState: appState, onPartyJoined: {
                })
                    .presentationDetents([.large])
                    .background(
                        LinearGradient(
                            colors: Palette.gradientColors,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()
                    )
            }
            .onOpenURL { url in
                print("SwiftUI onOpenURL called with: \(url)")
                if let code = extractPartyCode(from: url) {
                    partyCode = code
                    showJoinSheet = true
                }
            }
            .onChange(of: appState.needToRefresh, initial: false) { _, refresh in
                if(refresh)
                {
                    appState.endedPartyCode = nil
                    appState.kickedGuestUsername = nil
                    appState.needToRefresh = false
                }
            }
        }
    }
    
    func extractPartyCode(from url: URL) -> String? {
        let components = url.pathComponents
        if components.count >= 3 && components[1] == "join-party" {
            return components[2]
        }
        return nil
    }
}

//#Preview {
//    TestNewUIView(authUser: AuthUser(), appState: AtPartyStatus(.active))
//        .environmentObject(SessionManager())
//}
