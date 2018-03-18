//
//  NavigatorImpl.swift
//  VKAppNew
//
//  Created by  Artem Mazheykin on 04.11.2017.
//  Copyright © 2017 Morodin. All rights reserved.
//

import UIKit

class NavigatorImpl: Navigator{
    
    let router: Router = RouterImpl()
    private weak var fabrika: Fabrika!
    
    init(fabrika: Fabrika){
        self.fabrika = fabrika
    }
    
    func showFirstViewController() {
        let vc = fabrika.mainScreenController()
        _ = router.presentViewController(nextViewController: vc)
    }
    
    
    func last10SongController(didTappedButtonFrom viewController: UIViewController){
        
//        if let vc = viewController as? MainScreenController{
//            let last10vcon = fabrika.last10SongController() as! Last10SongController
//            last10vcon.last10Songs = vc.last10Songs
//            
//            _ = router.pushViewController(nextViewController: last10vcon)
//
//        }
        
        

    }

    func favouriteViewController(didTappedButtonFrom viewController: UIViewController) {
        let vc = fabrika.favouriteViewController()
        _ = router.pushViewController(nextViewController: vc)
    }
    
    
    
    
}
