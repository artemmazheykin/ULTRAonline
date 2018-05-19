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
import StoreKit

class NetworkHelperImpl: NetworkHelper{
    
    // URLs
    
    var last10SongsUrl = "https://radiopleer.com/info/ultra_last_tracks.txt"
    
    let currentRegionCode = Locale.current.regionCode?.lowercased()
    
    func fetchDeveloperToken() -> String{
        return DataSingleton.shared.developerToken
    }
    
    func fetchUserToken() -> String{
        return DataSingleton.shared.userToken
    }
    
    
    
    
    func getUrlImage(metadata: String, size: Int) -> Promise<URL?> {
        return Promise<URL?>{pup in
            
            guard !metadata.isEmpty, metadata !=  " - ", let request = getSearchURLSongWithApMusAPI(with: metadata) else {
                pup.fulfill(nil)
                return
            }
            
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                guard error == nil, let data = data else {
                    print("!!!!error \(error.debugDescription)")
                    pup.fulfill(nil)
                    return
                }

                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print("jsooooooon  = \(json)")
                guard let parsedResult = json as? [String: Any],
                    let results = parsedResult[Keys.results] as? [String: Any],
                    let songs = results[Keys.songs] as? [String: Any],
                    let dataArray = songs[Keys.data] as? Array<[String: Any]>,
                    let dataFirst = dataArray.first,
                    let attributes = dataFirst[Keys.attributes] as? [String: Any],
                    let artwork = attributes[Keys.artworkForApMusicAPI] as? [String: Any],
                    var artworkUrlString = artwork[Keys.url] as? String else {
                        print("error with parsing json object")
                        pup.fulfill(nil)
                        return
                }
                if size > 0 {
                    artworkUrlString = artworkUrlString.replacingOccurrences(of: "{w}x{h}", with: "\(size)x\(size)")
                }
                
                let artworkURL = URL(string: artworkUrlString)
                pup.fulfill(artworkURL)
            }).resume()
        }
    }
    
    func getForTestUrlImage(metadata: String, size: Int) -> Promise<URL?> {
        return Promise<URL?>{pup in
            
            guard !metadata.isEmpty, metadata !=  " - ", let url = getSearchURLSongWithStorefront(with: metadata) else {
                pup.fulfill(nil)
                return
            }
            
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                guard error == nil, let data = data else {
                    print("!!!!error \(error.debugDescription)")
                    pup.fulfill(nil)
                    return
                }
                
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                guard let parsedResult = json as? [String: Any],
                    let results = parsedResult[Keys.results] as? Array<[String: Any]>,
                    let result = results.first,
                    var artwork = result[Keys.artwork] as? String else {
                        pup.fulfill(nil)
                        return
                }
                print(result)
                if size != 100, size > 0 {
                    artwork = artwork.replacingOccurrences(of: "100x100", with: "\(size)x\(size)")
                }
                
                let artworkURL = URL(string: artwork)
                pup.fulfill(artworkURL)
            }).resume()
        }
    }
    
    func getUrlSong(metadata: String) -> Promise<(metadata: String,url: URL?)?> {
        return Promise<(metadata: String,url: URL?)?>{pup in
            
            guard !metadata.isEmpty, metadata !=  " - ", let url = getSearchURLSongWithStorefront(with: metadata) else {
                pup.fulfill(nil)
                return
            }
            
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                guard error == nil, let data = data else {
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
            }).resume()
        }
    }
    
    func getSongDuration(id: String) -> Promise<Double>{
        return Promise<Double>{pup in
            
            if let request = getURLSong(with: id){
                let dataTask = URLSession.shared.dataTask(with: request){ (data, response, error) in
                    guard error == nil, let data = data else {
                        print("Error \(error?.localizedDescription) with getSongDuration URL!!!")
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
                }
                dataTask.resume()
            }
            else{
                pup.fulfill(0)
            }
        }
    }

    
    func getUrlArtist(metadata: String) -> Promise<URL?> {
        return Promise<URL?>{pup in
            
            guard !metadata.isEmpty, metadata !=  " - ", let url = getSearchURLSongWithStorefront(with: metadata) else {
                pup.fulfill(nil)
                return
            }
            
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                guard error == nil, let data = data else {
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
//                                print("result = \(result)")
                let artistViewUrl = URL(string: artistView)
                pup.fulfill(artistViewUrl)
            }).resume()
        }
    }
    
    func getTrackId(metadata: String) -> Promise<String?> {
        return Promise<String?>{pup in
            
            guard !metadata.isEmpty, metadata !=  " - ", let url = getSearchURLSongWithStorefront(with: metadata) else {
                pup.fulfill(nil)
                return
            }
            
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                guard error == nil, let data = data else {
                    print("error.debugDescription = \(error.debugDescription)")
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
            }).resume()
        }
    }
    
    func getTrackIds(songNames: [String]) -> Promise<[String:String]>{
        return Promise<[String:String]>{pup in
            
            
            var result:[String:String] = [:]
            for songName in songNames{
                
                _ = getTrackId(metadata: songName).done{ trackId in
                    result[songName] = trackId
                }
                
                
            }
        }
    }


    private func getSearchURLSongWithStorefront(with term: String) -> URL? {
        
        
        
        var components = URLComponents()
        components.scheme = Domain.scheme
        components.host = Domain.host
        components.path = Domain.path
        components.queryItems = [URLQueryItem]()
        components.queryItems?.append(URLQueryItem(name: Keys.term, value: term))
        components.queryItems?.append(URLQueryItem(name: Keys.entity, value: Values.entitySong))
        components.queryItems?.append(URLQueryItem(name: Keys.storefront, value: Values.storefront))

        return components.url
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
            request.addValue("Bearer \(fetchDeveloperToken())", forHTTPHeaderField: "Authorization")
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
            request.addValue("Bearer \(fetchDeveloperToken())", forHTTPHeaderField: "Authorization")
            return request
        }else{
            return nil
        }
    }

 // https://api.music.apple.com/v1/me/library?ids[albums]=1106659171&ids[songs]=1107054256&ids[music-videos]=267079116
    
    func addSongToLibrary(with id: String) -> Promise<Bool>{
        return Promise<Bool> { pup in
            if let request = getURLAddSong(with: id){
                let dataTask = URLSession.shared.dataTask(with: request)
                dataTask.resume()
                pup.fulfill(true)
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
            request.addValue("Bearer \(fetchDeveloperToken())", forHTTPHeaderField: "Authorization")
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
        static let limit = "1"
        static let types = "songs"

    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in

            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(metadata: String, size: Int) -> Promise<UIImage> {
        return Promise<UIImage>{ pup in
            _ = getUrlImage(metadata: metadata, size: size).done {result in
                
                if let url = result{

                    self.getDataFromUrl(url: url) { data, response, error in
                        guard let data = data, error == nil else {
                            pup.fulfill(#imageLiteral(resourceName: "ultra_logo_black"))
                            return
                        }
//                        print(response?.suggestedFilename ?? url.lastPathComponent)
                        if let image = UIImage(data: data){
                            pup.fulfill(image)
                        }
                        else{
                            pup.fulfill(#imageLiteral(resourceName: "ultra_logo_black"))
                        }
                        
                    }
                    
                }
            }
            
        }
    }
    
    func updateLast10Songs() -> Promise<[String]>{
        return Promise<[String]>{ pup in
            if let myURL = URL(string: last10SongsUrl) {
                
                do{
                    let myHTMLString = try String(contentsOf: myURL, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                    
                    let myLast10Songs = myHTMLString.getLast10Songs()
                    
                    pup.fulfill(myLast10Songs)
                }
                catch{
                    print("Error with text from URL!!!!")
                }
            }else{
                print("Wrong last10SongsUrl!!!!!!!!!!!!")
            }
        }
    }
}
