//
//  AppDelegate.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 14.02.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//


//Name:
//RadioUltraForFansKey
//Key ID:
//L354WH5U33
//Services
//MusicKit


// Storefront ID fetched was: 143469-16,29

import UIKit
import AVFoundation
import MediaPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var fabric: Fabrika!
    var window: UIWindow?
    let audioSession = AVAudioSession.sharedInstance()
    var data: DataSingleton!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        fetchDeveloperToken()
        appleMusicRequestPermission()
        fabric = FabrikaImpl()
        data = DataSingleton.shared
        
        data.fetchImages()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        
//        do {
//            try audioSession.setCategory(AVAudioSessionCategoryPlayback)//, with: .mixWithOthers)
//            try audioSession.setActive(true)
//        }
//        catch {
//            print("Setting category to AVAudioSessionCategoryPlayback failed. \(error)")
//        }
//
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication){
    
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//        let vc = window?.rootViewController as! UINavigationController
//        if vc.viewControllers.count > 1, let fvc = vc.viewControllers[1] as? FavouriteViewController{
//            if fvc.favoriteSongs.count != DataSingleton.shared.songs.count{
//                fvc.updateFavoriteSongs()
//                fvc.favoritesTable.reloadData()
//            }
//        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        
        switch MagicPlayer.shared.systemPlayer.playbackState{
        case .playing, .paused:
            MagicPlayer.shared.isRadioActive = false
        default:
            MagicPlayer.shared.isRadioActive = true
        }
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UIApplication.shared.endReceivingRemoteControlEvents()

    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        super.remoteControlReceived(with: event)
        
        guard let event = event, event.type == UIEventType.remoteControl else { return }
        
        switch event.subtype {
        case .remoteControlPlay:
            MagicPlayer.shared.play()
        case .remoteControlPause:
            MagicPlayer.shared.pause()
//        case .remoteControlTogglePlayPause:
//            FRadioPlayer.shared.togglePlaying()
        default:
            break
        }
    }
    
    // Request permission from the user to access the Apple Music library
    func appleMusicRequestPermission() {

        SKCloudServiceController.requestAuthorization { (status:SKCloudServiceAuthorizationStatus) in

            switch SKCloudServiceController.authorizationStatus() {
                
            case .authorized:
                
                print("The user's already authorized - we don't need to do anything more here, so we'll exit early.")
                
                if UserDefaults.standard.value(forKey: "UserToken") == nil{
                    let serviceController = SKCloudServiceController()
                    serviceController.requestUserToken(forDeveloperToken: DataSingleton.shared.developerToken) { (tokenOpt, error) in
                        guard error == nil else{
                            print("ERRORRRRR!!!! \(error.debugDescription)")
                            
                            return
                        }
                        if let token = tokenOpt{
                            DataSingleton.shared.userToken = token
                            UserDefaults.standard.set(token, forKey: "UserToken")
                        }
                    }
                }
                
                return
                
            case .denied:
                
                print("The user has selected 'Don't Allow' in the past - so we're going to show them a different dialog to push them through to their Settings page and change their mind, and exit the function early.")
                
                // Show an alert to guide users into the Settings
                
                return
                
            case .notDetermined:
                
                print("The user hasn't decided yet - so we'll break out of the switch and ask them.")
                break
                
            case .restricted:
                
                print("User may be restricted; for example, if the device is in Education mode, it limits external Apple Music usage. This is similar behaviour to Denied.")
                return
                
            }

            switch status {

            case .authorized:

                let serviceController = SKCloudServiceController()
                serviceController.requestUserToken(forDeveloperToken: DataSingleton.shared.developerToken) { (tokenOpt, error) in
                    guard error == nil else{
                        print("ERRORRRRR!!!! \(error.debugDescription)")
                        return
                    }
                    if let token = tokenOpt{
                        DataSingleton.shared.userToken = token
                        UserDefaults.standard.set(token, forKey: "UserToken")
                    }
                }

                print("All good - the user tapped 'OK', so you're clear to move forward and start playing.")

            case .denied:

                print("The user tapped 'Don't allow'. Read on about that below...")

            case .notDetermined:

                print("The user hasn't decided or it's not clear whether they've confirmed or denied.")

            case .restricted:

                print("User may be restricted; for example, if the device is in Education mode, it limits external Apple Music usage. This is similar behaviour to Denied.")

            }

        }

    }
    
}

