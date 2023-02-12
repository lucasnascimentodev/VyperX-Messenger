//
//  CadastroViewController.swift
//  VyperX Messenger
//
//  Created by Lucas Nascimento on 07/02/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CadastroContatoViewController: UIViewController {
    
    
    @IBOutlet weak var campoEmail: UITextField!
    @IBOutlet weak var mensagemErro: UILabel!
    
    // Referencias para recuperar ID do Usuario
    var idUsuarioLogado: String!
    var emailUsuarioLogado: String!

    
    var auth:Auth!
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()
        db = Firestore.firestore()
        
        // Recupera ID do usuario logado
        if let currentUser = auth.currentUser {
            self.idUsuarioLogado = currentUser.uid
            self.emailUsuarioLogado = currentUser.email
        }

    }
    
    
    @IBAction func adicionarContato(_ sender: Any) {
        
        if let emailDigitado = campoEmail.text {
            if emailDigitado == self.emailUsuarioLogado {
                mensagemErro.isHidden = false
                mensagemErro.text = "Não é possivel adicionar seu proprio e-mail"
                return
            }
            
            // Verificação de usuario registrado no Firestore
            db.collection("usuarios")
                .whereField("email", isEqualTo: emailDigitado)
                .getDocuments { (snapshotResultado, erro) in
                    
                    // Conta o total de retornos
                    if let totalItens = snapshotResultado?.count {
                        if totalItens == 0 {
                            self.mensagemErro.text  = "Usuario não registrado"
                            self.mensagemErro.isHidden = false
                            return
                        }  
                    }
                    
                    // Salvando contato
                    if let snapshot = snapshotResultado {
                        for document in snapshot.documents{
                            let dados = document.data()
                            self.salvarContatos(dadosContato: dados)
                        }
                    }
                    
            }
            
        }
        
    }
    
   
    func salvarContatos(dadosContato: Dictionary<String, Any>) {
        
        if let idusuarioContato = dadosContato["id"] {
            db.collection("usuarios")
                .document(idUsuarioLogado)
                .collection("contatos")
                .document(String(describing: idusuarioContato) )
                .setData(dadosContato) { (erro) in
                    if erro == nil {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
        }
        
       
    }

}
