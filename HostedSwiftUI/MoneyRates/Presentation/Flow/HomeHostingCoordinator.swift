//
//  HomeHostingCoordinator.swift
//  MoneyRates
//
//  Created by Omar Eduardo Gomez Padilla on 14/07/22.
//

import UIKit
import ModelLibrary

final class HomeHostingCoordinator: HomeCoordinator {
    
    private weak var parentController: HomeHostingController!
    
    init(parentController: HomeHostingController) {
        self.parentController = parentController
    }
    
    func goToPickSource() {
        let controller  = getUIController(.source)
        parentController.present(controller, animated: true)
    }
    
    func goToPickTarget() {
        let controller  = getUIController(.target)
        parentController.present(controller, animated: true)
    }
}

extension HomeHostingCoordinator {
    
    private func getUIController(_ mode: PickCurrencyModeEnum) -> PickCurrencyUIViewController {
        let viewModel = PickCurrencyViewModelImpl()
        viewModel.delegate = self
        viewModel.mode = mode
        return PickCurrencyUIViewController(viewModel: viewModel)
    }
}

extension HomeHostingCoordinator: PickCurrencyViewModelDelegate {
    func onSymbolSelected(viewModel: PickCurrencyViewModel, symbol: SymbolModel) {
        print("onSymbolSelected \(symbol.description)")
        parentController.presentedViewController?.dismiss(animated: true, completion: { [weak self] in
            // Tell the model
            self?.parentController.onSymbolSelected(viewModel: viewModel, symbol: symbol)
        })
    }
}
