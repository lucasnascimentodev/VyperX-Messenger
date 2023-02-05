//
//  AjustesViewController.swift
//  VyperX Messenger
//
//  Created by Lucas Nascimento on 06/02/2023.
//

import UIKit
import FirebaseAuth

class AjustesViewController: UIViewController {
    
    var auth: Auth!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()

    }
    
    @IBAction func deslogar(_ sender: Any) {
        
        do {
            try auth.signOut()
            print("Usuario deslogado com sucesso")
        } catch  {
            print("Erro ao deslogar usuario")
        }
        
    }
    
    

}
