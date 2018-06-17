//
//  AuthorisationHelper.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 11.06.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import Foundation
import StoreKit
import PromiseKit


class AuthorisationHelperImpl: AuthorisationHelper{
    
    let devTokenKey = "DeveloperToken"
    var developerToken = ""
    var userToken = ""
    let serviceController = SKCloudServiceController()
    let getDevTokenUrlString = "https://us-central1-ultraonline-f867c.cloudfunctions.net/getAppleToken"
    
    func fetchDeveloperTokenFromJWT() -> Promise<String?>{
        return Promise<String?>{pup in
            if let devToken = UserDefaults.standard.value(forKey: devTokenKey) as? String{
                return pup.fulfill(devToken)
            }
            let request = URLRequest(url: URL(string: getDevTokenUrlString)!)
            URLSession.shared.dataTask(with: request) { (dataOpt, _, error) in
                guard error == nil, let data = dataOpt
                    else{
                        print("Error with getting devToken from firebase cloud functions")
                        pup.fulfill(nil)
                        return
                }
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                guard let parsedResult = json as? [String: Any],
                    let token = parsedResult["token"] as? String else {
                        print("error with parsing json object")
                        pup.fulfill(nil)
                        return
                }
                print("token = \(token)")
                pup.fulfill(token)
                }.resume()
        }
    }

    func requestUserToken(){
        serviceController.requestUserToken(forDeveloperToken: developerToken) { (tokenOpt, error) in
            guard error == nil else{
                print("ERRORRRRR!!!! \(error.debugDescription)")
                return
            }
            if let token = tokenOpt{
                self.userToken = token
                UserDefaults.standard.set(token, forKey: "UserToken")
            }
            else{
                print("ERRORRRRR!!!! \(error.debugDescription)")
                return
            }
        }
    }
    
    func requestAuthorization(){
        
        SKCloudServiceController.requestAuthorization { (status:SKCloudServiceAuthorizationStatus) in
            
            switch SKCloudServiceController.authorizationStatus() {
                
            case .authorized:
                
                print("The user's already authorized - we don't need to do anything more here, so we'll exit early.")
                
                if UserDefaults.standard.value(forKey: "UserToken") == nil{
                    self.serviceController.requestUserToken(forDeveloperToken: self.developerToken) { (tokenOpt, error) in
                        guard error == nil else{
                            print("ERRORRRRR!!!! \(error.debugDescription)")
                            
                            return
                        }
                        if let token = tokenOpt{
                            self.userToken = token
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
                
                self.serviceController.requestUserToken(forDeveloperToken: self.developerToken) { (tokenOpt, error) in
                    guard error == nil else{
                        print("ERRORRRRR!!!! \(error.debugDescription)")
                        return
                    }
                    if let token = tokenOpt{
                        self.userToken = token
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
