//
//  GeneralToggleSettings.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-07-15.
//

import SwiftUI

/// A place for boolean settings rarely used but which allws useful tests 
struct GeneralToggleSettings: View {
    @EnvironmentObject var model: GeneralSettingsViewModel
    
    var body: some View {
        VStack {
            
            Toggle("Use V2 payments", isOn: $model.useV2Payments)
                .tinted()
                .accessibilityIdentifier("toggleUseV2")
            
            Toggle("Disable payment menu", isOn: $model.disablePaymentMenu)
                .tinted()
            
            Toggle("Always use Safari", isOn: $model.useSafari)
                .tinted()
            
            Toggle("Allow all redirects", isOn: $model.allowAllRedirects)
                .tinted()
            
            Toggle("Test wrong hostURL", isOn: $model.testWrongHostUrl)
                .tinted()
                
            
            TextField("Subsite", text: $model.subsiteText) {
                print("On commit - hide keyboard")
                self.resignFirstResponder()
            }
            .disableAutocorrection(true)
            .darkTextFieldLightMode()
        }
        .foregroundColor(.white)
        .padding()
    }
}

struct GeneralToggleSettings_Previews: PreviewProvider {
    static var previews: some View {
        GeneralToggleSettings()
            .environmentObject(GeneralSettingsViewModel())
            .background(Color.black)
    }
}
