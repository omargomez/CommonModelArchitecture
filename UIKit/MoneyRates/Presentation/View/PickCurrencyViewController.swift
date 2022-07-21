//
//  CurrencyViewController.swift
//  MoneyRates
//
//  Created by Omar Gomez on 3/3/22.
//

import UIKit
import Combine
import ModelLibrary

class PickCurrencyViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var cancellables: Set<AnyCancellable> = []
    
    var viewModel: PickCurrencyViewModel!

    convenience init?(coder: NSCoder, viewModel: PickCurrencyViewModel) {
        self.init(coder: coder)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(output: viewModel.output)
    
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")

        viewModel.input.onLoad.send()
    }

}

extension PickCurrencyViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.currencyCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellID") else {
            return UITableViewCell()
        }
        
        let symbol = self.viewModel.symbolAt(at: indexPath.row)
        cell.textLabel?.text = symbol.description
        return cell
    }
}

extension PickCurrencyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.input.onSelection.send(indexPath.row)
    }
}

extension PickCurrencyViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.viewModel.input.cancelSearch.send(())
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel.input.search.send(searchText)
    }
    
}


private extension PickCurrencyViewController {
    func bind(output: PickCurrencyViewOutput) {
        output.symbols
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] symbols in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)
        
        output.searchEnabled
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                self?.searchBar.text = nil
                self?.searchBar.resignFirstResponder()
            })
            .store(in: &cancellables)
        
        output.error
            .compactMap{ $0 }
            .receive(on: RunLoop.main)
            .sink { (error) in
                self.showErrorAlert(title: error.title, message: error.description)
            }
            .store(in: &cancellables)
        
    }
}
