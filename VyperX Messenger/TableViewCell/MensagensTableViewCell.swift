//
//  MensagensTableViewCell.swift
//  VyperX Messenger
//
//  Created by Lucas Nascimento on 09/02/2023.
//

import UIKit

class MensagensTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var imagemDireita: UIImageView!
    
    @IBOutlet weak var imagemEsquerda: UIImageView!
    
    @IBOutlet weak var mensagemDireitaLabel: UILabel!
    
    @IBOutlet weak var mensagemEsquerdaLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
