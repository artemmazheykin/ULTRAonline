//
//  NetworkHelper.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 11.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import UIKit
import PromiseKit

protocol NetworkHelper: class{
    
    
//    func downloadImage(metadata: String, size: Int) -> Promise<UIImage>
    func getUrlImage(songName: String, metadata: String, size: Int) -> Promise<URL?>
    func getUrlSong(metadata: String) -> Promise<(metadata: String,url: URL?)?>
    func getUrlArtist(metadata: String) -> Promise<URL?>
    func getTrackId(metadata: String) -> Promise<String?>
    func getSongDuration(id: String) -> Promise<Double>
    func addSongToLibrary(with id: String) -> Promise<Bool>
    func updateLast10Songs() -> Promise<[String]>
}
