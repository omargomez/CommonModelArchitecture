//
//  CurrencyPickerViewController.swift
//  AppkitConverter
//
//  Created by Omar Gómez on 8/8/22.
//

import Cocoa
import Combine
import ModelLibrary

class CurrencyPickerViewController: NSViewController {

    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var tableView: NSTableView!
    
    private let viewModel: PickCurrencyViewModelImpl
    private var cancellables: Set<AnyCancellable> = []
    
    var selection: SelectionModel?
    
    required init?(coder: NSCoder) {
        self.viewModel = PickCurrencyViewModelImpl(mode: .source)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        bind(self.viewModel.output)
        viewModel.input.onLoad.send()
    }
    
    @IBAction func closeAction(_ sender: Any) {
        guard let window = self.view.window, let parent = window.sheetParent else { return }
        parent.endSheet(window, returnCode: .cancel)
    }
}

extension CurrencyPickerViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        viewModel.input.search.send(searchField.stringValue)
    }
}

private extension CurrencyPickerViewController {
    
    func bind(_ output: PickCurrencyViewOutput) {
        
        output.symbols
            .receive(on: RunLoop.main)
            .sink(receiveValue: { value in
                self.tableView.reloadData()
            })
            .store(in: &cancellables)
        
        output.selection
            .sink(receiveValue: { value in
                self.selection = value
                guard let window = self.view.window, let parent = window.sheetParent else { return }
                parent.endSheet(window, returnCode: .OK)
            })
            .store(in: &cancellables)
    }
}

extension CurrencyPickerViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        viewModel.currencyCount()
    }
}

extension CurrencyPickerViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let result = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cellID"), owner: self) as? NSTableCellView else {
            return nil
        }
        
        result.textField?.stringValue = viewModel.symbolAt(at: row).description
        return result

    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        viewModel.input.onSelection.send(self.tableView.selectedRow)
    }
}
