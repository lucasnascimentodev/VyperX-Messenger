//
//  ContatosViewController.swift
//  VyperX Messenger
//
//  Created by Lucas Nascimento on 06/02/2023.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseStorageUI

class ContatosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var tableViewContatos: UITableView!
    @IBOutlet weak var searchBarContatos: UISearchBar!
    
    var auth: Auth!
    var db: Firestore!
    var idUsuarioLogado: String!
    var listaDeContatos: [Dictionary <String, Any >] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        searchBarContatos.delegate = self
        tableViewContatos.separatorStyle = .none
        
        auth = Auth.auth()
        db = Firestore.firestore()
        
        // Recuperar id usuario logado
        if let id = auth.currentUser?.uid {
            self.idUsuarioLogado = id
        }
       
    }
     // Faz o Recarregamento dos dados mediante a atualização da pagina
    override func viewDidAppear(_ animated: Bool) {
        recuperarContatos()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let textoResultado = searchBar.text {
            if textoResultado != " " {
                pesquisarContatos(texto: textoResultado)
                if searchText == "" {
                    recuperarContatos()
                }
            }
        }
    }
    
    func pesquisarContatos(texto:String) {
        var listaFiltro: [Dictionary <String, Any >] = self.listaDeContatos
        self.listaDeContatos.removeAll()
        
        for item in listaFiltro {
            if let nome = item ["nome"] as? String {
                if nome.lowercased().contains(texto.lowercased() ) {
                    self.listaDeContatos.append(item)
                }
            }
        }
        
        self.tableViewContatos.reloadData()
    }
    
    
    func recuperarContatos() {
       self.listaDeContatos.removeAll()
        db.collection("usuarios")
            .document(idUsuarioLogado)
            .collection("contatos")
            .getDocuments { (snapshotResultado, erro) in
                
                if let snapshot = snapshotResultado {
                    for document in  snapshot.documents {
                        
                        let dadosContato = document.data()
                        self.listaDeContatos.append(dadosContato)
                        
                    }
                    self.tableViewContatos.reloadData()
                }
            }
        
    }
    
    //---------------------------------TableViews // -------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listaDeContatos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celula = tableView.dequeueReusableCell(withIdentifier: "celulaContatos", for: indexPath) as! ContatoTableViewCell
        
        //Condição de retorno caso naõ localize contato
        celula.fotoContato.isHidden = false
        if self.listaDeContatos.count == 0 {
            celula.nome.text = "Nenhum contato encontrado"
            celula.email.text = ""
            celula.fotoContato.isHidden = true
            return celula
        }
        
        let indice = indexPath.row
        let dadosContato = self.listaDeContatos[indice]
        
        
        celula.nome.text = dadosContato["nome"] as? String
        celula.email.text = dadosContato["email"] as? String
        
        if let foto = dadosContato["urlImagem"] as? String {
            celula.fotoContato.sd_setImage(with: URL(string: foto),
                                           completed: nil )
        }else {
            celula.fotoContato.image = UIImage(named: "imagem-perfil")
        }
    
        
        return celula
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Qual linha foi selecionada pelo usuario
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableViewContatos.deselectRow(at: indexPath, animated: true)
        
        let indice = indexPath.row
        let contato = self.listaDeContatos [indice]
        
        self .performSegue(withIdentifier: "iniciarConversaContato", sender: contato)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "iniciarConversaContato" {
            let viewDestino = segue.destination as! MensagensViewController
            viewDestino.contato = sender as? Dictionary
        }
    }
    
}
