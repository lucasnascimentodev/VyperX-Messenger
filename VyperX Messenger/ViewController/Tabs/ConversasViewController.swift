//
//  ConversasViewController.swift
//  VyperX Messenger
//
//  Created by Lucas Nascimento on 15/02/2023.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseStorageUI

class ConversasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var tableViewConversas: UITableView!
    var listaConversas: [Dictionary<String, Any>] = []
    var conversasListener: ListenerRegistration!

    
    var auth: Auth!
    var db: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewConversas.separatorStyle = .none

        auth = Auth.auth()
        db = Firestore.firestore()
        
    }
    
    func addListenerRecuperarConversas()  {
        
        if let idUsuarioLogado = auth.currentUser?.uid {
            conversasListener = db.collection("conversas")
                .document(idUsuarioLogado)
                .collection("ultima_conversa")
                .addSnapshotListener { (querySnapshot, erro) in
                    
                    if erro == nil {
                        
                        self.listaConversas.removeAll()
                        
                        
                        if let snapshot = querySnapshot {
                            for document in snapshot.documents {
                                let dados = document.data()
                                self.listaConversas.append(dados)
                            }
                            self.tableViewConversas.reloadData()
                        }
                    }
                }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listaConversas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celula = tableView.dequeueReusableCell(withIdentifier: "celulaConversas", for: indexPath) as! ConversaTableViewCell
        
        let indice = indexPath.row
        let dados = self.listaConversas[indice]
        let nome = dados ["nomeUsuario"] as? String
        let ultimaMensagem = dados ["ultimaMensagem"] as? String

        celula.nomeConversa.text = nome
        celula.ultimaConversa.text = ultimaMensagem
        
        // Validação da foto do Usuario
        
        if let urlFotoUsuario = dados["urlFotoUsuario"] as? String {
            celula.fotoConversa.sd_setImage(with: URL(string: urlFotoUsuario), completed: nil)

        } else {
            celula.fotoConversa.image = UIImage(named: "imagem-perfil")
        }
        
        return celula
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        addListenerRecuperarConversas()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        conversasListener.remove()
    }
   
}
