//
//  NetworkHelper.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 11.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import UIKit
import PromiseKit

protocol NetworkHelper: class{
    
    
    func downloadImage(metadata: String, size: Int) -> Promise<UIImage>
    func getUrlImage(metadata: String, size: Int) -> Promise<URL?>
    func getUrlSong(metadata: String) -> Promise<URL?>
    func getUrlArtist(metadata: String) -> Promise<URL?>
}
