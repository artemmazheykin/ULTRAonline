//
//  SongImageModel.swift
//  ULTRA
//
//  Created by Artem Mazheykin on 12.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import UIKit

class SongImageModel{
    
    let image: UIImage?
    let songName: String
    let artistName: String
    var artistAndSongName: String{
        return artistName + " - " + songName
    }
    
    init(image: UIImage, songName: String, artistName: String){
        
        self.image = image
        self.songName = songName
        self.artistName = artistName
        
    }
    
    init?(imageFromDictionary: [String:Any]){
        
        if let imagePNGData = imageFromDictionary["ImagePNGData"] as? Data{
            if let image = UIImage(data: imagePNGData,scale:1.0){
                self.image = image
            }else{
                return nil
            }
        }else{
            image = nil
        }
        if let artistName = imageFromDictionary["ArtistName"] as? String{
            self.artistName = artistName
        }else{
            return nil
        }
        if let songName = imageFromDictionary["SongName"] as? String{
            self.songName = songName
        }else{
            return nil
        }
        
    }
    
    func setImageToDictionary() -> [String:Any]{
        
        var dictionary:[String:Any] = [:]

        if let trueImage = image{
            if let imagePNGData = UIImagePNGRepresentation(trueImage){
                dictionary["ImagePNGData"] = imagePNGData
            }
        }
      
        dictionary["SongName"] = songName
        dictionary["ArtistName"] = artistName
        
        
        return dictionary
    }

}
