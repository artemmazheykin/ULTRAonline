//
//  ArtistModel.swift
//  UltraAggregator
//
//  Created by  Artem Mazheykin on 09.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import Foundation

class ArtistModel{
    
    let artistName: String
    var songs: [SongModel]
    let dateOfCreation: Date
    
    init(artistName: String, songs: [SongModel]){
        self.artistName = artistName
        self.songs = songs
        
        let sortedSongs = songs.sorted { (song1, song2) -> Bool in
            return song1.dateOfCreation < song2.dateOfCreation
        }
        
        let dateOfCreation = sortedSongs[0].dateOfCreation
        self.dateOfCreation = dateOfCreation
        
    }
    
    init?(fromDictionary dictionary: [String:Any]){
        
        if let artistName = dictionary["ArtistName"] as? String{
            self.artistName = artistName
        }else{
            return nil
        }
        
        if let dictionarySongs = dictionary["Songs"] as? [[String:Any]]{
            
            var songs:[SongModel] = []
            for dictionarySong in dictionarySongs{
                if let song = SongModel(songFromDictionary: dictionarySong){
                    songs.append(song)
                }
            }
            self.songs = songs
        }else{
            return nil
        }
        
        if let dateOfCreation = dictionary["DateOfCreation"] as? Date{
            self.dateOfCreation = dateOfCreation
        }else{
            return nil
        }
    }
    
    func setArtistToDictionary() -> [String:Any]{
        
        var dictionary:[String:Any] = [:]
        
        dictionary["ArtistName"] = artistName
        
        var dictionarySongs:[[String:Any]] = []
        
        for song in songs{
            let dictionarySong = song.setSongToDictionary()
            dictionarySongs.append(dictionarySong)
        }
        dictionary["Songs"] = dictionarySongs
        
        dictionary["DateOfCreation"] = dateOfCreation
        
        return dictionary
    }
    
    func insertSong(song: SongModel){
        songs.append(song)
    }
    
    func isContainThatSongInSongs(song: String) -> Bool{
        for songModel in songs{
            if songModel.songName == song{
                return true
            }
        }
        return false
    }
}





