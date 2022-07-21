//
//  UIKitAppCoordinator.swift
//  MoneyRates
//
//  Created by Omar Eduardo Gomez Padilla on 14/07/22.
//

import UIKit
import ModelLibrary

final class AppCoordinatorImpl: AppCoordinator {
    
    private weak var window: UIWindow!
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func goToHome() {
        
        guard let navigationController = UIStoryboard.main.instantiateInitialViewController() as? UINavigationController else {
            return
        }
        
        let controller = UIStoryboard.main.instantiateViewController(identifier: "homeController", creator: { coder in
            
            let viewModel = HomeViewModelImpl()
            guard let result = HomeViewController(coder: coder, viewModel: viewModel) else {
                fatalError("HomeViewController failed")
            }
            viewModel.coordinator = HomeCoordinatorImpl(parentController: result)
            return result
            
        })
        
        navigationController.setViewControllers([controller], animated: false)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

    }
    
}
