//
//  SongService.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 09.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import Foundation
import PromiseKit


class SongServiceImpl: SongService {
    
    var repository: SongRepository!
    var networkHelper: NetworkHelper!
    
    func addSongToFavorites(songModel: SongModel){
        var artists = repository.getFavoriteArtistsFromUserDefaults()
        var newArtist: ArtistModel!
        var isExistingArtist = false
        var isExistingArtistAndSong = false
        
        for (i,artist) in artists.enumerated(){
            
            for (j,song) in artist.songs.enumerated(){
                
                if song.artistAndSongName == songModel.artistAndSongName{
                    artists[i].songs[j] = songModel
                    isExistingArtist = true
                    isExistingArtistAndSong = true
                }
            }
        }
        
        if !isExistingArtistAndSong{
            for artist in artists{
                
                if artist.artistName == songModel.artistName{
                    artist.songs.append(songModel)
                    isExistingArtist = true
                }
            }
        }
        
        if !isExistingArtist{
            
            newArtist = ArtistModel(artistName: songModel.artistName, songs: [songModel])
            artists.append(newArtist)
        }
        setFavoriteArtistsToUserDefaults(artists: artists)
    }
    
    
    
    func deleteSongFromFavorites(songModel: SongModel) {
        
        var artists = repository.getFavoriteArtistsFromUserDefaults()
        
        var indexArtist: Int!
        var artistWithoutSongs = false
        
        for (i,artist) in artists.enumerated(){
            if artist.artistName == songModel.artistName{
                var indexSong:Int!
                for (i,song) in artist.songs.enumerated(){
                    if song.songName == songModel.songName{
                        indexSong = i
                    }
                }
                artist.songs.remove(at: indexSong)
                indexArtist = i
            }
        }
        if indexArtist != nil{
            if artists[indexArtist].songs.count == 0{
                artistWithoutSongs = true
            }
            if artistWithoutSongs{
                artists.remove(at: indexArtist)
            }
        }
        
        setFavoriteArtistsToUserDefaults(artists: artists)
    }
    
    
    func deleteSongImageFromFavorites(songModel: SongModel){
        
        var images = repository.getFavoriteImagesFromUserDefaults()
        images[songModel.artistName + " - " + songModel.songName] = nil
        repository.setFavoriteImagesToUserDefaults(images: images)

    }
 
    func addCurrentSongImageToFavorites(songImageModel: SongImageModel){
        var images = repository.getFavoriteImagesFromUserDefaults()
        images[songImageModel.artistAndSongName] = songImageModel
        repository.setFavoriteImagesToUserDefaults(images: images)
    }

    
    
    func isThatSongFaforiteChecking(artist: String, song: String) -> SongModel{
        let artists = repository.getFavoriteArtistsFromUserDefaults()
        for artistModel in artists{
            for songModel in artistModel.songs{
                if songModel.artistName == artist && songModel.songName == song{
                    return songModel
                }
            }
        }
        let songModel = SongModel(artistName: artist, songName: song)
        return songModel

    }

    func getFavoriteArtistsFromUserDefaults() -> [ArtistModel]{
        
        return repository.getFavoriteArtistsFromUserDefaults()
        
    }
    
    func getFavoriteSongsFromUserDefaults() -> [String:SongModel]{
        var songsDictionary:[String:SongModel] = [:]
        let artists = repository.getFavoriteArtistsFromUserDefaults()
        for artist in artists{
            for song in artist.songs{
                songsDictionary[song.artistAndSongName] = song
            }
        }
        return songsDictionary
    }

    
    func setFavoriteArtistsToUserDefaults(artists: [ArtistModel]){
        
        repository.setFavoriteArtistsToUserDefaults(artists: artists)
    }
            
    func resetFavourites(){
        repository.resetFavourites()
    }
    
    func addIDToUserDefaults(id: (songName: String,number: String)){
        
        var ids = repository.getIDsFromUserDefaults()
        ids[id.songName] = id.number
        repository.setIDsToUserDefaults(ids: ids)
    }
    
    func addURLToUserDefaults(songUrl: (songName: String,url: URL)){
        
        var urls = repository.getURLsFromUserDefaults()
        urls[songUrl.songName] = songUrl.url
        repository.setURLsToUserDefaults(urls: urls)
    }

    func deleteIDFromUserDefaults(songName: String){
        
        var ids = repository.getIDsFromUserDefaults()
        ids[songName] = nil
        repository.setIDsToUserDefaults(ids: ids)
    }
    
    func deleteURLFromUserDefaults(songName: String){
        
        var urls = repository.getURLsFromUserDefaults()
        urls[songName] = nil
        repository.setURLsToUserDefaults(urls: urls)
    }

    
    func getIDsFromUserDefaults() -> [String : String] {
        return repository.getIDsFromUserDefaults()
    }
    
    func getURLsFromUserDefaults() -> [String:URL]{
        return repository.getURLsFromUserDefaults()
    }

}
