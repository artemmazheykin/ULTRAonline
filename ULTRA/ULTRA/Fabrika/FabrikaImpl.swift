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
    private var authorisationHelper: AuthorisationHelper!
    private var networkHelper: NetworkHelper!
    
    private func initDAL(){
        initSystemParametersService()
        initSongService()
    }
    
    private func initAuthHelper(){
        authorisationHelper = AuthorisationHelperImpl()
        DataSingleton.shared.authorisationHelper = authorisationHelper
    }
    
    func initNetworkHelper(){
        let netHelper = NetworkHelperImpl()
        netHelper.authorisationHelper = authorisationHelper
        networkHelper = netHelper
        DataSingleton.shared.networkHelper = networkHelper
        MagicPlayer.shared.networkHelper = networkHelper
    }
    
    private func initSystemParametersService(){
        let systemParametersService = SystemParametersServiceImpl()
        systemParametersService.repository = SystemParametersRepositoryImpl()
        self.systemParametersService = systemParametersService
    }
    
    private func initSongService(){
        let songService = SongServiceImpl()
        songService.repository = SongRepositoryImpl()
        songService.networkHelper = networkHelper
        self.songService = songService
    }

    init(){
        let navigator = NavigatorImpl(fabrika: self)
        self.navigator = navigator
        initAuthHelper()
        initNetworkHelper()
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
                    mainScreenController.authorisationHelper = authorisationHelper
                    mainScreenController.networkHelper = networkHelper
                }
            }
            return navc
        }
        return UIViewController()
        
    }
        
    func favouriteViewController() -> UIViewController {
        let vc = storyboard.getViewController(type: .favouriteViewController) as! FavouriteViewController
        vc.navigator = navigator
        vc.songService = songService
        vc.authorisationHelper = authorisationHelper
        vc.networkHelper = networkHelper
        return vc
    }
}


