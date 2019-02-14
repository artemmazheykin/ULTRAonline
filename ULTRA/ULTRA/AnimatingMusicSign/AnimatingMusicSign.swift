//
//  AnimatingMusicSign.swift
//  ULTRA
//
//  Created by Artem Mazheykin on 14/02/2019.
//  Copyright © 2019 Morodin. All rights reserved.
//

import UIKit

class AnimatingMusicSign: UIView {

    @IBOutlet weak var firstBarHightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var secondBarHightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var thirdBarHightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var fourthBarHightConstraint: NSLayoutConstraint!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        instanceFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        instanceFromNib()
    }
    
    func instanceFromNib(){
        
        Bundle.main.loadNibNamed("AnimatingMusicSign", owner: self, options: nil)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
