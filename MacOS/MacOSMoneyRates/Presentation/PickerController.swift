//
//  PickerController.swift
//  MacOSMoneyRates
//
//  Created by Omar Eduardo Gomez Padilla on 18/07/22.
//

import Cocoa
import ModelLibrary
import SwiftUI

class PickerController: NSHostingController<PickCurrencyUIView> {

    weak var model: PickCurrencyViewModelImpl!
    weak var parentCoordinator: HomeHostingCoordinator!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: PickCurrencyUIView() )
    }
    
    init(parentCoordinator: HomeHostingCoordinator) {
        super.init(rootView: PickCurrencyUIView() )
        self.parentCoordinator = parentCoordinator
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.rootView.viewModel.delegate = self.parentCoordinator
    }
}

