//
//  MensagensViewController.swift
//  VyperX Messenger
//
//  Created by Lucas Nascimento on 09/02/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class MensagensViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableViewMensagens: UITableView!
    
    @IBOutlet weak var fotoBotao: UIButton!
    
    @IBOutlet weak var mensagemCaixaTexto: UITextField!
    
    var listaMensagens: [Dictionary<String, Any>]! = []
    var idUsuarioLogado: String!
    var contato: Dictionary <String, Any>!
    var mensagemListener: ListenerRegistration!
    var imagePicker = UIImagePickerController ()
    var nomeContato: String!
    var urlFotoContato: String!


    var auth: Auth!
    var db: Firestore!
    var storage: Storage!

    
    
/* ------------------------------------------------------------------ */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self

        
        auth = Auth.auth()
        db = Firestore.firestore()
        storage = Storage.storage()
        
        // Recuperar id usuario logado
        if let id = auth.currentUser?.uid {
            self.idUsuarioLogado = id
        }
        
        // Configura titulo da tela
        if let nome = contato["nome"] {
            nomeContato = nome as? String
            self.navigationItem.title = nomeContato
        }
        
        if let url = contato["urlImagem"] as? String {
            urlFotoContato = url
        }
        
        // Configurações tableView
        tableViewMensagens.separatorStyle = .none
       

        // Configurações lista de mensagens
        //listaMensagens = ["Olá tudo bem ?", "Tudo otimo", "Estou precisando falar urgente com você, sera que você poderia ir na farmacia para mim comprar alguns medicamentos ? Estou bastante doente", "Claro, quais ?", "Um amoxilina, paracetamol e um cinegripe", "ok", "Muitissimo obrigado!", "Estamos juntos !"]
    }
      
    // Metodos para listagem de tabela :
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listaMensagens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celulaDireita = tableView.dequeueReusableCell(withIdentifier: "celulaMensagensDireita", for: indexPath) as! MensagensTableViewCell // linkando a função
        
        let celulaEsquerda = tableView.dequeueReusableCell(withIdentifier: "celulaMensagensEsquerda", for: indexPath) as! MensagensTableViewCell // linkando a função
        
        let celulaImagemDireita = tableView.dequeueReusableCell(withIdentifier: "celulaImagemDireita", for: indexPath) as! MensagensTableViewCell // linkando a função
        
        let celulaImagemEsquerda = tableView.dequeueReusableCell(withIdentifier: "celulaImagemEsquerda", for: indexPath) as! MensagensTableViewCell // linkando a função
         
        let indice = indexPath.row
        let dados = self.listaMensagens[indice]
        let texto = dados ["texto"] as? String
        let idUsuario = dados ["idUsuario"] as? String
        let urlImagem = dados ["urlImagem"] as? String


        
        
        // Condição de envio e recepção de mensagens
        
        if idUsuarioLogado == idUsuario {
            
            if urlImagem != nil {
                celulaImagemDireita.imagemDireita.sd_setImage(with: URL(string: urlImagem!), completed: nil)
                return celulaImagemDireita
            }
            celulaDireita.mensagemDireitaLabel.text = texto
            return celulaDireita
        }else {
            if urlImagem != nil {
                celulaImagemEsquerda.imagemEsquerda.sd_setImage(with: URL(string: urlImagem!), completed: nil)
                return celulaImagemEsquerda
            }
            celulaEsquerda.mensagemEsquerdaLabel.text = texto
            return celulaEsquerda
        }
        
    
    }

    @IBAction func enviarImagem(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let imagemRecuperada = info [UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        let imagens = storage
            .reference()
            .child("imagens")
        
        if let imagemUpload = imagemRecuperada.jpegData(compressionQuality: 0.3) {
            
            let identificadorUnico = UUID().uuidString
            
            let nomeImagem = "\(identificadorUnico).jpg"
            let imagemMensagemRef = imagens.child("mensagens").child(nomeImagem)
            imagemMensagemRef.putData(imagemUpload, metadata: nil) {
                (metaData,erro) in
                
                if erro == nil {
                    print("Sucesso ao realizar upload da img")
                    imagemMensagemRef.downloadURL { [self] url, erro in
                        if let urlImagem = url?.absoluteString {
                            
                            if let idUsuarioDestinatario = self.contato ["id"] as? String {
                                
                                let mensagem: Dictionary<String, Any> = [
                                    "idUsuario" : self.idUsuarioLogado!,
                                    "urlImagem" : urlImagem,
                                    "data" : FieldValue.serverTimestamp()
                                ]
                                
                                // Salvando mensagem remetenete
                                self.salvarMensagem(idRemetente: self.idUsuarioLogado, idDestinatario: idUsuarioDestinatario, mensagem: mensagem)
                                
                                // Salvando mensagem destinatario
                                self.salvarMensagem(idRemetente: idUsuarioDestinatario, idDestinatario: self.idUsuarioLogado, mensagem: mensagem)
                                
                                let conversa:Dictionary<String, Any> = [
                                    "idRemetente" : idUsuarioLogado!,
                                    "idDestinatario" : idUsuarioDestinatario,
                                    "ultimaMensagem" : "imagem..."
                                    ]
                                
                                conversa["nomeUsuario"] = self.nomeContato!
                                conversa["urlFotoUsuario"] = self.urlfotoContato!

                                
                                // Salvando conversa para remetente
                                salvarConversa(idRemetente: idUsuarioLogado, idDestinatario: idUsuarioDestinatario, conversa: conversa)
                                // Salvando conversa para destinatario
                                salvarConversa(idRemetente: idUsuarioDestinatario, idDestinatario: idUsuarioLogado, conversa: conversa)
                            
                                
                            }
                            
                        }
                    }
                    
                }else {
                    print("Falha ao realizar upload da img")
                }
            }
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func enviarMensagem(_ sender: Any) {
            
        if let textoDigitado = mensagemCaixaTexto.text {
            if !textoDigitado.isEmpty {
                if let idUsuarioDestinatario = contato ["id"] as? String {
                    
                    let mensagem: Dictionary<String, Any> = [
                        "idUsuario" : idUsuarioLogado!,
                        "texto" : textoDigitado,
                        "data" : FieldValue.serverTimestamp()
                    ]
                    
                    // Salvando mensagem remetenete
                    salvarMensagem(idRemetente: idUsuarioLogado, idDestinatario: idUsuarioDestinatario, mensagem: mensagem)
                    
                    // Salvando mensagem destinatario
                    salvarMensagem(idRemetente: idUsuarioDestinatario, idDestinatario: idUsuarioLogado, mensagem: mensagem)
                    
                    let conversa:Dictionary<String, Any> = [
                        "idRemetente" : idUsuarioLogado!,
                        "idDestinatario" : idUsuarioDestinatario,
                        "ultimaMensagem" : textoDigitado,
                        "nomeUsuario" : nomeContato!,
                        "urlFotoUsuario" : urlFotoContato!,
                        "tipo" : "texto"
                    ]
                    
                    // Salvando conversa para remetente
                    salvarConversa(idRemetente: idUsuarioLogado, idDestinatario: idUsuarioDestinatario, conversa: conversa)
                    // Salvando conversa para destinatario
                    salvarConversa(idRemetente: idUsuarioDestinatario, idDestinatario: idUsuarioLogado, conversa: conversa)


                    
                }
                
            }
        }
        
    }
    
    func salvarConversa(idRemetente: String, idDestinatario: String, conversa: Dictionary<String, Any> )  {
        db.collection("conversas")
            .document(idRemetente)
            .collection("ultima_conversa")
            .document(idDestinatario)
            .setData(conversa)
    }
    
    func salvarMensagem(idRemetente: String, idDestinatario: String, mensagem: Dictionary<String, Any>) {
        db.collection("mensagens")
            .document(idRemetente)
            .collection(idDestinatario)
            .addDocument(data: mensagem)
        
        // limpa a caixa de texto
        mensagemCaixaTexto.text = ""
        
    }
    
    func recuperarMensagens() {
        if let idDestinatario = contato ["id"] as? String {
            mensagemListener = db.collection("mensagens")
                .document(idUsuarioLogado)
                .collection(idDestinatario)
                .order(by: "data", descending: false)
                .addSnapshotListener { (querySnapshot, erro) in
                    
                    // Limpa lista
                    self.listaMensagens.removeAll()
                    
                    // Recuperar dados
                    if let snapshot = querySnapshot {
                        for document in snapshot.documents {
                            let dados = document.data()
                            self.listaMensagens.append(dados)
                            
                        }
                        self.tableViewMensagens.reloadData()
                    }
                
                }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Desabilitar tabBar
        self.tabBarController?.tabBar.isHidden = true
        
        recuperarMensagens()
    }
    
        // Habilitar tabBar
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
        mensagemListener.remove()

    }
 
}


