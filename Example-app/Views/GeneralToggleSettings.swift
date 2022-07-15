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
            
            Toggle("Disable payment menu", isOn: $model.disablePaymentMenu)
            Toggle("Always use Safari", isOn: $model.useSafari)
            Toggle("Allow all redirects", isOn: $model.allowAllRedirects)
            Toggle("Test wrong hostURL", isOn: $model.testWrongHostUrl)
            
            TextField("Subsite", text: $model.subsiteText) {
                print("On commit - hide keyboard")
                self.resignFirstResponder()
            }
            .disableAutocorrection(true)
            .darkModeTextField()
        }.padding()
    }
}

struct GeneralToggleSettings_Previews: PreviewProvider {
    static var previews: some View {
        GeneralToggleSettings()
            .environmentObject(GeneralSettingsViewModel())
            .preferredColorScheme(.dark)
    }
}
