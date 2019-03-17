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
    
    class func instanceFromNib() -> UIView{
        return UINib(nibName: "AnimatingMusicSign", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
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

extension Bundle {
    
    static func loadView<T>(fromNib name: String, withType type: T.Type) -> T {
        if let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
            return view
        }
        
        fatalError("Could not load view with type " + String(describing: type))
    }
}
