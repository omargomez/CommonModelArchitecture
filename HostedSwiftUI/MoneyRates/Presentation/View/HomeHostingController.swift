//
//  HomeHostingController.swift
//  MoneyRates
//
//  Created by Omar Gomez on 10/6/22.
//

import Foundation
import SwiftUI
import Combine
import ModelLibrary

class HomeHostingController: UIHostingController<HomeUIView> {
    
    struct Input {
        let selection = PassthroughSubject<SelectionModel, Never>()
    }
    
    private let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()
    let input = Input()
    
    init(viewModel: HomeViewModelImpl) {
        self.viewModel = viewModel
        super.init(rootView: HomeUIView(viewModel: viewModel))
        
        input.selection
            .sink(receiveValue: { value in
                if value.mode == .source {
                    self.viewModel.input.onSource.send(value.symbol)
                } else {
                    self.viewModel.input.onTarget.send(value.symbol)
                }
            })
            .store(in: &cancellables)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
