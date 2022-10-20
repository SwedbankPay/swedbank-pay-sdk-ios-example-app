//
//  ShoppingCartView.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-08-01.
//

import SwiftUI

struct ShoppingBasketView: View {
    @ObservedObject var storeViewModel: StoreViewModelObserved
    
    var body: some View {
        VStack {
            basketHeader
            Divider()
                .padding(.horizontal)
            ProductListView()
            if storeViewModel.model.getBasketCount() > 0 {
                footerSegment
            }
        }
        .environmentObject(storeViewModel)
        .preferredColorScheme(.light)
    }
    
    @ViewBuilder
    var footerSegment: some View {
        if storeViewModel.enterPriceIsShown {
            VStack {
                TextField("Total price", text: $storeViewModel.overideTotalString) {
                    submitTotalPrice()
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 15.0).stroke(Color.primary))
                .padding()
                
                Button {
                    self.resignFirstResponder()
                    submitTotalPrice()
                } label: {
                    Text("Done")
                        .foregroundColor(.primary)
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 15.0).stroke(Color.primary))
                .padding(.bottom)
            }
            
            
        }
        else {
            shippingCell
            Divider()
                .padding(.horizontal)
            totalCell
            Button {
                if storeViewModel.model.getBasketCount() > 0 {
                    storeViewModel.processPayment = true
                }
            } label: {
                Text("Checkout")
                    .smallFont()
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .accessibilityIdentifier("checkoutButton")
            }
            .foregroundColor(.white)
            .background(Color.black)
            .cornerRadius(30)
            .padding(.top, 10)
            .padding(.horizontal, 50)
            
        }
    }
    
    func submitTotalPrice() {
        storeViewModel.enterPriceIsShown = false
        if let overideTotal = storeViewModel.overideTotal {
            storeViewModel.overideTotalString = "\(Int(truncating: overideTotal as NSNumber))"
        } else {
            storeViewModel.overideTotalString = ""
        }
    }
    
    var basketHeader: some View {
        HStack {
            Image("Icon-Basket")
            Spacer()
            Text("Shopping basket")
            Spacer()
            Button {
                storeViewModel.showBasket = false
            } label: {
                Image("Icon-X")
                    .foregroundColor(.primary)
            }
        }
        .regularFont()
        .padding(.horizontal)
    }
    
    var shippingCell: some View {
        HStack {
            Spacer()
                .frame(width: 50)
            ZStack {
                Circle()
                    .foregroundColor(Color.backgroundGray)
                    .frame(width: 50, height: 50)
                
                Image("Icon-Truck")
                    .aspectRatio(contentMode: .fit)
                    
            }
            
            Spacer()
                .frame(width: 30)
            VStack(alignment: .leading) {
                Text("Shipping")
                    .titleFont()
                Text(storeViewModel.shippingCostLabel)
                    .priceFont()
            }
            Spacer()
        }
    }
    
    var totalCell: some View {
        HStack {
            Spacer()
                .frame(width: 130)
            
            Button {
                storeViewModel.enterPriceIsShown = true
            } label: {
                VStack(alignment: .leading) {
                    HStack(alignment: .bottom) {
                        Text("Total")
                            .titleFont()
                        Text("(tap to change)")
                            .smallFont()
                    }
                    Text(storeViewModel.totalPriceLabel)
                        .priceFont()
                }
                .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

struct ShoppingBasketView_Previews: PreviewProvider {
    
    static var model = StoreViewModelObserved()
    static var previews: some View {
        if model.model.getBasketCount() <= 0 {
            model.model.addToBasket(model.model.products[3])
            //model.model.addToBasket(model.model.products[1])
            //model.model.addToBasket(model.model.products[0])
            //model.model.addToBasket(model.model.products[4])
        }
        
        return ScrollView {
            ShoppingBasketView(storeViewModel: model)
        }
    }
}
