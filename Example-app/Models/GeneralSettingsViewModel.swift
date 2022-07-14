//
//  GeneralSettingsViewModel.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-07-13.
//  Copyright © 2022 Swedbank. All rights reserved.
//

import Foundation

class GeneralSettingsViewModel: ObservableObject {
    
    @Published var showCell: Bool = false
    
    @Published var selectedInstrument: PaymentViewModel.InstrumentOption = .disabled
    @Published var selectedCountry: Country = .Sweden {
        willSet {
            if newValue != ConsumerViewModel.shared.getCountry() {
                ConsumerViewModel.shared.setCountry(newValue)
            }
        }
    }
    @Published var generatePaymentToken: Bool = false
    @Published var disablePaymentMenu: Bool = false
    @Published var useSafari: Bool = false
    @Published var allowAllRedirects: Bool = false
    @Published var testWrongHostUrl: Bool = false
    @Published var restrictedToInstrumentsText: String = "" {
        willSet {
            
            let instruments = newValue.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            let instrumentsOrNil = instruments.isEmpty ? nil : instruments
            PaymentViewModel.shared.restrictedToInstruments = instrumentsOrNil
        }
    }
    @Published var payerReferenceText: String = "" {
        willSet {
            if newValue.isEmpty {
                PaymentViewModel.shared.payerReference = nil
            } else {
                PaymentViewModel.shared.payerReference = newValue
            }
        }
    }
    @Published var subsiteText: String = "" {
        willSet {
            if newValue.isEmpty {
                PaymentViewModel.shared.subsite = nil
            } else {
                PaymentViewModel.shared.subsite = newValue
            }
        }
    }
    @Published var paymentTokenText: String = "" {
        willSet {
            if newValue.isEmpty {
                PaymentViewModel.shared.paymentToken = nil
            } else {
                PaymentViewModel.shared.paymentToken = newValue
            }
        }
    }
    
    init() {
        refreshModel()
    }
    
    func refreshModel() {
        selectedCountry = ConsumerViewModel.shared.getCountry()
        disablePaymentMenu = PaymentViewModel.shared.disablePaymentMenu
        useSafari = PaymentViewModel.shared.useSafari
        allowAllRedirects = PaymentViewModel.shared.ignoreGoodRedirectsList
        testWrongHostUrl = PaymentViewModel.shared.testWrongHostUrl
        restrictedToInstrumentsText = PaymentViewModel.shared.restrictedToInstruments?.joined(separator: ",") ?? ""
        refreshInstrumentModeLabel()
        refreshPayerReference()
        refreshPaymentToken()
        refreshSubsite()
        generatePaymentToken = PaymentViewModel.shared.generatePaymentToken
    }
    
    private func refreshInstrumentModeLabel() {
        if let instrument = PaymentViewModel.shared.instrument {
            selectedInstrument = .instrument(instrument)
        } else {
            selectedInstrument = .disabled
        }
    }
    
    func refreshPayerReference() {
        payerReferenceText = PaymentViewModel.shared.payerReference ?? ""
    }
    
    private func refreshPaymentToken() {
        paymentTokenText = PaymentViewModel.shared.paymentToken ?? ""
    }
    
    private func refreshSubsite() {
        subsiteText = PaymentViewModel.shared.subsite ?? ""
    }
}
