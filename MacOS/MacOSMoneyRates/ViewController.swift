//
//  ViewController.swift
//  MacOSMoneyRates
//
//  Created by Omar Eduardo Gomez Padilla on 15/07/22.
//

import Cocoa
import ModelLibrary
import SwiftUI

class ViewController: NSHostingController<HomeUIView> {

    weak var model: HomeViewModelImpl!
    
    required init?(coder: NSCoder) {
        let model = HomeViewModelImpl()
        super.init(coder: coder, rootView: HomeUIView(viewModel: model) )
        self.model = model
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.coordinator = HomeHostingCoordinator(parentController: self)

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

private extension ViewController {
    
}

final class HomeHostingCoordinator: HomeCoordinator {
    
    private weak var parentController: ViewController!
    private weak var pickerController: NSViewController!
    
    init(parentController: ViewController) {
        self.parentController = parentController
    }
    
    func goToPickSource() {
        // Show
        let pickerController = PickerController(parentCoordinator: self)
        parentController.presentAsModalWindow(pickerController)
//        self.parentController.view.window?.beginSheet(<#T##sheetWindow: NSWindow##NSWindow#>)
        self.parentController.view.window.shee
        self.pickerController = pickerController
        
    }
    
    func goToPickTarget() {
//        let controller  = getUIController(.target)
//        parentController.present(controller, animated: true)
        print("###> pick target")
    }
}

extension HomeHostingCoordinator: PickCurrencyViewModelDelegate {
    func onSymbolSelected(viewModel: PickCurrencyViewModel, symbol: SymbolModel) {
        print("onSymbolSelected: \(symbol.description)")
        self.parentController.dismiss(self.parentController.presentedViewControllers?.first!)
//        print("presentedViewControllerss: \(self.parentController.presentedViewControllers)")
//        self.parentController.presentedViewControllers?.first?.dismiss()
    }
}
