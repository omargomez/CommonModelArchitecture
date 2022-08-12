//
//  ViewController.swift
//  AppkitConverter
//
//  Created by Omar Gómez on 8/8/22.
//

import Cocoa
import Combine
import ModelLibrary

class ViewController: NSViewController {

    @IBOutlet weak var sourceButton: NSButton!
    @IBOutlet weak var targetButton: NSButton!
    @IBOutlet weak var sourceField: NSTextField!
    @IBOutlet weak var targetField: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    private let viewModel: HomeViewModelImpl
    private var cancellables: Set<AnyCancellable> = []
    
    
    required init?(coder: NSCoder) {
        self.viewModel = HomeViewModelImpl()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel.coordinator = self
        bind(self.viewModel.output)
        self.viewModel.input.onLoad.send()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func sourceAction(_ sender: Any) {
        self.viewModel.input.pickSourceEvent.send()
    }

    @IBAction func onTargetAction(_ sender: Any) {
        self.viewModel.input.pickTargetEvent.send()
    }
}

extension ViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        if let text = obj.object as? NSTextField {
            if text == self.sourceField {
                viewModel.input.onInputSource.send(sourceField.stringValue)
            } else {
                viewModel.input.onInputTarget.send(sourceField.stringValue)
            }
        }
    }
}


private extension ViewController {
    func bind(_ output: HomeViewOutput) {
        output.sourceTitle
            .sink(receiveValue: { value in
                self.sourceButton.title = value
            })
            .store(in: &cancellables)
        
        output.targetTitle
            .sink(receiveValue: { value in
                self.targetButton.title = value
            })
            .store(in: &cancellables)
        
        output.error
            .sink(receiveValue: { value in // TODO alert
                print("Error: \(value)")
            })
            .store(in: &cancellables)
        
        output.sourceResult
            .compactMap({$0}) //TODO: Is this expecting nil?
            .sink(receiveValue: { value in
                self.sourceField.stringValue = value.description
            })
            .store(in: &cancellables)
        
        output.targetResult
            .compactMap({$0})
            .sink(receiveValue: { value in
                self.targetField.stringValue = value.description
            })
            .store(in: &cancellables)
        
        output.busy
            .sink(receiveValue: { value in
                self.progressIndicator.isHidden = !value
                if value {
                    self.progressIndicator.startAnimation(self)
                } else {
                    self.progressIndicator.stopAnimation(self)
                }
            })
            .store(in: &cancellables)
    }
    
    
}


extension ViewController: HomeCoordinator {
    func goToPickSource() {
        doSheet(true)
    }
    
    func goToPickTarget() {
        doSheet(false)
    }
    
    private func doSheet(_ source: Bool) {
        let storyboardName = NSStoryboard.Name(stringLiteral: "Main")
        let storyboard = NSStoryboard(name: storyboardName, bundle: nil)
        
        let sceneIdentifier = NSStoryboard.SceneIdentifier(stringLiteral: "PickerWindowController")
        guard let windowController = storyboard.instantiateController(withIdentifier: sceneIdentifier) as? NSWindowController,
              let resizeWindow = windowController.window,
              let controller = windowController.contentViewController as? CurrencyPickerViewController
        else {
            return }
        
        self.view.window?.beginSheet(resizeWindow, completionHandler: { (response) in
            if response == NSApplication.ModalResponse.OK, let selection = controller.selection {
                if source {
                    self.viewModel.input.onSource.send(selection.symbol)
                    
                } else {
                    self.viewModel.input.onTarget.send(selection.symbol)
                }
            }
        })
    }
}
