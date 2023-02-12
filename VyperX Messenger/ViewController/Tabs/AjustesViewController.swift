//
//  AjustesViewController.swift
//  VyperX Messenger
//
//  Created by Lucas Nascimento on 06/02/2023.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseStorageUI

class AjustesViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nome: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var imagem: UIImageView!
    
    
    var auth: Auth!
    var storage: Storage!
    var firestore: Firestore!
    var imagePicker = UIImagePickerController ()
    var idUsuario: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        auth = Auth.auth()
        storage = Storage.storage()
        firestore = Firestore.firestore()
        
        // Recuperar id usuario logado
        if let id = auth.currentUser?.uid {
            self.idUsuario = id
        }
        
        // Recupera dados do usuario
        recuperarDadosUsuario()
        
    }
    
    // Função para recuperar dados
    func recuperarDadosUsuario() {
        
        // Criado para acessar firestore
        let usuariosRef = self.firestore
            .collection("usuarios")
            .document(idUsuario)
        
        // Acessando a variavel criada
        usuariosRef.getDocument { (snapshot,erro) in
            
            // Recuperando o usuario e email
            if let dados = snapshot?.data() {
                
                let nomeUsuario = dados ["nome"] as? String
                let emailUsuario = dados ["email"] as? String
                
                self.nome.text = nomeUsuario
                self.email.text = emailUsuario
                
                // Recuperando imagem
                if let urlImagem = dados["urlImagem"] as? String {
                    self.imagem.sd_setImage(with: URL(string: urlImagem), completed: nil)
                }
                
            }
            
        }
        
    }
    
    
    @IBAction func alterarimagem(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let imagemRecuperada = info [UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        self.imagem.image = imagemRecuperada
        
        let imagens = storage
            .reference()
            .child("imagens")
        
        if let imagemUpload = imagemRecuperada.jpegData(compressionQuality: 0.3) {
            
            if let usuarioLogado = auth.currentUser {
                
                let idUsuario = usuarioLogado.uid
                
                let nomeImagem = "\(idUsuario).jpg"
                let imagemPerfilRef = imagens.child("perfil").child(nomeImagem)
                
                imagemPerfilRef.putData(imagemUpload,metadata: nil) {
                    (metaData, erro) in
                    
                    if erro == nil {
                        
                        imagemPerfilRef.downloadURL { (url, erro) in
                            if let urlImagem = url?.absoluteString {
                                self.firestore
                                    .collection("usuarios")
                                    .document(idUsuario)
                                    .updateData([
                                        "urlImagem":urlImagem
                                    ])
                            }
                        }
                        
                        print("Sucesso ao fazer upload da imagem")
                        
                    }else {
                        print("Erro ao fazer upload de imagem")
                    }
                }
                
                imagePicker.dismiss(animated: true, completion: nil)
            }
        }
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
    


