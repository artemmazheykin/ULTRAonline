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
    func resetFavourites()
}
