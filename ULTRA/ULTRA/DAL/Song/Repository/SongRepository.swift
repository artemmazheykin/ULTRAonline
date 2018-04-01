//
//  SongRepository.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 09.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import Foundation
import UIKit

protocol SongRepository: class {
    
    func getFavoriteArtistsFromUserDefaults() -> [ArtistModel]
    func setFavoriteArtistsToUserDefaults(artists: [ArtistModel])
    func getFavoriteImagesFromUserDefaults() -> [String:SongImageModel]
    func setFavoriteImagesToUserDefaults(images: [String:SongImageModel])
    func getIDsFromUserDefaults() -> [String:String]
    func setIDsToUserDefaults(ids: [String:String])
    func getURLsFromUserDefaults() -> [String:URL]
    func setURLsToUserDefaults(urls: [String:URL])
    func resetFavourites()
}
