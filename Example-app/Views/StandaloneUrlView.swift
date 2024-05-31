//
//  StandaloneUrlView.swift
//  Example-app
//
//  Created by Andreas Petersson on 2023-05-09.
//  Copyright © 2023 Swedbank. All rights reserved.
//

import SwiftUI
import SwedbankPaySDK
import CodeScanner

struct StandaloneUrlView: View {
    @StateObject private var viewModel = StandaloneUrlViewModel()
    @FocusState private var isFocused: Bool
    
    @State var nativePayment: SwedbankPaySDK.NativePayment?
    @State var latestClickedUrl: ScanUrl = .unknown

    var scannerSheet : some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                if case let .success(code) = result {
                    switch self.latestClickedUrl {
                        case .checkout:
                            viewModel.viewCheckoutUrl = code.string
                            break
                        case .base:
                            viewModel.baseUrl = code.string
                            saveEnteredUrl(scanUrl: .base)
                            break
                        case .complete:
                            viewModel.completeUrl = code.string
                            saveEnteredUrl(scanUrl: .complete)
                            break
                        case .cancel:
                            viewModel.cancelUrl = code.string
                            saveEnteredUrl(scanUrl: .cancel)
                            break
                        case .payment:
                            viewModel.paymentUrlAuthorityAndPath = code.string
                            break
                        case .sessionApi:
                            viewModel.sessionApiUrl = code.string
                            break
                        case .swish:
                            viewModel.swishNumber = code.string
                            break
                        case .unknown:
                            break
                    }
                    viewModel.displayScannerSheet = false
                }
            })
    }
    
    var body: some View {
        ScrollView {
            VStack {
                // Display result information from payment
                if let icon = viewModel.paymentResultIcon, let text = viewModel.paymentResultMessage {
                    Image(icon)
                    Text(text)
                }
            }
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    TextField(
                        "stand_alone_url_payment_view_checkout_url",
                        text: $viewModel.viewCheckoutUrl
                    )
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .lightTextField()
                        .keyboardType(.URL)
                        .focused($isFocused)
                    
                    IconButton(systemName: "qrcode.viewfinder") {
                        viewModel.displayScannerSheet = true
                        self.isFocused = false
                        self.latestClickedUrl = .checkout
                    }
                }

                HStack {
                    TextField(
                        "stand_alone_url_payment_base_url",
                        text: $viewModel.baseUrl,
                        onEditingChanged: { focused in
                            if (!focused) {
                                saveEnteredUrl(scanUrl: .base)
                            }
                        }
                    )
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .lightTextField()
                        .keyboardType(.URL)
                        .focused($isFocused)
                    
                    IconButton(systemName: "qrcode.viewfinder") {
                        viewModel.displayScannerSheet = true
                        self.isFocused = false
                        self.latestClickedUrl = .base
                    }
                }
                
                HStack {
                    TextField(
                        "stand_alone_url_payment_complete_url",
                        text: $viewModel.completeUrl,
                        onEditingChanged: { focused in
                            if (!focused) {
                                saveEnteredUrl(scanUrl: .complete)
                            }
                        }
                    )
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .lightTextField()
                        .keyboardType(.URL)
                        .focused($isFocused)
                    
                    IconButton(systemName: "qrcode.viewfinder") {
                        viewModel.displayScannerSheet = true
                        self.isFocused = false
                        self.latestClickedUrl = .complete
                    }
                }
                
                HStack {
                    TextField(
                        "stand_alone_url_payment_cancel_url",
                        text: $viewModel.cancelUrl,
                        onEditingChanged: { focused in
                            if (!focused) {
                                saveEnteredUrl(scanUrl: .cancel)
                            }
                        }
                    )
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .lightTextField()
                        .keyboardType(.URL)
                        .focused($isFocused)
                    
                    IconButton(systemName: "qrcode.viewfinder") {
                        viewModel.displayScannerSheet = true
                        self.isFocused = false
                        self.latestClickedUrl = .cancel
                    }
                }
                
                Toggle("stand_alone_url_payment_checkout_v3", isOn: $viewModel.useCheckoutV3)
                
                Button {
                    isFocused = false
                    viewModel.displaySwedbankPayController = true
                } label: {
                    Text("general_checkout")
                        .smallFont()
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .accessibilityIdentifier("checkoutButton")
                }
                .disabled(!viewModel.isCheckoutEnabled)
                .foregroundColor(viewModel.isCheckoutEnabled ? .white : .gray)
                .background(viewModel.isCheckoutEnabled ? .black : .backgroundGray)
                .cornerRadius(30)
                .padding(.top, 10)
                
                HStack {
                    Text("stand_alone_url_payment_payment_url_scheme")
                    TextField(
                        "stand_alone_url_payment_payment_url",
                        text: $viewModel.paymentUrlAuthorityAndPath,
                        onEditingChanged: { focused in
                            if(!focused) {
                                saveEnteredUrl(scanUrl: .payment)
                            }
                        }
                    )
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .lightTextField()
                        .keyboardType(.URL)
                        .focused($isFocused)
                }
                
                HStack {
                    TextField(
                        "stand_alone_url_payment_session_url",
                        text: $viewModel.sessionApiUrl,
                        onEditingChanged: { focused in
                            if (!focused) {
                                saveEnteredUrl(scanUrl: .sessionApi)
                            }
                        }
                    )
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .lightTextField()
                    .keyboardType(.URL)
                    .focused($isFocused)
                    
                    IconButton(systemName: "qrcode.viewfinder") {
                        viewModel.displayScannerSheet = true
                        self.isFocused = false
                        self.latestClickedUrl = .sessionApi
                    }
                }
                
                Button {
                    isFocused = false
                    
                    if let configuration = viewModel.configurePayment(),
                       let sessionURL = URL(string: viewModel.sessionApiUrl) {
                        nativePayment = SwedbankPaySDK.NativePayment(orderInfo: configuration.orderInfo)
                        nativePayment?.delegate = viewModel
                        
                        nativePayment?.startPaymentSession(sessionURL: sessionURL)
                    }
                } label: {
                    Text("stand_alone_url_payment_get_session")
                        .smallFont()
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .accessibilityIdentifier("getSessionButton")
                }
                .disabled(viewModel.sessionApiUrl.isEmpty)
                .foregroundColor(!viewModel.sessionApiUrl.isEmpty ? .white : .gray)
                .background(!viewModel.sessionApiUrl.isEmpty ? .black : .backgroundGray)
                .cornerRadius(30)
                .padding(.top, 10)
                
                if let availableInstrument = viewModel.availableInstrument {
                    ForEach(availableInstrument, id: \.self) { instrument in
                        switch instrument {
                        case .swish(let prefills):
                            HStack {
                                TextField(
                                    "stand_alone_url_payment_swish_number",
                                    text: $viewModel.swishNumber,
                                    onEditingChanged: { focused in
                                        if (!focused) {
                                            saveEnteredUrl(scanUrl: .sessionApi)
                                        }
                                    }
                                )
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .lightTextField()
                                .keyboardType(.phonePad)
                                .focused($isFocused)
                                
                                IconButton(systemName: "qrcode.viewfinder") {
                                    viewModel.displayScannerSheet = true
                                    self.isFocused = false
                                    self.latestClickedUrl = .swish
                                }
                            }
                            
                            Button {
                                isFocused = false
                                
                                nativePayment?.makePaymentAttempt(instrument: .swish(msisdn: viewModel.swishNumber))
                            } label: {
                                Text("stand_alone_url_payment_swish")
                                    .smallFont()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .accessibilityIdentifier("swishButton")
                            }
                            .disabled(viewModel.swishNumber.isEmpty)
                            .foregroundColor(!viewModel.swishNumber.isEmpty ? .white : .gray)
                            .background(!viewModel.swishNumber.isEmpty ? .black : .backgroundGray)
                            .cornerRadius(30)
                            .padding(.top, 10)

                            Button {
                                isFocused = false
                                
                                nativePayment?.makePaymentAttempt(instrument: .swish(msisdn: nil))
                            } label: {
                                Text("stand_alone_url_payment_swish_device")
                                    .smallFont()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .accessibilityIdentifier("swishButton")
                            }
                            .foregroundColor(.white)
                            .background(.black)
                            .cornerRadius(30)
                            .padding(.top, 10)
                            
                            if let prefills = prefills {
                                ForEach(prefills, id: \.self) { prefill in
                                    Button {
                                        isFocused = false
                                        
                                        nativePayment?.makePaymentAttempt(instrument: .swish(msisdn: prefill.msisdn))
                                    } label: {
                                        Text("stand_alone_url_payment_swish_prefill \(prefill.msisdn)")
                                            .smallFont()
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 48)
                                            .accessibilityIdentifier("swishPrefillButton")
                                    }
                                    .foregroundColor(.white)
                                    .background(.black)
                                    .cornerRadius(30)
                                    .padding(.top, 10)
                                }
                            }
                        }
                    }
                }
                
                Button {
                    isFocused = false
                    
                    nativePayment?.abortPaymentSession()
                } label: {
                    Text("stand_alone_url_payment_abort")
                        .smallFont()
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .accessibilityIdentifier("abortButton")
                }
                .disabled(viewModel.sessionApiUrl.isEmpty)
                .foregroundColor(!viewModel.sessionApiUrl.isEmpty ? .white : .gray)
                .background(!viewModel.sessionApiUrl.isEmpty ? .black : .backgroundGray)
                .cornerRadius(30)
                .padding(.top, 10)
            }
            .padding()
            .sheet(isPresented: $viewModel.displaySwedbankPayController) {
                if let configuration = viewModel.configurePayment() {
                    SwedbankPayView(swedbankPayConfiguration: configuration, delegate: viewModel, nativePaymentDelegate: viewModel)
                }
            }
            .sheet(isPresented: $viewModel.displayScannerSheet) {
                self.scannerSheet
            }
            .alert(viewModel.error?.localizedDescription ?? "",
                   isPresented: $viewModel.showingAlert) {
                Button("general_ok".localize, role: .cancel) { }
                Button("general_retry".localize) { viewModel.retry?() }
            }
        }
    }
    
    func saveEnteredUrl(scanUrl: ScanUrl) {
        switch scanUrl {
            case .checkout:
                break
            case .base:
                viewModel.saveUrl(urlType: scanUrl, url: viewModel.baseUrl)
                break
            case .complete:
                viewModel.saveUrl(urlType: scanUrl, url: viewModel.completeUrl)
                break
            case .cancel:
                viewModel.saveUrl(urlType: scanUrl, url: viewModel.cancelUrl)
                break
            case .payment:
                viewModel.saveUrl(urlType: scanUrl, url: viewModel.paymentUrlAuthorityAndPath)
                break
            case .sessionApi:
                viewModel.saveUrl(urlType: scanUrl, url: viewModel.sessionApiUrl)
                break
            case .swish:
                viewModel.saveUrl(urlType: scanUrl, url: viewModel.swishNumber)
                break
            case .unknown:
                break
        }
    }
}

struct SwedbankPayView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SwedbankPaySDKController
    
    private let swedbankPayConfiguration: SwedbankPayConfiguration
    private let delegate: SwedbankPaySDKDelegate
    private let nativePaymentDelegate: SwedbankPaySDKNativePaymentDelegate

    init(swedbankPayConfiguration: SwedbankPayConfiguration, delegate: SwedbankPaySDKDelegate, nativePaymentDelegate: SwedbankPaySDKNativePaymentDelegate) {
        self.swedbankPayConfiguration = swedbankPayConfiguration
        self.delegate = delegate
        self.nativePaymentDelegate = nativePaymentDelegate
    }
    
    func makeUIViewController(context: Context) -> SwedbankPaySDKController {
        let vc = SwedbankPaySDKController(
            configuration: swedbankPayConfiguration,
            withCheckin: false,
            consumer: nil,
            paymentOrder: nil,
            userData: nil)
        
        vc.delegate = delegate
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: SwedbankPaySDKController, context: Context) {
    }
}

struct StandaloneUrlView_Previews: PreviewProvider {
    static var previews: some View {
        StandaloneUrlView()
    }
}
