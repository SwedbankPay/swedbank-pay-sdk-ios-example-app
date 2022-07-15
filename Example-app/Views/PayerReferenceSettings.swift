//
//  PayerReferenceSettings.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-07-13.
//

import SwiftUI

/// Generate a payer reference to be used in the next purchase
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

struct PayerReferenceSettings_Previews: PreviewProvider {
    static var previews: some View {
        PayerReferenceSettings()
            .environmentObject(GeneralSettingsViewModel())
            .preferredColorScheme(.dark)
    }
}
