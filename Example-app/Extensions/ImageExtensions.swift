//
//  ImageExtensions.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-07-13.
//  Copyright © 2022 Swedbank. All rights reserved.
//

import SwiftUI

extension Image {
    
    static let touchSize:CGFloat = 40
    
    func buttonImage() -> some View {
        self.resizable()
        .foregroundColor(.primary)
        .frame(width: Image.touchSize, height: Image.touchSize)
    }
}
