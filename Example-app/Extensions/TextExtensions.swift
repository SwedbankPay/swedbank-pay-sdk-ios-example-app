//
//  TextExtensions.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-07-13.
//

import SwiftUI

extension View {
    func selectedFont() -> some View {
        self.font(.custom("IBMPlexMono-Bold", size: 14))
    }
    
    func regularFont() -> some View {
        font(.custom("IBMPlexMono-Medium", size: 14))
    }
}

extension Text {
    
    func selectedText(_ selected: Bool) -> some View {
        self.if(selected) {
            $0.underline().selectedFont()
        }
    }
}
