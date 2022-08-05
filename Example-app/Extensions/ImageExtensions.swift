//
//  ImageExtensions.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-07-13.
//

import SwiftUI

extension Image {
    
    static let touchSize:CGFloat = 40
    
    func buttonImage() -> some View {
        self.resizable()
        .frame(width: Image.touchSize, height: Image.touchSize)
    }
}
