//
//  LogView.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-07-05.
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
            scrollingView
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
    
    var hostingController: UIHostingController<Self> {
        UIHostingController(rootView: self)
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        
        let longString = repeatElement("long slong string long string long string", count: 90).joined(separator: "\n").appending("\nEND")
        return LogView(model: LogViewModel(errorLogText: longString, navigationLogText: nil))
    }
}
