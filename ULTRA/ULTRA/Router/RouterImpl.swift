//
//  RouterImpl.swift
//  VKAppNew
//
//  Created by  Artem Mazheykin on 04.11.2017.
//  Copyright © 2017 Morodin. All rights reserved.
//

import UIKit

class RouterImpl: Router{
    
    
    fileprivate func initRootViewController(with rootViewController: UIViewController) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
        appDelegate.window?.rootViewController = rootViewController
        appDelegate.window?.makeKeyAndVisible()
    }
        
    fileprivate var currentViewController: UIViewController? {
        return UIApplication.topViewController
    }
    
    
    func presentViewController(nextViewController: UIViewController) -> UIViewController  {
                
        if currentViewController != nil {
            currentViewController?.present(nextViewController, animated: true, completion: nil)
        } else {
            initRootViewController(with: nextViewController)
        }
        return UIViewController()
    }

    func pushViewController(nextViewController: UIViewController) -> UIViewController {
        currentViewController?.navigationController?.pushViewController(nextViewController, animated: true)
        return nextViewController
    }
    
    func popViewController(nextViewController: UIViewController) -> UIViewController {
        
        currentViewController?.navigationController?.pushViewController(nextViewController, animated: true)
//        currentViewController?.pop
        return nextViewController
    }


}

extension UIApplication {
    
    private class func _topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return _topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return _topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return _topViewController(base: presented)
        }
        return base
    }
    
    class var topViewController: UIViewController? {
        return _topViewController()
        
    }
}

