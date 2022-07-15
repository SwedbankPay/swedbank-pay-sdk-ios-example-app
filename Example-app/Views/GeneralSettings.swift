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
    
    @ViewBuilder
    var body: some View {
        main
            .opacity(model.showCell ? 1 : 0)
        hiddenBody
            .opacity(model.showCell ? 0 : 1)
    }
    
    var main: some View {
        VStack {
            closeButtonCountrySelector
            InstrumentModeSelector()
            Divider().overlay(Color.primary)
                .padding(.horizontal)
            PayerReferenceSettings()
            Divider().overlay(Color.primary)
                .padding(.horizontal)
            PaymentTokenSettings()
            Divider().overlay(Color.primary)
                .padding(.horizontal)
            GeneralToggleSettings()
            
            Spacer()
        }
        .preferredColorScheme(.dark)
        .regularFont()
        .environmentObject(model)
    }
    
    @ViewBuilder
    var showViewButton: some View {
        if #available(iOS 14.0, *) {
            showViewButtonInner
                .matchedGeometryEffect(id: "Cog", in: generalSettingsNamespace)
        } else {
            showViewButtonInner
        }
    }
    
    var showViewButtonInner: some View {
        Button {
            withAnimation(.easeOut) {
                model.showCell = !model.showCell
            }
        } label: {
            Image(systemName: "gear")
                .buttonImage()
        }
        .rotationEffect(.degrees(model.showCell ? 180 : 0))
    }
    
    var hiddenBody: some View {
        VStack {
            HStack {
                showViewButton
                Spacer()
            }
            .padding()
            Spacer()
        }
        .preferredColorScheme(.dark)
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
        ScrollView {
            GeneralSettings(model: GeneralSettingsViewModel())
        }
    }
}
