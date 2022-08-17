//
//  StyleSettings.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-08-15.
//  Copyright © 2022 Swedbank. All rights reserved.
//

import SwiftUI

class StyleSettingsModel: ObservableObject {
    @Published var styleText = PaymentViewModel.shared.styleText {
        didSet {
            PaymentViewModel.shared.styleText = styleText
            refreshError()
        }
    }
    
    @Published var hasError: Bool = false
    @Published var isShown = false
    
    func refreshError() {
        let vm = PaymentViewModel.shared
        hasError = !vm.trimmedStyleText.isEmpty && vm.style == nil
    }
}

struct StyleSettings: View {
    
    @ObservedObject var model: StyleSettingsModel
    @State var labelWidth:CGFloat = 100
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Button {
                    withAnimation(.easeIn) {
                        model.isShown = !model.isShown
                    }
                } label: {
                    Text("Style")
                        .regularFont()
                    
                }
                
                if model.isShown {
                    Spacer()
                    Button {
                        withAnimation(.easeIn) {
                            model.isShown = false
                        }
                    } label: {
                        Image("Icon-X")
                            .foregroundColor(.white)
                    }
                }
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: model.isShown ? .infinity : labelWidth, alignment: .leading)
            
            if model.isShown {
                main
                    .transition(.fold)
                    .background(Color.black)
            }
        }
        .background(Color.black)
        .cornerRadius(15)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var main: some View {
        VStack {
            HStack {
                Text("Error with input")
                    .foregroundColor(.red)
                    .opacity(model.hasError ? 1 : 0)
                Spacer()
                Button {
                    self.resignFirstResponder()
                } label: {
                    Text("Done")
                }
            }
            
            TextEditor(text: $model.styleText)
                .background(Color.white)
                .frame(minHeight: 400)
        }
        .padding()
    }
}

struct StyleSettings_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            StyleSettings(model: StyleSettingsModel())
        }
    }
}
