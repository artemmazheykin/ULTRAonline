//
//  NetworkHelper.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 11.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//


// "trackId": 723342422

//----TOKEN----
//eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IkwzNTRXSDVVMzMifQ.eyJpc3MiOiI3NzMyNE5URzNEIiwiaWF0IjoxNTIzNzEwMjI4LCJleHAiOjE1MjM3NTM0Mjh9.uj9KH_Klg5fXPhABvITi7RD90ejOz-6NsCphUbaySL4m0Ql390E0R86dD2sUH5-7VWFjSPutFPrd82hZE_KghA

import UIKit
import PromiseKit

class NetworkHelperImpl: NetworkHelper{
    
    // URLs
    var authorisationHelper: AuthorisationHelper!

    var last10SongsUrl = "https://fmgid.com/stations/ultra/current.json"
    
    let currentRegionCode = Locale.current.regionCode?.lowercased()
    

    func fetchUserToken() -> String{
        if let userToken = UserDefaults.standard.string(forKey: authorisationHelper.userTokenKey){
            return userToken
        }
        return ""
    }

    func getUrlImage(songName: String, metadata: String, size: Int) -> Promise<URL?> {
        return Promise<URL?>{pup in
            
            guard !metadata.isEmpty, metadata !=  " ", let request = getSearchURLSongWithApMusAPI(with: metadata) else {
                pup.fulfill(nil)
                return
            }
            
            authorisationHelper.data(with: request, completion: { (data, error) in
                guard error == nil, let data = data else{
                    print("ERROR: \(error.debugDescription)")
                    pup.fulfill(nil)
                    return
                }
                var artworkUrlString = ""
                
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                guard let parsedResult = json as? [String: Any],
                    let results = parsedResult[Keys.results] as? [String: Any],
                    let songs = results[Keys.songs] as? [String: Any],
                    let dataArray = songs[Keys.data] as? Array<[String: Any]> else {
                        print("error with parsing json object")
                        pup.fulfill(nil)
                        return
                }
                guard let attributes = dataArray.first?[Keys.attributes] as? [String: Any],
                    let artwork = attributes[Keys.artworkForApMusicAPI] as? [String: Any],
                    let artworkUrlStringFirst = artwork[Keys.url] as? String else{
                        print("error with parsing json object")
                        pup.fulfill(nil)
                        return
                }
                artworkUrlString = artworkUrlStringFirst
                
                if size > 0 {
                    artworkUrlString = artworkUrlString.replacingOccurrences(of: "{w}x{h}", with: "\(size)x\(size)")
                }
                
                let artworkURL = URL(string: artworkUrlString)
                pup.fulfill(artworkURL)
            })
        }
    }
    
    
    func getUrlSong(metadata: String) -> Promise<(metadata: String,url: URL?)?> {
        return Promise<(metadata: String,url: URL?)?>{pup in
            
            guard !metadata.isEmpty, metadata !=  " - ", let request = getSearchURLSongWithStorefront(with: metadata) else {
                pup.fulfill(nil)
                return
            }
            
            authorisationHelper.data(with: request, completion: { (data, error) in
                guard error == nil, let data = data else{
                    print("ERROR: \(error.debugDescription)")
                    pup.fulfill(nil)
                    return
                }

                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                guard let parsedResult = json as? [String: Any],
                    let results = parsedResult[Keys.results] as? Array<[String: Any]>,
                    let result = results.first,
                    let collectionView = result[Keys.collectionViewUrl] as? String else {
                        pup.fulfill(nil)
                        return
                }
                
                let collectionViewUrl = URL(string: collectionView)
                pup.fulfill((metadata,collectionViewUrl))
                
            })
        }
    }
    
    func getSongDuration(id: String) -> Promise<Double>{
        return Promise<Double>{pup in
            
            if let request = getURLSong(with: id){
                
                authorisationHelper.data(with: request, completion: { (data, error) in
                    guard error == nil, let data = data else{
                        print("ERROR: \(error.debugDescription)")
                        pup.fulfill(0)
                        return
                    }
                    let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    
                    guard let parsedResult = json as? [String: Any],
                        let dataResults = parsedResult["data"] as? [[String: Any]],
                        let attributes = dataResults.first!["attributes"] as? [String: Any],
                        let duration = attributes["durationInMillis"] as? Double else{
                            pup.fulfill(0)
                            return
                    }
                    pup.fulfill(duration)
                })
            }
            else{
                pup.fulfill(0)
            }
        }
    }

    
    func getUrlArtist(metadata: String) -> Promise<URL?> {
        return Promise<URL?>{pup in
            
            guard !metadata.isEmpty, metadata !=  " - ", let request = getSearchURLSongWithStorefront(with: metadata) else {
                pup.fulfill(nil)
                return
            }
            authorisationHelper.data(with: request, completion: { (data, error) in
                guard error == nil, let data = data else{
                    print("ERROR: \(error.debugDescription)")
                    pup.fulfill(nil)
                    return
                }

                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                guard let parsedResult = json as? [String: Any],
                    let results = parsedResult[Keys.results] as? Array<[String: Any]>,
                    let result = results.first,
                    let artistView = result[Keys.artistViewUrl] as? String else {
                        pup.fulfill(nil)
                        return
                }
                //   print("result = \(result)")
                let artistViewUrl = URL(string: artistView)
                pup.fulfill(artistViewUrl)

            })
        }
    }
    
    func getTrackId (metadata: String) -> Promise<String?> {
        return Promise<String?>{pup in
            
            guard !metadata.isEmpty, metadata !=  " - ", let request = getSearchURLSongWithStorefront(with: metadata) else {
                pup.fulfill(nil)
                return
            }

            authorisationHelper.data(with: request, completion: { (data, error) in
                guard error == nil, let data = data else{
                    print("ERROR: \(error.debugDescription)")
                    pup.fulfill(nil)
                    return
                }

                
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                guard let parsedResult = json as? [String: Any],
                    let results = parsedResult[Keys.results] as? Array<[String: Any]>,
                    let result = results.first,
                    let isStreamable = result[Keys.isStreamable] as? Int,
                    isStreamable == 1,
                    let trackId = result[Keys.trackId] as? Double else {
                        pup.fulfill(nil)
                        return
                }
                //                print("result = \(result)")
                let idRaw = String(trackId)
                let id = idRaw.getSongId()
                
                pup.fulfill(id)

            })
        }
    }
    
    
    
//    func getTrackIds(songNames: [String]) -> Promise<[String:String]>{
//        return Promise<[String:String]>{pup in
//
//
//            var result:[String:String] = [:]
//            for songName in songNames{
//
//                _ = getTrackId(metadata: songName).done{ trackId in
//                    result[songName] = trackId
//                }
//
//
//            }
//        }
//    }


    private func getSearchURLSongWithStorefront(with term: String) -> URLRequest? {
        
        
        
        var components = URLComponents()
        components.scheme = Domain.scheme
        components.host = Domain.host
        components.path = Domain.path
        components.queryItems = [URLQueryItem]()
        components.queryItems?.append(URLQueryItem(name: Keys.term, value: term))
        components.queryItems?.append(URLQueryItem(name: Keys.entity, value: Values.entitySong))
        components.queryItems?.append(URLQueryItem(name: Keys.storefront, value: Values.storefront))

        if let url = components.url{
            let request = URLRequest(url: url)
            return request
        }else{
            return nil
        }

    }
    
    
    
    
    //https://api.music.apple.com/v1/catalog/us/search?term=james+brown&limit=2&types=artists,albums
    private func getSearchURLSongWithApMusAPI(with term: String) -> URLRequest? {
        
        var components = URLComponents()
        components.scheme = DomainAppleMusicApi.scheme
        components.host = DomainAppleMusicApi.host
        components.path = DomainAppleMusicApi.pathFindSong
        components.queryItems = [URLQueryItem]()
        components.queryItems?.append(URLQueryItem(name: Keys.term, value: term))
        components.queryItems?.append(URLQueryItem(name: Keys.limit, value: Values.limit))
        components.queryItems?.append(URLQueryItem(name: Keys.types, value: Values.types))
        if let url = components.url{
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            let devToken = UserDefaults.standard.string(forKey: authorisationHelper.devTokenKey) ?? ""
            request.addValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
            return request
        }else{
            return nil
        }
    }

    private func getSearchURLSong(with term: String) -> URL? {
        
        
        
        var components = URLComponents()
        components.scheme = Domain.scheme
        components.host = Domain.host
        components.path = Domain.path
        components.queryItems = [URLQueryItem]()
        components.queryItems?.append(URLQueryItem(name: Keys.term, value: term))
        components.queryItems?.append(URLQueryItem(name: Keys.entity, value: Values.entitySong))
        
        
        return components.url
    }

    private func getURLSong(with id: String) -> URLRequest? {
        
        var components = URLComponents()
        components.scheme = DomainAppleMusicApi.scheme
        components.host = DomainAppleMusicApi.host
        components.path = DomainAppleMusicApi.pathFetchSong
        components.path += "\(id)"
        if let url = components.url{
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let devToken = UserDefaults.standard.string(forKey: authorisationHelper.devTokenKey) ?? ""
            request.addValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
            return request
        }else{
            return nil
        }
    }

 // https://api.music.apple.com/v1/me/library?ids[albums]=1106659171&ids[songs]=1107054256&ids[music-videos]=267079116
    
    func addSongToLibrary(with id: String) -> Promise<Bool>{
        return Promise<Bool> { pup in
            if let request = getURLAddSong(with: id){
                
                authorisationHelper.data(with: request, completion: { (_, error) in
                    guard error == nil else{
                        print("ERROR: \(error.debugDescription)")
                        pup.fulfill(false)
                        return
                    }
                    
                    pup.fulfill(true)
                })
            }
            else{
                pup.fulfill(false)
            }
            
        }
    }
    
    private func getURLAddSong(with id: String) -> URLRequest? {
        
        var components = URLComponents()
        components.scheme = DomainAppleMusicApi.scheme
        components.host = DomainAppleMusicApi.host
        components.path = DomainAppleMusicApi.pathAddSong

        components.queryItems = [URLQueryItem]()
        components.queryItems?.append(URLQueryItem(name: Keys.songIds, value: id))

        if let url = components.url{
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let devToken = UserDefaults.standard.string(forKey: authorisationHelper.devTokenKey) ?? ""

            request.addValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
            request.addValue("\(fetchUserToken())", forHTTPHeaderField: "Music-User-Token")
            return request
        }else{
            return nil
        }
    }

    
    // MARK: - Constants
    
    private struct Domain {
        static let scheme = "https"
        static let host = "itunes.apple.com"
        static let path = "/search"
    }
    
    private struct DomainAppleMusicApi {
        static let scheme = "https"
        static let host = "api.music.apple.com"
        static let pathFetchSong = "/v1/catalog/ru/songs/"
        static let pathAddSong = "/v1/me/library"
        static let pathFindSong = "/v1/catalog/ru/search"
        //"https://api.music.apple.com/v1/catalog/ru/songs/\(id)")
    }
    
    private struct Keys {
        // Request
        static let term = "term"
        static let entity = "entity"
        static let storefront = "s"
        static let songIds = "ids[songs]"
        static let limit = "limit"
        static let types = "types"
        static let songs = "songs"
        static let data = "data"
        static let url = "url"
        static let attributes = "attributes"
        static let artworkForApMusicAPI = "artwork"
        static let name = "name"

        // Response
        static let results = "results"
        static let artwork = "artworkUrl100"
        static let collectionViewUrl = "collectionViewUrl"
        static let artistViewUrl = "artistViewUrl"
        static let trackId = "trackId"
        static let isStreamable = "isStreamable"
    }
    
    private struct Values {
        static let entitySong = "song"
        static let entityArtist = "artist"
        static let storefront = "143469"
        static let limit = "10"
        static let types = "songs"

    }
    
    // https://fmgid.com/stations/ultra/current.json
    
    func updateCurrentSong() -> Promise<(artist: String, song: String)?>{
        return Promise<(artist: String, song: String)?>{pup in
            let request = URLRequest(url: URL(string: last10SongsUrl)!)
            URLSession.shared.dataTask(with: request) { (dataOpt, _, error) in
                guard error == nil, let data = dataOpt
                    else{
                        print("Error with getting info from last10SongsUrl")
                        pup.fulfill(nil)
                        return
                }
                
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                guard let parsedResult = json as? [String: Any],
                    let artist = parsedResult["artist"] as? String,
                    let title = parsedResult["title"] as? String
                    else {
                        print("error with parsing json object")
                        pup.fulfill(nil)
                        return
                }
                pup.fulfill((artist: artist, song: title))
            }.resume()
        }
    }
    
        func updateLast10Songs() -> Promise<[String]>{
            return Promise<[String]>{ pup in
                
                let request = URLRequest(url: URL(string: last10SongsUrl)!)
                URLSession.shared.dataTask(with: request) { (dataOpt, _, error) in
                guard error == nil, let data = dataOpt
                    else{
                        print("Error with getting info from last10SongsUrl")
                        pup.fulfill([])
                        return
                }
                
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                guard let parsedResult = json as? [String: Any],
                let metadata = parsedResult["metadata"] as? String,
                let timeline = parsedResult["timeline"] as? String,
                let timeHoursAndMinutesString = timeline.toDateString(inputFormat: "YYYY-MM-dd HH:mm:ss", outputFormat: "HH:mm") as? String,
                let lastSongs = parsedResult["prev_tracks"] as? [[String: Any]]
                    /*let token = parsedResult["token"] as? String*/ else {
                        print("error with parsing json object")
                        pup.fulfill([])
                        return
                }
                var lastSongsString:[String] = []
                
                for song in lastSongs{
                    guard let artist = song["artist"] as? String,
                        let title = song["title"] as? String,
                        let timeline = song["timeline"] as? String,
                        let timeHoursAndMinutesString = timeline.toDateString(inputFormat: "YYYY-MM-dd HH:mm:ss", outputFormat: "HH:mm") else{
                            print("error with parsing song from json object")
                            pup.fulfill([])
                            return
                    }
                    lastSongsString.append("\(timeHoursAndMinutesString) \(artist) - \(title)")
                    
                }
                
                
                print("timeHoursAndMinutesString = \(timeHoursAndMinutesString)")
                print("parsedResult = \(parsedResult)")
                pup.fulfill(lastSongsString)
                }.resume()
            
            
//            if let myURL = URL(string: last10SongsUrl) {
//
//                do{
//                    let myHTMLString = try String(contentsOf: myURL, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
//
//                    let myLast10Songs = myHTMLString.getLast10Songs()
//
//                    pup.fulfill(myLast10Songs)
//                }
//                catch{
//                    print("Error with text from URL!!!!")
//                }
//            }else{
//                print("Wrong last10SongsUrl!!!!!!!!!!!!")
//            }
        }
    }
}
