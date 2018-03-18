//
//  Router.swift
//  VKAppNew
//
//  Created by  Artem Mazheykin on 04.11.2017.
//  Copyright © 2017 Morodin. All rights reserved.
//

import UIKit

protocol Router: class {
    func presentViewController(nextViewController: UIViewController) -> UIViewController
    func pushViewController(nextViewController: UIViewController) -> UIViewController
}
