//
//  Navigator.swift
//  VKAppNew
//
//  Created by  Artem Mazheykin on 04.11.2017.
//  Copyright © 2017 Morodin. All rights reserved.
//

import UIKit

protocol Navigator: class {
    
    func last10SongController(didTappedButtonFrom viewController: UIViewController)
    func favouriteViewController(didTappedButtonFrom viewController: UIViewController)


}
