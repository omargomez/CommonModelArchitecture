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
    
    @ObservedObject private var viewModel: PickCurrencyViewModelImpl
    @State private var searchText: String
    
    init(viewModel: PickCurrencyViewModelImpl = PickCurrencyViewModelImpl(mode: .source)) {
        self.viewModel = viewModel
        self.searchText = ""
    }
    
    private typealias RowItem = (index: Int, item: SymbolModel)
    
    var body: some View {
        let items = (0..<viewModel.currencyCount()).map({RowItem(index: $0, self.viewModel.symbolAt(at: $0))})
        NavigationView {
            List(items, id: \.item.id) { symbolItem in
                Text(symbolItem.item.description)
                    .onTapGesture {
                        self.viewModel.input.onSelection.send(symbolItem.index)
                    }
            }
            .listStyle(.plain)
            #if !os(macOS)
            .navigationBarTitle(Text("Select Currency"), displayMode: .inline)
            #endif
        }
        .searchable(text: $searchText)
        .onAppear(perform: {
            self.viewModel.input.onLoad.send()
        })
        .onChange(of: searchText) { newValue in
            self.viewModel.input.search.send(newValue)
        }
    }
}

#if os(macOS)
struct DesktopPickCurrencyUIView: View {
    @ObservedObject private var viewModel: PickCurrencyViewModelImpl
    @State private var searchText: String
    
    init(viewModel: PickCurrencyViewModelImpl = PickCurrencyViewModelImpl(mode: .source)) {
        self.viewModel = viewModel
        self.searchText = ""
        self.viewModel.input.onLoad.send()
    }
    
    private typealias RowItem = (index: Int, item: SymbolModel)
    
    var body: some View {
        let items = (0..<viewModel.currencyCount()).map({RowItem(index: $0, self.viewModel.symbolAt(at: $0))})
        VStack {
            TextField("", text: $searchText)
            List(items, id: \.item.id) { symbolItem in
                Text(symbolItem.item.description)
                    .onTapGesture {
                        self.viewModel.input.onSelection.send(symbolItem.index)
                    }
            }
            .listStyle(.plain)
        }
        .onAppear(perform: {
            // nothing
        })
        .onChange(of: searchText) { newValue in
            self.viewModel.input.search.send(newValue)
        }
        .padding()
        .frame(minWidth: 300, minHeight: 200)
    }
}
#endif

struct PickCurrencyUIView_Previews: PreviewProvider {
    static var previews: some View {
        PickCurrencyUIView()
    }
}
