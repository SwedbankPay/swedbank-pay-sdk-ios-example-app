//
//  ShoppingCartProductCell.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-08-03.
//

import SwiftUI

struct ShoppingCartProductCell: View {
    var product: Product
    @EnvironmentObject var storeModel: StoreViewModelObserved

    var body: some View {
        
        HStack(alignment: .top) {
            productImage
            
            VStack(alignment: .leading) {
                Text(product.name)
                    .titleFont()
                
                Text(productPriceLabel)
                    .priceFont()
                
                Button {
                    withAnimation(.easeInOut) {
                        storeModel.removeFromBasket(product)
                    }
                } label: {
                    HStack {
                        Image("Icon-Basket-Remove")
                        Text("Remove")
                            .foregroundColor(.white)
                            .smallFont()
                    }
                    .padding(10)
                    .background(Color.deleteRed)
                    .cornerRadius(25)
                }
            }
            Spacer()
        }
    }
    
    var productImage: some View {
        ZStack {
            Circle()
                .frame(width: 100, height: 100)
                .foregroundColor(productColor)
            Image(product.image)
                .resizable()
            
        }
        .frame(width: 120, height: 120, alignment: .center)
    }
    
    var productColor: Color {
        if #available(iOS 15.0, *) {
            return Color(uiColor: UIColor(rgb: product.highlightHexColor))
        } else {
            return Color(UIColor(rgb: product.highlightHexColor))
        }
    }
    
    var productPriceLabel: String {
        let currency = ConsumerViewModel.shared.getCurrency()
        let price = String((product.price[currency] ?? 0) / 100)
        
        return "\(price) \(currency.rawValue)"
    }
}

/*
struct ShoppingCartProductCell_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingCartProductCell()
    }
}
*/
