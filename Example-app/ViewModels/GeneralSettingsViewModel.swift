//
//  GeneralSettingsViewModel.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-07-13.
//

import Foundation
import SwedbankPaySDK

class GeneralSettingsViewModel: ObservableObject {
    
    /// Hide/reveal the whole section
    @Published var showCell: Bool = false
    /// Controlling the get tokens screen
    @Published var showGetTokenScreen = false
    
    @Published var showCustomInstrumentInput = false
    @Published var selectedInstrument: PaymentViewModel.InstrumentOption = .disabled {
        willSet {
            let currentIndex = PaymentViewModel.shared.instrumentOptionIndex
            if let newIndex = PaymentViewModel.shared.instrumentOptions.firstIndex(of: newValue), newIndex != currentIndex {
                PaymentViewModel.shared.instrumentOptionIndex = newIndex
            }
            showCustomInstrumentInput = newValue == .custom
        }
    }
    
    @Published var customInstrument: String = PaymentViewModel.shared.customInstrument ?? "" {
        willSet {
            if PaymentViewModel.shared.customInstrument != newValue {
                PaymentViewModel.shared.customInstrument = newValue
            }
        }
    }
    
    @Published var selectedCountry: Country = .Sweden {
        willSet {
            if newValue != ConsumerViewModel.shared.getCountry() {
                ConsumerViewModel.shared.setCountry(newValue)
            }
        }
    }
    @Published var generatePaymentToken: Bool = false {
        willSet {
            if newValue != PaymentViewModel.shared.generatePaymentToken {
                PaymentViewModel.shared.generatePaymentToken = newValue
            }
        }
    }
    @Published var disablePaymentMenu: Bool = false {
        willSet {
            if newValue != PaymentViewModel.shared.disablePaymentMenu {
                PaymentViewModel.shared.disablePaymentMenu = newValue
            }
        }
    }
    
    @Published var useSafari: Bool = false {
        willSet {
            if newValue != PaymentViewModel.shared.useSafari {
                PaymentViewModel.shared.useSafari = newValue
            }
        }
    }
    
    @Published var allowAllRedirects: Bool = false {
        willSet {
            if newValue != PaymentViewModel.shared.ignoreGoodRedirectsList {
                PaymentViewModel.shared.ignoreGoodRedirectsList = newValue
            }
        }
    }
    
    @Published var testWrongHostUrl: Bool = false {
        willSet {
            if newValue != PaymentViewModel.shared.testWrongHostUrl {
                PaymentViewModel.shared.testWrongHostUrl = newValue
            }
        }
    }
    
    @Published var restrictedToInstrumentsText: String = "" {
        willSet {
            
            let instruments = newValue.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            let instrumentsOrNil = instruments.isEmpty ? nil : instruments
            if PaymentViewModel.shared.restrictedToInstruments != instrumentsOrNil {
                PaymentViewModel.shared.restrictedToInstruments = instrumentsOrNil
            }
        }
    }
    
    @Published var payerReferenceText: String = "" {
        willSet {
            let value = newValue.isEmpty ? nil : newValue
            if PaymentViewModel.shared.payerReference != value {
                PaymentViewModel.shared.payerReference = value
            }
        }
    }
    
    @Published var subsiteText: String = "" {
        willSet {
            let value = newValue.isEmpty ? nil : newValue
            if PaymentViewModel.shared.subsite != value {
                PaymentViewModel.shared.subsite = value
            }
        }
    }
    
    @Published var paymentTokenText: String = "" {
        willSet {
            let value = newValue.isEmpty ? nil : newValue
            if PaymentViewModel.shared.paymentToken != value {
                PaymentViewModel.shared.paymentToken = value
            }
        }
    }
    
    @Published var paymentTokens: [SwedbankPaySDK.PaymentTokenInfo] = []
    @Published var loadingRequest = false
    private var request: SwedbankPaySDKRequest? {
        didSet {
            loadingRequest = request != nil
        }
    }
    
    init() {
        refreshModel()
    }
    
    func refreshModel() {
        
        customInstrument = PaymentViewModel.shared.customInstrument ?? ""
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
    
    @Published var tokenAlertIsPresented = false
    @Published var tokenAlertTitle: String = ""
    @Published var tokenAlertBody: String = ""
    func showTokenAlert(title: String, body: String) {
        tokenAlertTitle = title
        tokenAlertBody = body
        tokenAlertIsPresented = true
    }
    
    func fetchTokensV2() {
        if payerReferenceText.isEmpty {
            showTokenAlert(title: "Payer is needed", body: "Fill in the payer reference for which tokens to fetch")
            return
        }
        request?.cancel()
        
        let configuration = PaymentViewModel.shared.configuration
        request = SwedbankPaySDK.MerchantBackend.getPayerOwnedPaymentTokens(
            configuration: configuration,
            payerReference: payerReferenceText
        ) { [weak self] result in
            
            DispatchQueue.main.async {
                self?.onGetTokensResult(result)
            }
        }
    }
    
    private func onGetTokensResult(_ result: Result<SwedbankPaySDK.PayerOwnedPaymentTokensResponse, Error>) {
        request = nil
        switch result {
            case .success(let response):
                debugPrint(response)
                paymentTokens = response.payerOwnedPaymentTokens.paymentTokens ?? []
                if paymentTokens.isEmpty {
                    showTokenAlert(title: "Note", body: "No payment tokens found")
                }
            case .failure(SwedbankPaySDK.MerchantBackendError.problem(.client(.mobileSDK(.unauthorized)))):
                showTokenAlert(title: "Error", body: "Environment does not support token retrieval")
            case .failure:
                showTokenAlert(title: "Error", body: "Could not retrieve tokens")
        }
    }
    
    func useToken(_ token: SwedbankPaySDK.PaymentTokenInfo) {
        PaymentViewModel.shared.paymentToken = token.paymentToken
        showGetTokenScreen = false
    }
    
    func deleteToken(_ token: SwedbankPaySDK.PaymentTokenInfo) {
        request?.cancel()
        
        let configuration = PaymentViewModel.shared.configuration
        request = SwedbankPaySDK.MerchantBackend.deletePayerOwnerPaymentToken(
            configuration: configuration,
            paymentToken: token,
            comment: "User deleted from example app"
        ) { [weak self] result in
            self?.onDeleteTokenResult(token, result: result)
        }
    }
    
    private func onDeleteTokenResult(_ token: SwedbankPaySDK.PaymentTokenInfo, result: Result<Void, Error>) {
        request = nil
        
        if case .success = result,
            let index = paymentTokens.firstIndex(where: { $0.paymentToken == token.paymentToken }) {
            
            paymentTokens.remove(at: index)
        }
    }
    
}
