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
    
    var auth:Auth!
    var firestore: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func adicionarContato(_ sender: Any) {
    }
    

}
