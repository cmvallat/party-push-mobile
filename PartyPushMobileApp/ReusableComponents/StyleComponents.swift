//
//  StyleComponents.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/4/24.
//

import Foundation
import SwiftUI

class StyleHelpers{
    struct ActionButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .background(Color(red: 0, green: 0.5, blue: 0))
                .foregroundStyle(.white)
                .cornerRadius(10)
        }
    }
    
    struct GlassView: View {
        let cornerRadius: CGFloat
        let fill: Color
        let opacity: CGFloat
        let shadowRadius: CGFloat

        init(cornerRadius: CGFloat, fill: Color = .white, opacity: CGFloat = 0.25, shadowRadius: CGFloat = 10.0) {
            self.cornerRadius = cornerRadius
            self.fill = fill
            self.opacity = opacity
            self.shadowRadius = shadowRadius
        }

        var body: some View {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(fill)
                .opacity(opacity)
                .shadow(radius: shadowRadius)
        }
    }

    struct GlassModifier: ViewModifier {
        let cornerRadius: CGFloat
        let fill: Color
        let opacity: CGFloat
        let shadowRadius: CGFloat

        func body(content: Content) -> some View {
            content
                .background {
                    GlassView(cornerRadius: cornerRadius, fill: fill, opacity: opacity, shadowRadius: shadowRadius)}
        }
    }
    
    struct CheckboxToggleStyle: ToggleStyle {
      func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
          configuration.label
          Spacer()
          Image(systemName: configuration.isOn ? "checkmark.square" : "square")
            .resizable()
            .frame(width: 24, height: 24)
            .onTapGesture { configuration.isOn.toggle() }
        }
      }
    }
    
    struct CustomButton: View {
        var label: String
        var color: String
        
        var body: some View {
            Button(label) {
                
            }
              .foregroundColor(.white)
              .frame(maxWidth: 300, maxHeight: 45)
              .font(.headline)
              .background(.blue)
              .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }
}
