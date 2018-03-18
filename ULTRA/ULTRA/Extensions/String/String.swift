//
//  String.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 10.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import Foundation

extension String{
    
    func getLast10Songs() -> [String]{
        
        let substrings = self.components(separatedBy: "</li>")
        
        var myTimeAnd10Songs:[String] = []
        
        for substring in substrings{
            let subsubstrings = substring.components(separatedBy: "<li>")
            for subsubstring in subsubstrings{
                let subsubsubstrings = subsubstring.components(separatedBy: "\r\n")
                myTimeAnd10Songs.append(contentsOf: subsubsubstrings)
            }
        }
        
        var myTempTimeAnd10Songs:[String] = []
        
        for item in myTimeAnd10Songs{
            if item != ""{
                myTempTimeAnd10Songs.append(item)
            }
        }
        
        return myTempTimeAnd10Songs
        
    }
    
    
    func getArtistAndSongFromURL(completion: @escaping ((artist: String, song: String)?) -> ()){
        
        var artist: String?
        var song: String?

        if let myURL = URL(string: self) {
            
            do{
                let myHTMLString = try String(contentsOf: myURL, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                
                let substrings = myHTMLString.components(separatedBy: "\"")
                
                
                if substrings.count == 9{
                    
                    for (i,substring) in substrings.enumerated(){
                        
                        if substring == ":"{
                            if artist == nil{
                                artist = substrings[i+1]
                            }
                            else{
                                song = substrings[i+1]
                            }
                        }
                    }
                }
                else{
                    print("myHTMLString is wrong!")
                    completion(nil)
                }
                if let artist = artist, let song = song{
                    completion((artist,song))
                }
            }
            catch{
                print("Error with text from URL!!!!")
            }
        }else{
            completion(nil)
        }
    }
}
