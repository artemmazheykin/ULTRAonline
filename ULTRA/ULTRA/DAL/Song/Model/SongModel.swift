//
//  SongModel.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 09.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import UIKit

@objc class SongModel: NSObject{
    
    let artistName: String
    let songName: String
    var dateOfCreation:Date
    var isFavorite = false
    var artistAndSongName: String{
        return artistName + " - " + songName
    }

    
    init(artistName: String, songName: String){
        self.artistName = artistName
        self.songName = songName
        self.dateOfCreation = Date()
    }
    
    func changeFavor(){
        isFavorite = !isFavorite
    }
    
    init?(songFromDictionary: [String:Any]){
        
        if let artistName = songFromDictionary["ArtistName"] as? String{
            self.artistName = artistName
        }else{
            return nil
        }
        if let songName = songFromDictionary["SongName"] as? String{
            self.songName = songName
        }else{
            return nil
        }
        if let isFavorite = songFromDictionary["IsFavorite"] as? Bool{
            self.isFavorite = isFavorite
        }else{
            return nil
        }
        if let dateOfCreation = songFromDictionary["DateOfCreation"] as? Date{
            self.dateOfCreation = dateOfCreation
        }else{
            return nil
        }

    }
    
    func setSongToDictionary() -> [String:Any]{
        
        var dictionary:[String:Any] = [:]
        
        dictionary["ArtistName"] = artistName
        dictionary["SongName"] = songName
        dictionary["IsFavorite"] = isFavorite
        dictionary["DateOfCreation"] = dateOfCreation
        
        return dictionary
    }
}



