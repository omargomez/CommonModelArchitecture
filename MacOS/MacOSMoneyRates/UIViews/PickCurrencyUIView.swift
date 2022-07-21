//
//  PickCurrencyUIView.swift
//  MoneyRates
//
//  Created by Omar Eduardo Gomez Padilla on 8/06/22.
//

import SwiftUI
import Combine
import ModelLibrary

struct PickCurrencyUIView: View {
    
    @ObservedObject var viewModel: PickCurrencyViewModelImpl
    @State private var searchText: String
    
    init(viewModel: PickCurrencyViewModelImpl = PickCurrencyViewModelImpl()) {
        self.viewModel = viewModel
        self.searchText = ""
    }
    
    private typealias RowItem = (index: Int, item: SymbolModel)
    
    var body: some View {
        let items = (0..<viewModel.currencyCount()).map({RowItem(index: $0, self.viewModel.symbolAt(at: $0))})
        VStack {
            SearchBar(text: $searchText)
                .padding(.top, 30)
            List(items, id: \.item.id) { symbolItem in
                Text(symbolItem.item.description)
                    .onTapGesture {
                        print("### onTapGesture")
                        self.viewModel.input.onSelection.send(symbolItem.index)
                    }
            }
            .listStyle(.plain)
        }
        .onAppear(perform: {
            self.viewModel.input.onLoad.send()
        })
        .onChange(of: searchText) { newValue in
            print("onChange: \(searchText)")
            self.viewModel.input.search.send(newValue)
        }
    }
    
}

struct PickCurrencyUIView_Previews: PreviewProvider {
    static var previews: some View {
        PickCurrencyUIView()
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            
            TextField("Search ...", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(.gray)
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
            
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
}
