//
//  ContatosViewController.swift
//  VyperX Messenger
//
//  Created by Lucas Nascimento on 06/02/2023.
//

import UIKit

class ContatosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var tableViewContatos: UITableView!
    @IBOutlet weak var searchBarContatos: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tableViewContatos.separatorStyle = .none
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Pesquisa:" + String(searchText))
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celula = tableView.dequeueReusableCell(withIdentifier: "celulaContatos", for: indexPath) as! ContatoTableViewCell
        
        let indice = indexPath.row
        
        celula.nome.text = "Lucas Nascimento" + String(indice)
        celula.email.text = "teste@teste.com" + String(indice)
    
        
        return celula
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}
