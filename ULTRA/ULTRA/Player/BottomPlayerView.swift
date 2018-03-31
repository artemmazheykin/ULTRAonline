//
//  BottomPlayerView.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 29.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import UIKit

class BottomPlayerView: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var songNameLabel: UILabel!
    
    @IBOutlet weak var previousSongButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextSongButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        songImageView.layer.cornerRadius = 3
        songImageView.layer.masksToBounds = true
        songImageView.layer.borderWidth = 0.25
        songImageView.layer.borderColor = UIColor(red: 123/255, green: 123/255, blue: 123/255, alpha: 1.0).cgColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        instanceFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        instanceFromNib()
    }
    
    func instanceFromNib(){
        
        Bundle.main.loadNibNamed("BottomPlayer", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
    }
    
}
