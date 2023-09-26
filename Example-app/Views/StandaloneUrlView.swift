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
    
    @State var latestClickedUrl: ScanUrl = .unknown
    
    var scannerSheet : some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                if case let .success(code) = result {
                    switch self.latestClickedUrl {
                        case .payment:
                        viewModel.viewPaymentUrl = code.string
                            break
                        case .base:
                            viewModel.baseUrl = code.string
                            break
                        case .complete:
                            viewModel.completeUrl = code.string
                            break
                        case .cancel:
                            viewModel.cancelUrl = code.string
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
                    TextField("stand_alone_url_payment_view_payment_url", text: $viewModel.viewPaymentUrl)
                        .disableAutocorrection(true)
                        .lightTextField()
                    IconButton(systemName: "qrcode.viewfinder") {
                        viewModel.displayScannerSheet = true
                        self.latestClickedUrl = .payment
                    }
                }

                HStack {
                    TextField("stand_alone_url_payment_base_url", text: $viewModel.baseUrl)
                        .disableAutocorrection(true)
                        .lightTextField()
                    IconButton(systemName: "qrcode.viewfinder") {
                        viewModel.displayScannerSheet = true
                        self.latestClickedUrl = .base
                    }
                }
                
                HStack {
                    TextField("stand_alone_url_payment_complete_url", text: $viewModel.completeUrl)
                        .disableAutocorrection(true)
                        .lightTextField()
                    IconButton(systemName: "qrcode.viewfinder") {
                        viewModel.displayScannerSheet = true
                        self.latestClickedUrl = .complete
                    }
                }
                
                HStack {
                    TextField("stand_alone_url_payment_cancel_url", text: $viewModel.cancelUrl)
                        .disableAutocorrection(true)
                        .lightTextField()
                    IconButton(systemName: "qrcode.viewfinder") {
                        viewModel.displayScannerSheet = true
                        self.latestClickedUrl = .cancel
                    }
                }
                
                Toggle("stand_alone_url_payment_checkout_v3", isOn: $viewModel.useCheckoutV3)
                
                Button {
                    viewModel.displaySwedbankPayController = true
                } label: {
                    Text("general_checkout")
                        .smallFont()
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .accessibilityIdentifier("checkoutButton")
                }
                .foregroundColor(.white)
                .background(Color.black)
                .cornerRadius(30)
                .padding(.top, 10)
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
