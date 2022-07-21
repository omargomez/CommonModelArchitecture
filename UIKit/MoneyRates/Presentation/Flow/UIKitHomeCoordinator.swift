//
//  UIKitHomeCoordinator.swift
//  MoneyRates
//
//  Created by Omar Eduardo Gomez Padilla on 14/07/22.
//

import UIKit
import Combine
import ModelLibrary

final class HomeCoordinatorImpl: HomeCoordinator {
    
    private weak var parentController: HomeViewController!
    private var cancellables: Set<AnyCancellable> = []
    
    init(parentController: HomeViewController) {
        self.parentController = parentController
    }
    
    func goToPickSource() {
        let controller  = getController(.source)
        parentController.present(controller, animated: true)
    }
    
    func goToPickTarget() {
        let controller  = getController(.target)
        parentController.present(controller, animated: true)
    }
}

private extension HomeCoordinatorImpl {
    
    func getController(_ mode: PickCurrencyModeEnum) -> PickCurrencyViewController {
        let controller = UIStoryboard.main.instantiateViewController(identifier: "currencyViewController", creator: { coder in
            let viewModel = PickCurrencyViewModelImpl(mode: mode)
            viewModel.output.selection
                .sink(receiveValue: { value in
                    self.dismiss(value)
                })
                .store(in: &self.cancellables)
            let result = PickCurrencyViewController(coder: coder, viewModel: viewModel)
            return result
        }) as! PickCurrencyViewController
        return controller
    }
    
    func dismiss(_ selection: SelectionModel) {
        parentController.presentedViewController?.dismiss(animated: true, completion: { [weak self] in
            // Tell the model
            self?.parentController.input.onSelection.send(selection)
        })
        
    }
}
