//
//  StreamRate.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 12.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//
//https://nashe1.hostingradio.ru:18000/ultra-64.mp3 64
//https://nashe1.hostingradio.ru:18000/ultra-128.mp3 128
//https://nashe1.hostingradio.ru:18000/ultra-192.mp3 192

import Foundation

enum StreamRate{
    case _64, _128, _196
    
    var description: String{
        switch self {
        case ._64:
            return "64 kb/s"
        case ._128:
            return "128 kb/s"
        case ._196:
            return "196 kb/s"
        }
    }
    
    init?(kbps: String){
        switch kbps {
        case "64":
            self = ._64
        case "128":
            self = ._128
        case "196":
            self = ._196

        default:
            return nil
        }
    }

    var index: Int{
        switch self {
        case ._64:
            return 0
        case ._128:
            return 1
        case ._196:
            return 2
        }
    }
    
    var stringForUserDefaults: String{
        switch self {
        case ._64:
            return "64"
        case ._128:
            return "128"
        case ._196:
            return "196"
        }
    }
        
    var streamUrlString: String{
        switch self {
        case ._64:
            return "https://nashe1.hostingradio.ru:18000/ultra-64.mp3"
        case ._128:
            return "https://nashe1.hostingradio.ru:18000/ultra-128.mp3"
        case ._196:
            return "https://nashe1.hostingradio.ru:18000/ultra-192.mp3"
        }
    }
    
    var streamURL: URL{
        return URL(string: self.streamUrlString)!
    }
    
}
