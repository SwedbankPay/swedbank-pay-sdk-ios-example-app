//
//  PaymentTokenSettings.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-07-15.
//

import SwiftUI

/// Set or get V2 payment tokens, by using the payer id.
struct PaymentTokenSettings: View {
    @EnvironmentObject var model: GeneralSettingsViewModel
    
    var body: some View {
        
        VStack {
            ZStack {
                HStack {
                    Spacer()
                    Button {
                        model.showGetTokenScreen = true
                    } label: {
                        Text("Get")
                            .foregroundColor(.accentColor)
                    }
                    .accessibilityIdentifier("ShowGetTokenScreen")
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
            .darkTextFieldLightMode()
        
                Toggle("Generate payment token", isOn: $model.generatePaymentToken)
                .tinted("GeneratePaymentTokenToggle")
            
                
        }.padding()
            .sheet(isPresented: $model.showGetTokenScreen) {
                getTokenScreen
            }
            .foregroundColor(.white)
    }
    
    var getTokenScreen: some View {
        VStack {
            
            HStack {
                Spacer()
                Button {
                    model.showGetTokenScreen = false
                } label: {
                    Image(systemName: "xmark.circle")
                        .buttonImage()
                        .padding()
                }
                .accessibilityIdentifier("CloseTokenScreen")
            }
            
            PayerReferenceSettings(blackBackground: false)
            VStack {
                Button {
                    model.fetchTokensV2()
                } label: {
                    Text("Get tokens")
                }
                .accessibilityIdentifier("FetchTokenButton")
                
                if model.loadingRequest {
                    ProgressView()
                }
                
                ForEach(model.paymentTokens, id: \.paymentToken) { token in
                    HStack {
                        VStack {
                            Text(token.instrument?.rawValue ?? "")
                            Text(token.instrumentDisplayName ?? "")
                        }
                        
                        VStack {
                            Button {
                                model.useToken(token)
                            } label: {
                                Text("Use")
                            }
                            .accessibilityIdentifier("UseTokenButton")
                            
                            Button {
                                model.deleteToken(token)
                            } label: {
                                Text("Delete")
                            }
                            
                        }
                        .foregroundColor(.accentColor)
                    }
                }
            }
            
            Spacer()
        }
        .foregroundColor(.black)
        .showAlert(model.tokenAlertTitle, model.tokenAlertBody, isPresented: $model.tokenAlertIsPresented)
    }
}

struct PaymentTokenSettings_Previews: PreviewProvider {
    static var previews: some View {
        PaymentTokenSettings()
            .environmentObject(GeneralSettingsViewModel())
            .background(Color.black)
    }
}
