//
//  Colors.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 7/8/25.
//
import SwiftUI

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.98, green: 0.87, blue: 0.87),
                Color(red: 0.87, green: 0.93, blue: 0.96),
                Color(red: 0.91, green: 0.89, blue: 0.96)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct Palette {
    static let gradientColors = [
        Color(red: 0.18, green: 0.22, blue: 0.45),  // Lightened Navy
        Color(red: 0.33, green: 0.22, blue: 0.54),  // Lightened Deep Purple
        Color(red: 0.69, green: 0.26, blue: 0.38)   // Lightened Deep Red
    ]
    static let accentBlue = Color(red: 0.44, green: 0.62, blue: 0.93)
    static let accentPurple = Color(red: 0.65, green: 0.48, blue: 0.86)
    static let accentRed = Color(red: 0.96, green: 0.38, blue: 0.41)
    static let buttonBackground = Color(red: 0.32, green: 0.36, blue: 0.53)
    static let lighterButtonBackground = Color(red: 0.39, green: 0.41, blue: 0.60).opacity(0.7)
    static let deepTextColor = Color(red: 0.97, green: 0.97, blue: 1.00)
    static let placeholderColor = Color(red: 0.87, green: 0.89, blue: 0.98)
    static let mutedAccent = Color(red: 0.81, green: 0.71, blue: 0.88)
}
