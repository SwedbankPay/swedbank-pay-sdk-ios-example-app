//
//  ViewExtensions.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-07-13.
//

import SwiftUI

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder
    func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
    
    
    /// Give textfields a white background, padding and rounded corners so people can see that it is a textfield
    /// Works best in darkMode
    func darkModeTextField() -> some View {
        self
        .foregroundColor(.primary)
        .padding()
        .background(RoundedRectangle(cornerRadius: 15.0).fill(Color.primary).colorInvert())
        .colorInvert()
    }
    
    /// The only way to hide the keyboard in SwiftUI pre iOS 15, now we can use @FocusState
    func resignFirstResponder() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
    
    /// A version indipendent alert
    @ViewBuilder
    func showAlert(_ title: String, _ body: String, isPresented: Binding<Bool>) -> some View {
        if #available(iOS 15.0, *) {
            self.alert(title, isPresented: isPresented, actions: {}) {
                Text(body)
            }
        } else {
            self.alert(isPresented: isPresented) {
                Alert(title: Text(title), message: Text(body))
            }
        }
    }
}
