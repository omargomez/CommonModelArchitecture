//
//  HomeHostingCoordinator.swift
//  MoneyRates
//
//  Created by Omar Eduardo Gomez Padilla on 14/07/22.
//

import UIKit
import Combine
import ModelLibrary

final class HomeHostingCoordinator: HomeCoordinator {
    
    private weak var parentController: HomeHostingController!
    private var cancellables: Set<AnyCancellable> = []
    
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

private extension HomeHostingCoordinator {
    
    func getUIController(_ mode: PickCurrencyModeEnum) -> PickCurrencyUIViewController {
        let viewModel = PickCurrencyViewModelImpl(mode: mode)
        viewModel.output.selection
            .sink(receiveValue: { value in
                self.dismiss(value)
            })
            .store(in: &self.cancellables)
        return PickCurrencyUIViewController(viewModel: viewModel)
    }
    
    func dismiss(_ selection: SelectionModel) {
        parentController.presentedViewController?.dismiss(animated: true, completion: { [weak self] in
            self?.parentController.input.selection.send(selection)
        })
    }
}
