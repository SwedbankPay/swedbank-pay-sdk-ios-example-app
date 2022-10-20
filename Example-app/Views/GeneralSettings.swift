//
//  GeneralSettings.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-07-13.
//

import SwiftUI

/// The "main" general settings view, to control payer id, tokens, instruments and other minor settings.
struct GeneralSettings: View {
    @ObservedObject var model: GeneralSettingsViewModel
    @Namespace private var generalSettingsNamespace
    
    var body: some View {
        ZStack {
            main
                .frame(maxHeight: model.showCell ? .infinity : 100, alignment: .topLeading)
                .opacity(model.showCell ? 1 : 0)
            
            HStack {
                hiddenBody
                    .background(Color.black)
                    .cornerRadius(40)
                    .offset(x: 0, y: 4)
                    .opacity(model.showCell ? 0 : 1)
                
                Spacer()
            }
            .frame(maxHeight: model.showCell ? .infinity : 100, alignment: .topLeading)
        }
        .cornerRadius(20)
    }
    
    var main: some View {
        VStack {
            closeButtonCountrySelector
            InstrumentModeSelector()
            Divider().overlay(Color.white)
                .padding(.horizontal)
            PayerReferenceSettings(blackBackground: true)
            Divider().overlay(Color.white)
                .padding(.horizontal)
            PaymentTokenSettings()
            Divider().overlay(Color.white)
                .padding(.horizontal)
            GeneralToggleSettings()
            
            Spacer()
        }
        .regularFont()
        .environmentObject(model)
        .foregroundColor(.white)
        .background(Color.black)
    }
    
    var showViewButton: some View {
        Button {
            withAnimation(.easeOut) {
                model.showCell = !model.showCell
            }
        } label: {
            Image(systemName: "gear")
                .buttonImage()
        }
        .rotationEffect(.degrees(model.showCell ? 180 : 0))
        .foregroundColor(.white)
        .background(Color.black)
        .accessibilityIdentifier("CogButton")
        .matchedGeometryEffect(id: "Cog", in: generalSettingsNamespace, isSource: false)
    }
    
    var hiddenBody: some View {
        VStack {
            HStack {
                showViewButton
            }
            .padding()
        }
    }
    
    var closeButtonCountrySelector: some View {
        HStack {
            showViewButton
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
                            .foregroundColor(.primary).colorInvert()
                    }
                    Spacer()
                    Button {
                        model.selectedCountry = .Norway
                    } label: {
                        Text("Norway")
                            .selectedText(model.selectedCountry == .Norway)
                            .foregroundColor(.primary).colorInvert()
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
    
    static var model = GeneralSettingsViewModel()
    
    static var previews: some View {
        ScrollView {
            GeneralSettings(model: model)
                .frame(alignment: .topLeading)
        }
        .background(Color.gray)
        .padding()
        .padding(.horizontal)
        .onAppear {
            withAnimation {
                model.showCell = true
            }
        }
    }
}
