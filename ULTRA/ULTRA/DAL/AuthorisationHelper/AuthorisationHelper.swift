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
    
    func fetchDeveloperTokenFromJWT() -> Promise<String?>
    
    func requestUserToken()
    
    func requestAuthorization()
    
}
