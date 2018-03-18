//
//  FabrikaImpl.swift
//  VKAppNew
//
//  Created by  Artem Mazheykin on 04.11.2017.
//  Copyright © 2017 Morodin. All rights reserved.
//

import UIKit

class FabrikaImpl: Fabrika{
    
    private let storyboard: Storyboard = StoryboardImpl()
    private var navigator: Navigator!
    private var systemParametersService: SystemParametersService!
    private var songService: SongService!
    
    private func initDAL(){
        initSystemParametersService()
        initSongService()
    }
    
    private func initSystemParametersService(){
        let systemParametersService = SystemParametersServiceImpl()
        systemParametersService.repository = SystemParametersRepositoryImpl()
        self.systemParametersService = systemParametersService
    }
    
    private func initSongService(){
        let songService = SongServiceImpl()
        songService.repository = SongRepositoryImpl()
        self.songService = songService
    }

    init(){
        let navigator = NavigatorImpl(fabrika: self)
        self.navigator = navigator
        initDAL()
        navigator.showFirstViewController()
    }
    
    
    func mainScreenController() -> UIViewController{
        
        if let navc = storyboard.getViewController(type: .navigationController) as? UINavigationController{
            if navc.viewControllers.count > 0{
                if let mainScreenController = navc.viewControllers[0] as? MainScreenController{
                    mainScreenController.navigator = navigator
                    mainScreenController.systemParametersService = systemParametersService
                    mainScreenController.songService = songService
                }
            }
            return navc
        }
        return UIViewController()
        
    }
    
    func last10SongController() -> UIViewController{
        return storyboard.getViewController(type: .last10SongController)
    }
    
    func favouriteViewController() -> UIViewController {
        let vc = storyboard.getViewController(type: .favouriteViewController) as! FavouriteViewController
        vc.navigator = navigator
        vc.songService = songService
        
        return vc
    }
}


