//
//  HOST.swift
//  PartyPushMobileApp
//
//  Created by Nicholas Georgiou on 3/12/25.
//

import SwiftUI

struct NicksLoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack {
            Section(header: Text("Log In to My Account").font(.largeTitle)) {
                Divider()
                    .padding(.vertical)
                TextField(
                    "Username",
                    text: $username
                )
                  .textFieldStyle(.roundedBorder)
                  .font(.title)
                  .frame(width: 300)
                TextField(
                    "Password",
                    text: $password
                )
                  .textFieldStyle(.roundedBorder)
                  .font(.title)
                  .frame(width: 300)
                Button("Log In") {
                    
                }
                  .foregroundColor(.white)
                  .frame(maxWidth: 300, maxHeight: 45)
                  .font(.headline)
                  .background(.blue)
                  .clipShape(RoundedRectangle(cornerRadius: 5))
                  
                Button("Forgot Password?") {
                    
                }
                  .foregroundColor(.blue)
                  .frame(maxWidth: 300, maxHeight: 45)
                  .clipShape(RoundedRectangle(cornerRadius: 5))
                  .overlay(
                      RoundedRectangle(cornerRadius: 6)
                          .stroke(.blue, lineWidth: 2)
                  )
                
            }
        }
        .frame(
              minWidth: 0,
              maxWidth: .infinity,
              minHeight: 0,
              maxHeight: .infinity,
              alignment: .topLeading
            )
        .padding(.vertical)
        .background(Color(uiColor: UIColor.systemGray6))
    }
}

#Preview {
    NicksLoginView()
}
