//
//  LogView.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-07-05.
//  Copyright © 2022 Swedbank. All rights reserved.
//

import SwiftUI

class LogViewModel: ObservableObject {
    @Published var errorLogText: String
    @Published var navigationLogText: String
    
    init (errorLogText: String, navigationLogText: String?) {
        
        self.errorLogText = errorLogText.isEmpty ? "No error log" : errorLogText
        self.navigationLogText = navigationLogText ?? "No navigation log"
    }
}

struct LogView: View {
    
    @ObservedObject var model: LogViewModel
    @State private var selectedIndex = 0
    @Namespace var itemID
    
    var body: some View {
        VStack {
           
            
            if #available(iOS 14.0, *) {
                scrollingView
            } else {
                // Fallback on earlier versions
                manualScrollingView
            }
        }
    }
    
    @available(iOS 14.0, *)
    @ViewBuilder
    var scrollingView: some View {
        ScrollViewReader { proxy in
            
            Picker("Select log", selection: $selectedIndex) {
                Text("Error Log").tag(0)
                Text("Navigation Log").tag(1)
            }
            .onChange(of: selectedIndex, perform: { newValue in
                withAnimation(Animation.easeOut(duration: 1)) {
                    proxy.scrollTo(itemID, anchor: .bottomTrailing)
                }
            })
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            ScrollView {
                
                logText
                    .id(itemID)
                    .onAppear() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(Animation.easeOut(duration: 1)) {
                                proxy.scrollTo(itemID, anchor: .bottomTrailing)
                            }
                        }
                    }
            }
            
            copyButton
        }
    }
    
    var copyButton: some View {
        Button("Copy") {
            UIPasteboard.general.string = selectedIndex == 0 ? model.errorLogText : model.navigationLogText
        }
        .padding(.horizontal)
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.accentColor, lineWidth: 2)
        )
    }
    
    var logText: some View {
        selectedIndex == 0 ? Text(model.errorLogText) : Text(model.navigationLogText)
    }
        
        
    
    @ViewBuilder
    var manualScrollingView: some View {
        Picker("Select log", selection: $selectedIndex) {
            Text("Error Log").tag(0)
            Text("Navigation Log").tag(1)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
        
        ScrollView {
            Text( selectedIndex == 0 ? model.errorLogText : model.navigationLogText)
                .id(itemID)
        }
        
        copyButton
    }
    
    var hostingController: UIHostingController<LogView> {
        UIHostingController(rootView: self)
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        
        let longString = repeatElement("long slong string long string long string", count: 90).joined(separator: "\n").appending("\nEND")
        return LogView(model: LogViewModel(errorLogText: longString, navigationLogText: nil))
    }
}
