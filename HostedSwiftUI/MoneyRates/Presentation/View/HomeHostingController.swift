//
//  HomeHostingController.swift
//  MoneyRates
//
//  Created by Omar Gomez on 10/6/22.
//

import Foundation
import SwiftUI
import ModelLibrary

class HomeHostingController: UIHostingController<HomeUIView> {
    
    private let viewModel: HomeViewModel
    
    init(viewModel: HomeViewModelImpl) {
        self.viewModel = viewModel
        super.init(rootView: HomeUIView(viewModel: viewModel))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension HomeHostingController: PickCurrencyViewModelDelegate {
    func onSymbolSelected(viewModel: PickCurrencyViewModel, symbol: SymbolModel) {
        if viewModel.mode == .source {
            self.viewModel.input.onSource.send(symbol)
        } else {
            self.viewModel.input.onTarget.send(symbol)
        }
    }
}
