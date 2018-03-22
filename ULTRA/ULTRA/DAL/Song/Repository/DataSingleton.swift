//
//  DataSingleton.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 14.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

@objc protocol DataSingletonDelegate: class {
    
    @objc optional func last10SongsHaveChanged(last10Songs:[SongModel], last10SongsStrings: [String])
    @objc optional func favoriteSongsHaveChanged()
}


class DataSingleton{
    
    var songService: SongService!
    var isDownloadingMediaContentPermited: Bool!
    
    weak var delegateLast10VC: DataSingletonDelegate?
    weak var delegateFavoritesVC: DataSingletonDelegate?
    weak var delegateMainScreenVC: DataSingletonDelegate?
    
    var songs:[String:SongModel]{
        didSet{
            updateLast10Songs()
            delegateFavoritesVC?.favoriteSongsHaveChanged?()
            delegateMainScreenVC?.favoriteSongsHaveChanged?()
        }
    }
    
    var last10SongsStrings: [String] = []
    
    var last10Songs:[SongModel] = []{
        didSet{
            delegateLast10VC?.last10SongsHaveChanged?(last10Songs: last10Songs, last10SongsStrings: last10SongsStrings)
        }
    }
    
    var images: [String:UIImage] = [:]
    var trackIds:[String:String] = [:]

    var networkHelper = NetworkHelperImpl()
    
    open static let shared = DataSingleton()
    
    
    init(){
        let repository: SongRepository = SongRepositoryImpl()
        let songServiceImpl = SongServiceImpl()
        songServiceImpl.repository = repository
        songService = songServiceImpl
        self.songs = songService.getFavoriteSongsFromUserDefaults()
        updateLast10SongsEvery10Seconds()
    }
    
    func updateLast10SongsEvery10Seconds(){
        DispatchQueue.global(qos: .background).async {
            while true{
                _ = self.networkHelper.updateLast10Songs().done{ last10SongsStrings in
                    self.last10SongsStrings = last10SongsStrings
                    var verifiedLast10songs: [SongModel] = []
                    let uncheckedLast10Songs = self.convertStringSongsToModel(last10SongsStrings)
                    for uncheckedSong in uncheckedLast10Songs{
                        if let song = self.songs[uncheckedSong.artistAndSongName]{
                            verifiedLast10songs.append(song)
                        }else{
                            verifiedLast10songs.append(uncheckedSong)
                        }
                    }
                    self.last10Songs = verifiedLast10songs
                }
                sleep(10)
            }
        }
    }
    
    func updateLast10Songs(){
        DispatchQueue.global(qos: .background).async {
            _ = self.networkHelper.updateLast10Songs().done{ last10SongsStrings in
                self.last10SongsStrings = last10SongsStrings
                var verifiedLast10songs: [SongModel] = []
                let uncheckedLast10Songs = self.convertStringSongsToModel(last10SongsStrings)
                for uncheckedSong in uncheckedLast10Songs{
                    if let song = self.songs[uncheckedSong.artistAndSongName]{
                        verifiedLast10songs.append(song)
                    }else{
                        verifiedLast10songs.append(uncheckedSong)
                    }
                }
                self.last10Songs = verifiedLast10songs
            }
        }
    }
    
    func fetchImages(){
        ImageCache.default.maxCachePeriodInSecond = -1
        for song in songs{
            images[song.key] = ImageCache.default.retrieveImageInDiskCache(forKey: song.key)
        }
    }
    
    func storeImages(){
        for image in images{
            ImageCache.default.store(image.value, forKey: image.key)
        }
    }
    
    func addSongAndImageToFavorites(songModel: SongModel){
            songModel.dateOfCreation = Date()
            songs[songModel.artistAndSongName] = songModel
            songService.addSongToFavorites(songModel: songModel)
        _ = networkHelper.getUrlImage(metadata: songModel.artistAndSongName, size: 300).done{url in
            
            if self.isDownloadingMediaContentPermited{
                if let url = url{
                    ImageDownloader.default.downloadImage(with: url, options: [], progressBlock: nil) {
                        (image, error, url, data) in
                        self.images[songModel.artistAndSongName] = image
                        if let image = image{
                            ImageCache.default.store(image, forKey: songModel.artistAndSongName)
                        }
                    }
                }
            }
        }
        
        _ = networkHelper.getTrackId(metadata: songModel.artistAndSongName).done{trackId in
            self.trackIds[songModel.artistAndSongName] = trackId
            var IDs = songService
        }
        
        
    }
    
    func deleteSongAndImageFromFavorites(songModel: SongModel){
        songs[songModel.artistAndSongName] = nil
        songService.deleteSongFromFavorites(songModel: songModel)
        if let _ = images[songModel.artistAndSongName]{
            images[songModel.artistAndSongName] = nil
            ImageCache.default.removeImage(forKey: songModel.artistAndSongName)
        }
    }
    
    
    func convertStringSongsToModel(_ last10SongsStrings: [String]) -> [SongModel]{
        
        var artistAndSongStringsWithoutTime:[String] = []
        var timeOfPlaying: [String] = []
        var uncheckedLast10Songs: [SongModel] = []
        
        for stringSong in last10SongsStrings{
            let strings = stringSong.components(separatedBy: " ")
            if strings.count != 0{
                timeOfPlaying.append(strings.first!)
            }
        }
        
        for (i,string) in last10SongsStrings.enumerated(){
            
            let strings = string.components(separatedBy: timeOfPlaying[i]+" ")
            if strings.count>1{
                artistAndSongStringsWithoutTime.append(strings[1])
            }
        }
        
        for artistAndSong in artistAndSongStringsWithoutTime{
            let artistAndSongSeparated = artistAndSong.components(separatedBy: " - ")
            if artistAndSongSeparated.count == 2{
                uncheckedLast10Songs.append(SongModel(artistName: artistAndSongSeparated[0], songName: artistAndSongSeparated[1]))
            }
        }
        return uncheckedLast10Songs
    }
}
