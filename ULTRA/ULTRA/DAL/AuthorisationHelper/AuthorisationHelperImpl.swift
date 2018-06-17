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

enum ResponseError: Error {
    case invalidResponse(URLResponse?)
    case unacceptableStatusCode(Int)
}

class AuthorisationHelperImpl: AuthorisationHelper{
    
    let devTokenKey = "DeveloperToken"
    var userTokenKey = "UserToken"
    var userToken = ""
    let serviceController = SKCloudServiceController()
    let getDevTokenUrlString = "https://us-central1-ultraonline-f867c.cloudfunctions.net/getAppleToken"
    
    func fetchDeveloperToken() -> Promise<String>{
        
        return Promise<String>{pup in
            if let token = UserDefaults.standard.string(forKey: devTokenKey){
                pup.fulfill(token)
            }else{
                _ = fetchDeveloperTokenFromJWT().done{ result in
                    if let token = result{
                        UserDefaults.standard.set(token, forKey: self.devTokenKey)
                        print("Developer token is GOOOD!!")
                        pup.fulfill(token)
                        if let navc = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController, let vc = navc.viewControllers.first as? MainScreenController{
                            vc.setArtwork()
                        }
                    }
                    else{
                        pup.fulfill("")
                    }
                }
            }
        }

    }
    
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
    
    func requestUserToken() -> Promise<String?>{
        return Promise<String?>{ pup in
            _ = fetchDeveloperToken().done{ token in
                
                self.serviceController.requestUserToken(forDeveloperToken: token) { (tokenOpt, error) in
                    guard error == nil else{
                        print("ERRORRRRR!!!! \(error.debugDescription)")
                        pup.fulfill(nil)
                        return
                    }
                    if let token = tokenOpt{
                        self.userToken = token
                        UserDefaults.standard.set(token, forKey: self.userTokenKey)
                        pup.fulfill(token)
                    }
                    else{
                        print("ERRORRRRR!!!! \(error.debugDescription)")
                        pup.fulfill(nil)
                    }
                }
            }
        }
    }
    
    func IsDeniedWasSet() -> Bool{
        switch SKCloudServiceController.authorizationStatus() {
            
        case .authorized:
            
            return false
            
        case .denied:
            
            return true
            
        case .notDetermined:
            
            return false
            
        case .restricted:
            
            return false
            
        }
    }
    
    func requestAuthorization(){
        
        SKCloudServiceController.requestAuthorization { (status:SKCloudServiceAuthorizationStatus) in
            
            switch SKCloudServiceController.authorizationStatus() {
                
            case .authorized:
                
                print("The user's already authorized - we don't need to do anything more here, so we'll exit early.")
                
                if UserDefaults.standard.value(forKey: self.userTokenKey) == nil{
                    _ = self.requestUserToken().done{ _ in
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
                
                _ = self.requestUserToken().done{_ in
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

extension AuthorisationHelperImpl {
    func data(with request: URLRequest, completion: @escaping (Data?, Error?) -> Swift.Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error -> Void in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, ResponseError.invalidResponse(response))
                return
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                switch httpResponse.statusCode{
                case 401:
                    UserDefaults.standard.set(nil, forKey: self.devTokenKey)
                    _ = self.fetchDeveloperToken()
                case 403:
                    _ = self.requestUserToken().done{ _ in
                    }
                default: break
                }
                completion(nil, ResponseError.unacceptableStatusCode(httpResponse.statusCode))
                return
            }
            
            
            
            completion(data, nil)
        }
        task.resume()
    }
}

