//
//  HomeViewModel.swift
//  MoneyRates
//
//  Created by Omar Gomez on 21/2/22.
//

import Foundation
import Combine

public struct AmountViewModel: CustomStringConvertible, Equatable {
    public let value: Double
    
    public var description: String {
        String(format: "%.2f", value)
    }
}

public struct HomeViewInput {
    public let onLoad = PassthroughSubject<Void, Never>()
    public let onInputSource = PassthroughSubject<String, Never>()
    public let onInputTarget = PassthroughSubject<String, Never>()
    public let pickSourceEvent = PassthroughSubject<Void, Never>()
    public let pickTargetEvent = PassthroughSubject<Void, Never>()
    public let onSource = PassthroughSubject<SymbolModel, Never>()
    public let onTarget = PassthroughSubject<SymbolModel, Never>()
}

public struct HomeViewOutput {
    public let sourceTitle: AnyPublisher<String, Never>
    public let targetTitle: AnyPublisher<String, Never>
    public let error: AnyPublisher<ErrorViewModel?, Never>
    public let sourceResult: AnyPublisher<AmountViewModel?, Never>
    public let targetResult: AnyPublisher<AmountViewModel?, Never>
    public let busy: AnyPublisher<Bool, Never>
}

public protocol HomeViewModel {
    var input: HomeViewInput { get }
    var output: HomeViewOutput { get }
}

public enum HomeViewModelError: LocalizedError {
    case error
    
    public var errorDescription: String? {
        "Some error"
    }
}

public class HomeViewModelImpl: HomeViewModel, ObservableObject {
    @Published public var sourceTitle: String
    @Published public var targetTitle: String
    @Published public var error: ErrorViewModel? = nil
    @Published public var sourceResult: AmountViewModel? = nil
    @Published public var targetResult: AmountViewModel? = nil
    @Published public var busy: Bool = false
    
    public let input = HomeViewInput()
    public var output: HomeViewOutput {
        _output
    }
    
    private var _output: HomeViewOutput!
    public var coordinator: HomeCoordinator? = nil
    let conversionUC: ConversionUseCase
    let resetDataUC: ResetDataUsecase
    
    private var cancellables: Set<AnyCancellable> = []
    typealias ConversionType = Result<Double, Error>
    
    
    init(symbolRepository: SymbolRepository, exchangeService: ExchangeRateService,
         conversionUC: ConversionUseCase,
         resetDataUC: ResetDataUsecase) {
        
        self.conversionUC = conversionUC
        self.resetDataUC = resetDataUC
        
        self.sourceTitle = "Select source currency"
        self.targetTitle = "Select target currency"
        self._output = bind(input: input)
    }
    
    public convenience init() {
        self.init(symbolRepository: SymbolRepositoryImpl(), exchangeService: ExchangeRateServiceImpl(), conversionUC: ConversionUseCaseImpl(), resetDataUC: ResetDataUseCaseImpl())
    }

}

private extension HomeViewModelImpl {

    func bind(input: HomeViewInput) -> HomeViewOutput {
    
        input.pickSourceEvent
            .sink(receiveValue: {
                self.coordinator?.goToPickSource()
            }).store(in: &cancellables)
        
        input.pickTargetEvent
            .sink(receiveValue: {
                self.coordinator?.goToPickTarget()
            })
            .store(in: &cancellables)
        
        input.onSource
            .map({ symbol -> String in
                return symbol.description
            })
            .assign(to: &self.$sourceTitle)
        
        input.onTarget
            .map({ symbol -> String in
                return symbol.description
            })
            .assign(to: &self.$targetTitle)
        
        input.onLoad
            .handleEvents(receiveOutput: { _ in
                self.busy = true
            })
            .map({
                self.resetDataUC.execute()
                    .catch { _ -> Just<Bool> in
                        Just(false)
                    }
            })
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                self.busy = false
            })
            .store(in: &cancellables)
        
        setup(input: input.onInputSource,
              sourceSymbol: input.onSource,
              targetSymbol: input.onTarget)
            .sink(receiveValue: { result in
                switch result {
                case .success(let amount):
                    self.targetResult = AmountViewModel(value: amount)
                case .failure(let error):
                    self.error = ErrorViewModel(error: error)
                }
            })
        
            .store(in: &cancellables)
        setup(input: input.onInputTarget,
              sourceSymbol: input.onTarget,
              targetSymbol: input.onSource)
            .sink(receiveValue: { result in
                switch result {
                case .success(let amount):
                    self.sourceResult = AmountViewModel(value: amount)
                case .failure(let error):
                    self.error = ErrorViewModel(error: error)
                }
            })
            .store(in: &cancellables)
        
        return HomeViewOutput(sourceTitle: $sourceTitle.eraseToAnyPublisher(),
                              targetTitle: $targetTitle.eraseToAnyPublisher(),
                              error: $error.eraseToAnyPublisher(),
                              sourceResult: $sourceResult.eraseToAnyPublisher(),
                              targetResult: $targetResult.eraseToAnyPublisher(),
                              busy: $busy.eraseToAnyPublisher())
    }
    
    func setup(input: PassthroughSubject<String, Never>,
               sourceSymbol: PassthroughSubject<SymbolModel, Never>,
               targetSymbol: PassthroughSubject<SymbolModel, Never>
    ) -> AnyPublisher<ConversionType, Never> {
        input
            .compactMap({ text -> Double? in
                guard let val = Double(text),
                      val >= 0.01 else {
                          return nil
                      }
                return val
            })
            .combineLatest(sourceSymbol, targetSymbol)
            .handleEvents(receiveOutput: { _ in
                self.busy = true
            })
            .map({ (amount, source, target) in
                self.conversionUC.execute(sourceSymbol: source.id, targetSymbol: target.id, amount: amount)
                .map({ val -> ConversionType in
                    return .success(val)
                })
                .catch({ error -> Just<ConversionType> in
                    return Just(.failure(error))
                })
            })
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { _ in
                self.busy = false
            })
            .eraseToAnyPublisher()
    }
}
