//
//  RouterViewControllerType.swift
//  VKAppNew
//
//  Created by  Artem Mazheykin on 04.11.2017.
//  Copyright © 2017 Morodin. All rights reserved.
//

import Foundation

enum StoryboardViewControllerType:Int {
    case navigationController, mainScreenController, last10SongController, favouriteViewController
    
    var identifier: String {
        
        switch self {
            
        case .navigationController:
            return "NavigationController"
            
        case .mainScreenController:
            return "MainScreenController"
            
        case .last10SongController:
            return "Last10SongController"
            
        case .favouriteViewController:
            return "FavouriteViewController"
            
        }
    }
}
