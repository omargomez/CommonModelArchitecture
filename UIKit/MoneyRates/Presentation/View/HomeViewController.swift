//
//  ViewController.swift
//  MoneyRates
//
//  Created by Omar Gomez on 21/2/22.
//

import UIKit
import Combine
import ModelLibrary

extension UIViewController {
    
    func showErrorAlert(title: String, message: String) {
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
         
         // Create OK button with action handler
         let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
          })
         
         //Add OK button to a dialog message
         dialogMessage.addAction(ok)
         // Present Alert to
         self.present(dialogMessage, animated: true, completion: nil)
    }
    
}

class HomeViewController: UIViewController {

    struct Input {
        public let onSelection = PassthroughSubject<SelectionModel, Never>()
    }
    
    var viewModel: HomeViewModel!
    let input = Input()
    
    @IBOutlet weak var targetButton: UIButton!
    @IBOutlet weak var sourceButton: UIButton!
    @IBOutlet weak var sourceField: UITextField!
    @IBOutlet weak var targetField: UITextField!
    @IBOutlet weak var busyIndicator: UIActivityIndicatorView!
    
    private var cancellables: Set<AnyCancellable> = []
    
    convenience init?(coder: NSCoder, viewModel: HomeViewModel) {
        self.init(coder: coder)
        self.viewModel = viewModel
        
        input.onSelection
            .sink(receiveValue: { value in
                if value.mode == .source {
                    viewModel.input.onSource.send(value.symbol)
                } else {
                    viewModel.input.onTarget.send(value.symbol)
                }
            })
            .store(in: &cancellables)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind(output: viewModel.output)
        viewModel.input.onLoad.send()
    }
    

    @IBAction func onSourcePickAction(_ sender: Any) {
        viewModel.input.pickSourceEvent.send()
    }
    
    @IBAction func onTargetPickAction(_ sender: Any) {
        viewModel.input.pickTargetEvent.send()
    }
    
    @IBAction func onSourceChanged(_ sender: UITextField) {
        guard let text = sender.text else {
            return
        }
        
        viewModel.input.onInputSource.send(text)
    }
    
    @IBAction func onTargetChanged(_ sender: UITextField) {
        guard let text = sender.text else {
            return
        }
        
        viewModel.input.onInputTarget.send(text)
    }
}

private extension HomeViewController {
    func bind(output: HomeViewOutput) {
        output.sourceTitle
            .receive(on: RunLoop.main)
            .sink { (title) in
                self.sourceButton.setTitle(title, for: .normal)
            }.store(in: &cancellables)
        
        output.targetTitle
            .receive(on: RunLoop.main)
            .sink { (title) in
                self.targetButton.setTitle(title, for: .normal)
        }.store(in: &cancellables)
        
        output.error
            .compactMap{ $0 }
            .receive(on: RunLoop.main)
            .sink { (error) in
                self.showErrorAlert(title: error.title, message: error.description)
        }.store(in: &cancellables)
        
        output.targetResult
            .compactMap{ $0 }
            .receive(on: RunLoop.main)
            .sink { (value) in
                self.targetField.text = String(describing: value)
        }.store(in: &cancellables)
        
        output.sourceResult
            .compactMap{ $0 }
            .receive(on: RunLoop.main)
            .sink { (value) in
                self.sourceField.text = String(describing: value)
        }.store(in: &cancellables)
                
        output.busy
            .compactMap{ $0 }
            .receive(on: RunLoop.main)
            .sink { (value) in
                self.busyIndicator.isHidden = !value
                if value {
                    self.busyIndicator.startAnimating()
                } else {
                    self.busyIndicator.stopAnimating()
                }
            }.store(in: &cancellables)
    }
}
