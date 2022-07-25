//
//  View+Extensions.swift
//  MoneyRates
//
//  Created by Omar Gomez on 21/6/22.
//

import SwiftUI
import Foundation

private extension Color {
    
#if os(iOS)
    static let buttonFillColor = Color(UIColor.systemGray5)
    static let textFieldBorderStrokeColor = Color(UIColor.systemGray5)
#else
    static let buttonFillColor = Color(NSColor.shadowColor)
    static let textFieldBorderStrokeColor = Color(NSColor.shadowColor)
#endif
}

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
        self.modifier(AppButtonModifier())
    }
    
    func appTextFieldStyle() -> some View {
        self.modifier(AppTextFieldModifier())
    }
}
