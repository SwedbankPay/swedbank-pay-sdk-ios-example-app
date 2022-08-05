//
//  InstrumentModeSelector.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-07-15.
//  Copyright © 2022 Swedbank. All rights reserved.
//

import SwiftUI

/// Go into instrument mode by selecting a specific instrument. 
struct InstrumentModeSelector: View {
    
    @EnvironmentObject var model: GeneralSettingsViewModel
    @State var showInstrumentSheet = false
    
    var body: some View {
        VStack {
            Button {
                showInstrumentSheet = true
            } label: {
                VStack {
                    Text("Instrument mode (tap to change)")
                    Text(model.selectedInstrument.name.capitalized)
                }
                .foregroundColor(.primary).colorInvert()
            }
            TextField("Restrict to instruments", text: $model.restrictedToInstrumentsText) {
                print("On commit - hide keyboard")
                self.resignFirstResponder()
            }
            .disableAutocorrection(true)
            .darkTextFieldLightMode()
            .padding(.bottom)
        }
        .padding()
        //the modal sheet to change instrument, for ios 13 - 15
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
            
            if model.showCustomInstrumentInput {
                TextField("Custom instrument", text: $model.customInstrument) {
                    print("On commit - hide keyboard")
                    self.resignFirstResponder()
                }
                .disableAutocorrection(true)
                .darkTextFieldLightMode()
                .padding()
            }
            
            Picker("Instrument", selection: $model.selectedInstrument) {
                ForEach(PaymentViewModel.shared.instrumentOptions, id: \.self.name) { option in
                    Text(option.name).tag(option)
                }
            }.pickerStyle(.wheel)
        }
            
    }
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

struct InstrumentModeSelector_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentModeSelector()
            .environmentObject(GeneralSettingsViewModel())
            .background(Color.black)
    }
}
