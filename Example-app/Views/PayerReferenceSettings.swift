//
//  PayerReferenceSettings.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-07-13.
//  Copyright © 2022 Swedbank. All rights reserved.
//

import SwiftUI


struct PayerReferenceSettings: View {
    @EnvironmentObject var model: GeneralSettingsViewModel
    var body: some View {
        VStack {
            Text("Payer Reference")
                .padding(.bottom, 5)
            HStack {
                Spacer()
                Button {
                    PaymentViewModel.shared.payerReference = UUID().uuidString
                    model.refreshPayerReference()
                } label: {
                    Text("Generate")
                }
                Spacer()
                Button {
                    PaymentViewModel.shared.setPayerReferenceToLastUsed()
                    model.refreshPayerReference()
                } label: {
                    Text("Last used")
                }
                Spacer()
            }
            
            TextField("Enter payer reference", text: $model.payerReferenceText) {
                print("On commit - hide keyboard")
                self.resignFirstResponder()
            }
            .disableAutocorrection(true)
            .darkModeTextField()
            
        }.padding()
    }
}
