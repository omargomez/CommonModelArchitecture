//
//  PickCurrencyViewModel.swift
//  MoneyRates
//
//  Created by Omar Gomez on 3/3/22.
//

import Foundation
import Combine

public enum PickCurrencyModeEnum {
    case source
    case target
}

public struct ErrorViewModel: Equatable {
    public let title: String
    public let description: String
}

public struct SelectionModel {
    public let symbol: SymbolModel
    public let mode: PickCurrencyModeEnum
}

extension ErrorViewModel {
    public init(error: Error) {
        self.init(title: "An Error Occurred", description: error.localizedDescription)
    }
}

public struct PickCurrencyViewInput {
    public let onLoad = PassthroughSubject<Void, Never>()
    public let onSelection = PassthroughSubject<Int, Never>()
    public let cancelSearch = PassthroughSubject<Void, Never>()
    public let search = PassthroughSubject<String, Never>()
}

public struct PickCurrencyViewOutput {
    public let symbols: AnyPublisher<[SymbolModel], Never>
    public let error: AnyPublisher<ErrorViewModel, Never>
    public let searchEnabled: AnyPublisher<Bool, Never>
    public let selection: AnyPublisher<SelectionModel, Never>
}

public protocol PickCurrencyViewModel {
    
    func currencyCount() -> Int
    func symbolAt(at: Int) -> SymbolModel
    
    var input: PickCurrencyViewInput { get }
    var output: PickCurrencyViewOutput { get }
}

final public class PickCurrencyViewModelImpl: PickCurrencyViewModel, ObservableObject {
    
    private let userCase: SymbolUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    public let input: PickCurrencyViewInput = PickCurrencyViewInput()
    public var output: PickCurrencyViewOutput {
        _output
    }
    
    private var _output: PickCurrencyViewOutput!
    
    // Combine
    @Published var error: ErrorViewModel? = nil
    @Published var searchEnabled: Bool = false
    @Published var symbols: [SymbolModel] = []
    @Published var selection: SelectionModel? = nil
    
    init(useCase: SymbolUseCase, mode: PickCurrencyModeEnum) {
        self.userCase = useCase
        _output = bind(input: input, mode: mode)
    }
    
    public convenience init(mode: PickCurrencyModeEnum) {
        self.init(useCase: SymbolUseCaseImpl(), mode: mode)
    }
    
    public func currencyCount() -> Int {
        return symbols.count
    }
    
    public func symbolAt(at: Int) -> SymbolModel {
        symbols[at]
    }
    
    private func bind(input: PickCurrencyViewInput, mode: PickCurrencyModeEnum) -> PickCurrencyViewOutput {
        typealias SymbolsType = Result<[SymbolModel], Error>
        input.onLoad
            .map({
                self.userCase.symbols()
                    .map({$0.sorted(by:{$0.description < $1.description})})
                    .map({ val -> SymbolsType in
                        return .success(val)
                    })
                    .catch({ error -> Just<SymbolsType> in
                        return Just(.failure(error))
                    })
            })
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { value in
                switch value {
                case .success(let symbols):
                    self.symbols = symbols
                    print("sunbol sink: \(self.symbols.count)")
                case .failure(let error):
                    self.error = ErrorViewModel(error: error)
                }
            })
            .store(in: &cancellables)
        
        input.search
            .compactMap({self.userCase.filterSymbols(text: $0)})
            .compactMap({$0.sorted(by:{$0.description < $1.description})})
            .receive(on: DispatchQueue.main)
            .assign(to: &$symbols)
        
        input.cancelSearch
            .compactMap({self.userCase.filterSymbols(text: nil)})
            .compactMap({$0.sorted(by:{$0.description < $1.description})})
            .sink(receiveValue: { value in
                self.symbols = value
                self.searchEnabled = false
            })
            .store(in: &cancellables)
        
        input.onSelection
            .sink(receiveValue: { value in
                let symbol = self.symbols[value]
                self.selection = SelectionModel(symbol: symbol, mode: mode)
            })
            .store(in: &cancellables)
        
        return PickCurrencyViewOutput(
            symbols: $symbols.eraseToAnyPublisher(),
            error: $error.compactMap({$0}).eraseToAnyPublisher(),
            searchEnabled: $searchEnabled.eraseToAnyPublisher(),
            selection: $selection.compactMap({$0}).eraseToAnyPublisher())
    }
}
