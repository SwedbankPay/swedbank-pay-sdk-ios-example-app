//
//  ConsumerSettingsView.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-08-04.
//  Copyright © 2022 Swedbank. All rights reserved.
//

import SwiftUI

class ConsumerSettingsViewModel: ObservableObject {
    @Published var selected: ConsumerType = ConsumerViewModel.shared.getConsumerType() {
        didSet {
            ConsumerViewModel.shared.setConsumerType(selected)
        }
    }
    
    @Published var prefillEmail = ConsumerViewModel.shared.prefillEmail {
        didSet {
            ConsumerViewModel.shared.prefillEmail = prefillEmail
            selected = .Prefill
        }
    }
    
    @Published var prefillMsisdn = ConsumerViewModel.shared.prefillMsisdn {
        didSet {
            ConsumerViewModel.shared.prefillMsisdn = prefillMsisdn
            selected = .Prefill
        }
    }
    
    @Published var prefillProfileRef = ConsumerViewModel.shared.prefillProfileRef {
        didSet {
            ConsumerViewModel.shared.prefillProfileRef = prefillProfileRef
            selected = .Prefill
        }
    }
    
    @Published var isShown = false
}

struct ConsumerSettingsView: View {
    @ObservedObject var consumerModel: ConsumerSettingsViewModel
    @State var labelWidth:CGFloat = 100
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Button {
                    withAnimation(.easeIn) {
                        consumerModel.isShown = !consumerModel.isShown
                    }
                } label: {
                    Text("Consumer")
                        .regularFont()
                    
                }
                
                if consumerModel.isShown {
                    Spacer()
                    Button {
                        withAnimation(.easeIn) {
                            consumerModel.isShown = false
                        }
                    } label: {
                        Image("Icon-X")
                            .foregroundColor(.white)
                    }
                }
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: consumerModel.isShown ? .infinity : labelWidth, alignment: .leading)
            
            if consumerModel.isShown {
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
            Basic2ColumnGrid(count: ConsumerType.allCases.count, content: consumerType)
            .foregroundColor(.primary).colorInvert()
            .regularFont()
            .padding()
            
            VStack {
                TextField("Email", text: $consumerModel.prefillEmail)
                    .darkTextFieldLightMode()
                TextField("Phone number", text: $consumerModel.prefillMsisdn)
                    .darkTextFieldLightMode()
                TextField("Profile reference", text: $consumerModel.prefillProfileRef)
                    .darkTextFieldLightMode()
            }
            .padding()
        }
        .background(Color.black)
    }
    
    func consumerType(_ index: Int) -> some View {
        let item = ConsumerType.allCases[index]
        return Button {
            consumerModel.selected = item
        } label: {
            Text(item.displayName)
                .selectedText(consumerModel.selected == item)
                .frame(width: 150)
                .frame(maxHeight: 40)
        }
        .frame(alignment: .center)
    }
}

struct ConsumerSettingsView_Previews: PreviewProvider {
    static var consumerModel = ConsumerSettingsViewModel()
    
    static var previews: some View {
        ScrollView {
            ConsumerSettingsView(consumerModel: consumerModel)
        }
    }
}
