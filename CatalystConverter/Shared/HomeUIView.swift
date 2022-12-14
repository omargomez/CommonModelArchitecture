//
//  HomeUIView.swift
//  MoneyRates
//
//  Created by Omar Gomez on 10/6/22.
//

import SwiftUI
import Combine
import ModelLibrary

private class HomeCoordinatorImpl: HomeCoordinator {
    
    struct Output {
        let onPickEvent = PassthroughSubject<PickCurrencyModeEnum, Never>()
    }
    
    let output = Output()
    
    func goToPickSource() {
        output.onPickEvent.send(.source)
    }
    
    func goToPickTarget() {
        output.onPickEvent.send(.target)
    }
    
    
}

struct HomeUIView: View {
    
    @ObservedObject private var viewModel: HomeViewModelImpl
    @State private var sourceAmount: String = ""
    @State private var targetAmount: String = ""
    @State var errorAlert: Bool = false
    @FocusState private var sourceFocused: Bool
    @FocusState private var targetFocused: Bool
    @State private var showCurrencyPicker = false
    @State private var pickerMode: PickCurrencyModeEnum?
    private let homeCoordinator: HomeCoordinatorImpl
    
    init(viewModel: HomeViewModelImpl = HomeViewModelImpl() ) {
        self.viewModel = viewModel
        homeCoordinator = HomeCoordinatorImpl()
        self.viewModel.coordinator = homeCoordinator
    }
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                    .frame(width: 16.0)
                VStack(spacing: 8.0) {
                    Spacer()
                    Button(action: {
                        viewModel.input.pickSourceEvent.send()
                    }, label: {
                        Text(viewModel.sourceTitle)
                    })
                    .appButtonStyle()
                    TextField("Source amount", text: $sourceAmount)
                        .focused($sourceFocused)
                        .onChange(of: sourceAmount, perform: { newValue in
                            if sourceFocused {
                                viewModel.input.onInputSource.send(newValue)
                            }
                        })
                        .appTextFieldStyle()
                    Spacer()
                        .frame(height: 8.0)
                    TextField("Target amount", text: $targetAmount)
                        .focused($targetFocused)
                        .onChange(of: targetAmount, perform: { newValue in
                            if targetFocused {
                                viewModel.input.onInputTarget.send(newValue)
                            }
                        })
                        .appTextFieldStyle()
                    Button(action: {
                        viewModel.input.pickTargetEvent.send()
                    }, label: {
                        Text(viewModel.targetTitle)
                    })
                    .appButtonStyle()
                    Spacer()
                }
                Spacer()
                    .frame(width: 16.0)
            }
            if viewModel.busy {
                ProgressView()
            }
        }
        .sheet(isPresented: $showCurrencyPicker, onDismiss: {
            showCurrencyPicker = false
            pickerMode = nil
        }) {
            pickerView()
        }
        .onReceive( homeCoordinator.output.onPickEvent ) { mode in
            pickerMode = mode
        }
        .onAppear(perform: {
            viewModel.input.onLoad.send()
        })
        .onChange(of: viewModel.targetResult, perform: { newValue in
            if !targetFocused, let text = newValue?.description {
                targetAmount = text
            }
        })
        .onChange(of: viewModel.sourceResult, perform: { newValue in
            if !sourceFocused, let text = newValue?.description {
                sourceAmount = text
            }
        })
        .onChange(of: pickerMode, perform: { newValue in
            showCurrencyPicker =  (newValue != nil)
        })
        .onReceive(viewModel.output.error, perform: { value in
            errorAlert = true
        })
        .alert(isPresented: $errorAlert, content: {
            Alert(title: Text(viewModel.error?.title ?? "--"), message:
                    Text(viewModel.error?.description ?? "--"),
                  dismissButton: .cancel())
        })
    }
}

private extension HomeUIView {
    func pickerView() -> some View {
#if os(macOS)
        return macosPicker()
#elseif os(iOS)
        return iosPicker()
#else
        #error("Not supported platform")
#endif
    }
    
}

#if os(iOS)
private extension HomeUIView {
    func iosPicker() -> some View {
        let model = PickCurrencyViewModelImpl(mode: pickerMode!)
        return PickCurrencyUIView(viewModel: model)
            .onReceive( model.output.selection, perform: { value in
                showCurrencyPicker = false
                pickerMode = nil
                if value.mode == .source {
                    viewModel.input.onSource.send(value.symbol)
                } else {
                    viewModel.input.onTarget.send(value.symbol)
                }
            })
    }
}
#endif

#if os(macOS)
private extension HomeUIView {
    func macosPicker() -> some View {
        let model = PickCurrencyViewModelImpl(mode: pickerMode!)
        return DesktopPickCurrencyUIView(viewModel: model)
            .onReceive( model.output.selection, perform: { value in
                showCurrencyPicker = false
                pickerMode = nil
                if value.mode == .source {
                    viewModel.input.onSource.send(value.symbol)
                } else {
                    viewModel.input.onTarget.send(value.symbol)
                }
            })
        
    }
}
#endif

struct HomeUIView_Previews: PreviewProvider {
    static var previews: some View {
        HomeUIView(viewModel: HomeViewModelImpl())
    }
}

