//
//  UIKitHomeCoordinator.swift
//  MoneyRates
//
//  Created by Omar Eduardo Gomez Padilla on 14/07/22.
//

import UIKit
import ModelLibrary

final class HomeCoordinatorImpl: HomeCoordinator {
    
    private weak var parentController: HomeViewController!
    
    init(parentController: HomeViewController) {
        self.parentController = parentController
    }
    
    func goToPickSource() {
        let controller  = getController()
        controller.viewModel.mode = PickCurrencyModeEnum.source
        parentController.present(controller, animated: true)
    }
    
    func goToPickTarget() {
        let controller  = getController()
        controller.viewModel.mode = PickCurrencyModeEnum.target
        parentController.present(controller, animated: true)
    }
}

extension HomeCoordinatorImpl {
    
    private func getController() -> PickCurrencyViewController {
        let controller = UIStoryboard.main.instantiateViewController(identifier: "currencyViewController", creator: { coder in
            let viewModel = PickCurrencyViewModelImpl()
            viewModel.delegate = self
            let result = PickCurrencyViewController(coder: coder, viewModel: viewModel)
            return result
        }) as! PickCurrencyViewController
        return controller
    }
}

extension HomeCoordinatorImpl: PickCurrencyViewModelDelegate {
    func onSymbolSelected(viewModel: PickCurrencyViewModel, symbol: SymbolModel) {
        print("onSymbolSelected \(symbol.description)")
        parentController.presentedViewController?.dismiss(animated: true, completion: { [weak self] in
            // Tell the model
            self?.parentController.onSymbolSelected(viewModel: viewModel, symbol: symbol)
        })
    }
}
