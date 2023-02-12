//
//  LoginViewController.swift
//  VyperX Messenger
//
//  Created by Lucas Nascimento on 05/02/2023.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var campoEmail: UITextField!
    @IBOutlet weak var campoSenha: UITextField!
    
    var auth: Auth!
    var handler: AuthStateDidChangeListenerHandle!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        auth = Auth.auth()
        
        // Adicionando listener para autenticação do usuario
        handler = auth.addStateDidChangeListener { autenticacao, usuario in
            
            if usuario != nil {
                self.performSegue(withIdentifier: "segueLoginAutomatico", sender: nil)
            }
            
        }
        
    }
     // Removendo o listener apos criação do usuario
    override func viewWillDisappear(_ animated: Bool) {
        //auth.removeStateDidChangeListener(handler)
    }
    
    
    @IBAction func logar(_ sender: Any) {
        
        if let email = campoEmail.text {
            if let senha = campoSenha.text {
                
                auth.signIn(withEmail: email, password: senha) { (usuario, erro) in
                    
                    
                    if erro == nil {
                        if let usuarioLogado = usuario {
                            print("Sucesso ao logar usuario! \(String(describing:usuarioLogado.user.email)) ")
                        }
                    }else {
                       print("Erro ao realizar validação")
                    }
                }
                
                print("Digite sua senha.")
            }else {
                print("Erro ao informar senha")
            }
            print("Digite seu email.")
        }else {
            print("Erro ao digitar email")
        }
        
    }
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func unwindToLogin(_ unwindSegue: UIStoryboardSegue) {
        
    }

}
