//
//  SongService.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 09.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import UIKit
import PromiseKit

protocol SongService: class {
    
    func getFavoriteArtistsFromUserDefaults() -> [ArtistModel]
    func getFavoriteSongsFromUserDefaults() -> [String:SongModel]
    func setFavoriteArtistsToUserDefaults(artists: [ArtistModel])
//    func isThatSongFaforiteChecking(artist: String, song: String) -> Promise<SongModel>
    func isThatSongFaforiteChecking(artist: String, song: String) -> SongModel
    func addSongToFavorites(songModel: SongModel)
    func deleteSongFromFavorites(songModel: SongModel)
    func addCurrentSongImageToFavorites(songImageModel: SongImageModel)
    func deleteSongImageFromFavorites(songModel: SongModel)
    func resetFavourites()
    func addIDToUserDefaults(id: (songName: String,number: String))
    func deleteIDFromUserDefaults(songName: String)
    func getIDsFromUserDefaults() -> [String:String]

}
