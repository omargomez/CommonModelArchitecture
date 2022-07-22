//
//  ContentView.swift
//  SwiftUIMoneyRates
//
//  Created by Omar Eduardo Gomez Padilla on 21/07/22.
//

import SwiftUI
import Combine
import ModelLibrary

struct ContentView: View {
    @State private var showModal = false
    let pickCurrencyModel = PickCurrencyViewModelImpl(mode: .source)

    var body: some View {
        VStack {
            Button("Show modal") {
                self.showModal = true
            }
        }.sheet(isPresented: $showModal, onDismiss: {
            print(self.showModal)
        }) {
            PickCurrencyUIView(viewModel: pickCurrencyModel)
        }
        .onReceive( pickCurrencyModel.output.selection ) { selection in
                    // The app moved to the background
                    self.showModal = false
            print("Selection: \(selection)")
                }
    }
}

struct ModalView: View {
    @Environment(\.presentationMode) var presentation
    let message: String

    var body: some View {
        VStack {
            Text(message)
            Button("Dismiss") {
                self.presentation.wrappedValue.dismiss()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
