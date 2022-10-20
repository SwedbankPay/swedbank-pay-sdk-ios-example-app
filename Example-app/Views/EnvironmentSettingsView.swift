//
//  EnvironmentSettingsView.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-08-04.
//

import SwiftUI

class EnvironmentModel: ObservableObject {
    @Published var selected = PaymentViewModel.shared.environment {
        didSet {
            PaymentViewModel.shared.environment = selected
        }
    }
}

struct EnvironmentSettingsView: View {
    
    @ObservedObject var environmentModel = EnvironmentModel()
    var body: some View {
        
        Basic2ColumnGrid(count: PaymentViewModel.Environment.allCases.count, content: envButton)
        .foregroundColor(.primary).colorInvert()
        .regularFont()
        .padding()
        .background(Color.black)
    }
    
    func envButton(_ index: Int) -> some View {
        let environment = PaymentViewModel.Environment.allCases[index]
        return Button {
            environmentModel.selected = environment
        } label: {
            Text(environment.displayName)
                .selectedText(environmentModel.selected == environment)
                .frame(width: 150)
                .frame(maxHeight: 40)
        }
        .frame(alignment: .center)
    }
}

struct EnvironmentSettingsView_Previews: PreviewProvider {
    static var model = EnvironmentModel()
    
    static var previews: some View {
        EnvironmentSettingsView(environmentModel: model)
    }
}
