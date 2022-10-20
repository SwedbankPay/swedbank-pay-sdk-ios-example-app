//
//  ProductListView.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-08-03.
//

import SwiftUI

struct ProductListView: View {
    @EnvironmentObject var storeModel: StoreViewModelObserved
    
    var body: some View {
        if storeModel.model.getBasketCount() == 0 {
            emptyCell
                .transition(.fold)
        } else {
            productList
                .transition(.fold)
        }
    }
    
    var emptyCell: some View {
        ZStack {
            Circle()
                .foregroundColor(Color.backgroundGray)
                .frame(width: 96, height: 96)
            Text("Nothing here yet")
                .titleFont()
        }
    }
    
    var basketCount: Int {
        storeModel.model.getBasketCount()
    }
    
    @Namespace var shoppingCart
    var productList: some View {
        VStack {
            
            ForEach(0..<basketCount, id: \.self) { index in
                
                VStack {
                    ShoppingCartProductCell(product: storeModel.model.getBasketProduct(index))
                    Divider()
                        .padding(.horizontal)
                }
                .transition(.fold)
                
            }
        }
    }
}
