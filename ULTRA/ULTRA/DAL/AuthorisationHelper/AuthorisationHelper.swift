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


protocol AuthorisationHelper{
    
    var devTokenKey: String{
        get
    }
    
    var userTokenKey: String{
        get
    }

    func fetchDeveloperToken() -> Promise<String>
    
    func fetchDeveloperTokenFromJWT() -> Promise<String?>
    
    func requestUserToken() -> Promise<String?>
    
    func requestAuthorization()
    
    func data(with request: URLRequest, completion: @escaping (Data?, Error?) -> Swift.Void)
    
    func IsDeniedWasSet() -> Bool
}
