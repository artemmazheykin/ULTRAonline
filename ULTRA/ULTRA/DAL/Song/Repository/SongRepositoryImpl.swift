//
//  SongRepository.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 09.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import Foundation

class SongRepositoryImpl: SongRepository {
    
    let favorKey = "FavoriteSongsKey"
    let favorImageKey = "FavoriteImageKey"
    let songsIDKey = "SongsIDKey"
    let songsURLKey = "SongsURLKey"

    func getFavoriteArtistsFromUserDefaults() -> [ArtistModel]{
        
        var artists:[ArtistModel] = []

        if let dictionaryArtists = UserDefaults.standard.value(forKey: favorKey) as? [[String:Any]]{
            for dictionaryArtist in dictionaryArtists{
                if let artist = ArtistModel(fromDictionary: dictionaryArtist){
                    artists.append(artist)
                }
            }
        }
        return artists
    }
    
    func setFavoriteArtistsToUserDefaults(artists: [ArtistModel]){

        var dictionary:[[String:Any]] = []
        
        for artist in artists{
            let dictionaryArtist = artist.setArtistToDictionary()
            dictionary.append(dictionaryArtist)
        }
        
        UserDefaults.standard.set(dictionary, forKey: favorKey)
        
    }
    
    func getFavoriteImagesFromUserDefaults() -> [String:SongImageModel]{
        
        var images:[String:SongImageModel] = [:]
        
        if let dictionaryImages = UserDefaults.standard.value(forKey: favorImageKey) as? [String:[String:Any]]{
            for dictionaryImage in dictionaryImages{
                
                images[dictionaryImage.key] = SongImageModel(imageFromDictionary: dictionaryImage.value)
                
            }
        }
        return images

    }
    func setFavoriteImagesToUserDefaults(images: [String:SongImageModel]){
        
        var dictionary:[String:Any] = [:]
        
        for image in images{
            
            dictionary[image.key] = image.value.setImageToDictionary()
        
        }
        
        UserDefaults.standard.set(dictionary, forKey: favorImageKey)
        
    }


    func resetFavourites() {
        UserDefaults.standard.set([], forKey: favorKey)
        UserDefaults.standard.set([], forKey: favorImageKey)
    }
    
    func getIDsFromUserDefaults() -> [String:String]{
        let ids: [String:String] = [:]
        
        if let idsFromUserDefaults = UserDefaults.standard.value(forKey: songsIDKey) as? [String:String]{
            return idsFromUserDefaults
        }
        return ids
    }

    func getURLsFromUserDefaults() -> [String:URL]{
        var urls: [String:URL] = [:]
        
        guard let urlStringsFromUserDefaults = UserDefaults.standard.value(forKey: songsURLKey) as? [String:String] else{
            return urls
        }
        for item in urlStringsFromUserDefaults{
            urls[item.key] = URL(string: item.value)
        }
        
        return urls
    }

    func setIDsToUserDefaults(ids: [String:String]) {
        UserDefaults.standard.set(ids, forKey: songsIDKey)
    }
    
    func setURLsToUserDefaults(urls: [String:URL]) {
        
        var urlStrings:[String:String] = [:]
        for item in urls{
            urlStrings[item.key] = item.value.absoluteString
        }
        UserDefaults.standard.set(urlStrings, forKey: songsURLKey)
    }


}
