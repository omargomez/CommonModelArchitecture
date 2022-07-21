//
//  AppHostingCoordinator.swift
//  MoneyRates
//
//  Created by Omar Eduardo Gomez Padilla on 14/07/22.
//

import Foundation
import UIKit
import ModelLibrary

final class AppHostingCoordinator: AppCoordinator {
    
    private weak var window: UIWindow!
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func goToHome() {
        
        guard let navigationController = UIStoryboard.main.instantiateInitialViewController() as? UINavigationController else {
            return
        }
        
        navigationController.setViewControllers([getUIController()], animated: false)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

    }
    
}

private extension AppHostingCoordinator {
    func getUIController() -> UIViewController {
        let viewModel = HomeViewModelImpl()
        let result = HomeHostingController(viewModel: viewModel)
        viewModel.coordinator = HomeHostingCoordinator(parentController: result)
        return result
    }
}

