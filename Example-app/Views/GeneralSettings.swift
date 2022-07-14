//
//  GeneralSettings.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-07-13.
//  Copyright © 2022 Swedbank. All rights reserved.
//

import SwiftUI

struct PaymentTokenSettings: View {
    @EnvironmentObject var model: GeneralSettingsViewModel
    
    var body: some View {
        
        VStack {
            ZStack {
                HStack {
                    Spacer()
                    Button {
                        
                    } label: {
                        Text("Get")
                    }
                }
                .padding(.horizontal)
                
                Text("Payment Token")
                    .padding(.bottom, 5)
            }
            .frame(maxWidth: .infinity)
            
            TextField("Enter payment token", text: $model.paymentTokenText) {
                print("On commit - hide keyboard")
                self.resignFirstResponder()
            }
            .disableAutocorrection(true)
            .darkModeTextField()
            
            Toggle("Generate payment token", isOn: $model.generatePaymentToken)
            
        }.padding()
    }
}

struct GeneralSettings: View {
    @ObservedObject var model: GeneralSettingsViewModel
    @State var showInstrumentSheet = false
    
    var body: some View {
        VStack {
            closeButtonCountrySelector
            if #available(iOS 16.0, *) {
                instrumentModeSheet14
            } else {
                instrumentModeSheet14
            }
            PayerReferenceSettings()
            PaymentTokenSettings()
            
            Spacer()
        }
        .preferredColorScheme(.dark)
        .regularFont()
        .environmentObject(model)
    }
    
    /*
     Let's do this upgrade when iOS 16 is out of beta:
    @State private var settingsDetent = PresentationDetent.medium
    @available(iOS 16.0, *)
     /// the modal sheet to change instrument
    var instrumentModeSheet16: some View {
        instrumentModeSelector
        .sheet(isPresented: $showInstrumentSheet) {
            instrumentSheetView
                .presentationDetents(
                    [.medium, .large],
                    selection: $settingsDetent
                )
        }
    }
    */
    
    var instrumentModeSelector: some View {
        VStack {
            Button {
                showInstrumentSheet = true
            } label: {
                Text("Instrument mode (tap to change)")
                    .foregroundColor(.primary)
            }
            Text(model.selectedInstrument.name.capitalized)
        }
    }
    
    /// the modal sheet to change instrument, for ios 14, 15
    var instrumentModeSheet14: some View {
        instrumentModeSelector
            .sheet(isPresented: $showInstrumentSheet) {
                instrumentSheetView
            }
    }
    
    var instrumentSheetView: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    showInstrumentSheet = false
                } label: {
                    Image(systemName: "xmark.circle")
                        .buttonImage()
                        .padding()
                }
            }
            Spacer()
            Picker("Instrument", selection: $model.selectedInstrument) {
                ForEach(PaymentViewModel.shared.instrumentOptions, id: \.self.name) { option in
                    Text(option.name).tag(option)
                }
            }.pickerStyle(.wheel)
        }.preferredColorScheme(.dark)
    }
    
    var closeButtonCountrySelector: some View {
        HStack {
            Button {
                model.showCell = true
            } label: {
                Image(systemName: "gear")
                    .buttonImage()
            }
            Spacer()
            VStack(spacing: 10) {
                Text("Country")
                HStack {
                    Spacer()
                    Button {
                        model.selectedCountry = .Sweden
                    } label: {
                        Text("Sweden")
                            .selectedText(model.selectedCountry == .Sweden)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Button {
                        model.selectedCountry = .Norway
                    } label: {
                        Text("Norway")
                            .selectedText(model.selectedCountry == .Norway)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
            }
            .offset(x: -Image.touchSize/2, y: 0)
            
            Spacer()
        }.padding()
        
    }
}

struct GeneralSettings_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettings(model: GeneralSettingsViewModel())
    }
}
