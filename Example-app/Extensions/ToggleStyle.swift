//
//  ToggleStyle.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-08-03.
//  Copyright © 2022 Swedbank. All rights reserved.
//

import SwiftUI

/**
 Since we can't control switches off color, so we build our own
 Usage:
 Toggle("Test wrong hostURL", isOn: $model.testWrongHostUrl)
     .tinted()
 */
struct ColoredToggleStyle: ToggleStyle {
    var onColor = Color.accentColor
    var offColor = Color.gray
    var thumbColor = Color.white
    let accessibilityIdentifier: String
    
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Button(action: { configuration.isOn.toggle() } )
            {
                RoundedRectangle(cornerRadius: 16, style: .circular)
                    .fill(configuration.isOn ? onColor : offColor)
                    .frame(width: 50, height: 29)
                    .overlay(
                        Circle()
                            .fill(thumbColor)
                            .shadow(radius: 1, x: 0, y: 1)
                            .padding(1.5)
                            .offset(x: configuration.isOn ? 10 : -10))
                    .animation(Animation.easeInOut(duration: 0.2))
            }
            .accessibilityIdentifier(accessibilityIdentifier)
        }
    }
}

extension Toggle {
    func tinted(_ accessibilityIdentifier: String = "") -> some View {
        toggleStyle(ColoredToggleStyle(accessibilityIdentifier: accessibilityIdentifier))
    }
}
