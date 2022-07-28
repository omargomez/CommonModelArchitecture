//
//  View+Extensions.swift
//  MoneyRates
//
//  Created by Omar Gomez on 21/6/22.
//

import SwiftUI
import Foundation

extension Color {
    
#if os(macOS)
    static let buttonFillColor = Color(NSColor.systemGray)
    static let buttonPressedColor = Color(NSColor.controlAccentColor)
    static let textFieldBorderStrokeColor = Color(NSColor.shadowColor)
#else
    static let buttonFillColor = Color(UIColor.systemGray5)
    static let textFieldBorderStrokeColor = Color(UIColor.systemGray5)
    static let viewBackground = Color(UIColor.systemBackground)
    static let label = Color(UIColor.label)
#endif
}

#if os(iOS)
fileprivate struct AppButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 64.0)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.buttonFillColor)
            )
        
    }
}
#endif

#if os(macOS)
fileprivate struct AppButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: 64.0)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ?
                        Color.buttonPressedColor :
                            Color.buttonFillColor)
            .foregroundColor(Color.white)
            .font(.system(size: 28, weight: .light, design: .default))
            .cornerRadius(8)
    }
}
#endif

fileprivate struct AppEmbeddedListButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .font(configuration.isPressed ? Font.headline : Font.body)
#if os(iOS)
            .background(Color.viewBackground)
#endif
    }
}

fileprivate struct AppTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 64.0)
            .multilineTextAlignment(.center)
            .textFieldStyle(.plain)
            .font(.system(size: 32, weight: .regular, design: .default))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.textFieldBorderStrokeColor)
            )
    }
}

extension View {
    func appButtonStyle() -> some View {
        #if os(iOS)
        self.modifier(AppButtonModifier())
        #else
        buttonStyle(AppButtonStyle())
        #endif
    }
    
    func appTextFieldStyle() -> some View {
        self.modifier(AppTextFieldModifier())
    }
    
    func appEmbeddedListButtonStyle() -> some View {
        buttonStyle(AppEmbeddedListButtonStyle())
    }
    
    func appDialogTitleStyle() -> some View {
        self.font(Font.headline)
            .padding(.bottom, 8)
    }

    func appDialogButtonStyle() -> some View {
        self.buttonStyle(.borderedProminent)
    }
}
