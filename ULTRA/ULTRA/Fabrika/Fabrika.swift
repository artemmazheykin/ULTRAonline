//
//  File.swift
//  VKAppNew
//
//  Created by  Artem Mazheykin on 04.11.2017.
//  Copyright © 2017 Morodin. All rights reserved.
//

import UIKit

protocol Fabrika: class{
    
    func mainScreenController() -> UIViewController
    func last10SongController() -> UIViewController
    func favouriteViewController() -> UIViewController
    
}
