//
//  ShoppingCartTable.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-08-03.
//  Copyright © 2022 Swedbank. All rights reserved.
//

import SwiftUI

struct ShoppingCartTable: View {
    @ObservedObject var storeViewModel: StoreViewModelObserved
    var settingsViewModel: GeneralSettingsViewModel
    var consumerModel: ConsumerSettingsViewModel
    
    var body: some View {
        ScrollView {
            EnvironmentSettingsView()
                .cornerRadius(15)
            
            ShoppingBasketView(storeViewModel: storeViewModel)
                .padding(.vertical)
                .background(Color.white)
                .cornerRadius(15)
                .padding(.top)
            
            GeneralSettings(model: settingsViewModel)
            
            ConsumerSettingsView(consumerModel: consumerModel)
        }
    }
    
    var hostingController: UIHostingController<Self> {
        UIHostingController(rootView: self)
    }
}

struct ShoppingCartTable_Previews: PreviewProvider {
    static var storeViewModel = StoreViewModelObserved()
    static var settingsViewModel = GeneralSettingsViewModel()
    static var consumer = ConsumerSettingsViewModel()
    
    static var previews: some View {
        if storeViewModel.model.getBasketCount() <= 0 {
            //storeViewModel.model.addToBasket(storeViewModel.model.products[3])
        }
        
        return ShoppingCartTable(storeViewModel: storeViewModel, settingsViewModel: settingsViewModel, consumerModel: consumer)
            .padding()
            .background(Color.gray)
            
        
    }
}
