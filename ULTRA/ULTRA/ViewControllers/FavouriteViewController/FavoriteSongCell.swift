//
//  FavoriteSongCell.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 10.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import UIKit

class FavoriteSongCell: UITableViewCell {

    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        artistImage.layer.cornerRadius = 3
        songNameLabel.adjustsFontSizeToFitWidth = true
        artistImage.backgroundColor = .black
        artistImage.layer.masksToBounds = true
        artistImage.contentMode = .scaleAspectFit
        artistImage.layer.borderWidth = 0.25
        artistImage.layer.borderColor = UIColor(red: 123/255, green: 123/255, blue: 123/255, alpha: 1.0).cgColor
        let templateImage = #imageLiteral(resourceName: "play-button-circled-100").withRenderingMode(.alwaysTemplate)
        playButton.setImage(templateImage, for: .normal)
        playButton.imageView?.tintColor = UIColor.red
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
