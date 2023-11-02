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
            }
            .padding()
            .sheet(isPresented: $viewModel.displaySwedbankPayController) {
                if let configuration = viewModel.configurePayment() {
                    SwedbankPayView(swedbankPayConfiguration: configuration, delegate: viewModel)
                }
            }
            .sheet(isPresented: $viewModel.displayScannerSheet) {
                self.scannerSheet
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
            case .unknown:
                break
        }
    }
}

struct SwedbankPayView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SwedbankPaySDKController
    
    private let swedbankPayConfiguration: SwedbankPayConfiguration
    private let delegate: SwedbankPaySDKDelegate
    
    init(swedbankPayConfiguration: SwedbankPayConfiguration, delegate: SwedbankPaySDKDelegate) {
        self.swedbankPayConfiguration = swedbankPayConfiguration
        self.delegate = delegate
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
