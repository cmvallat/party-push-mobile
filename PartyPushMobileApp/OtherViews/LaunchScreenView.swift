//
//  LaunchScreenView.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 6/30/25.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.5

    var body: some View {
        ZStack {
            AppBackground()

            VStack {
                Image("LoadingImageTransparent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300) // Adjust size as needed
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.smooth(duration: 2)) {
                            scale = 1.1
                            opacity = 1.0
                        }
                    }
                
                Text("Getting the party started...")
                    .font(.headline)
                    .padding(.top, 20)
//                    .color(Color.red)

            }
        }
    }
}
