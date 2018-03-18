//
//  ViewController.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 14.02.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//


// https://radiopleer.com/info/ultra.txt
import UIKit
import AVFoundation
import MediaPlayer

class MainScreenController: UIViewController{
    
    
    @IBOutlet weak var startStopRadio: UIButton!
    var isPlaying = false
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var songName: UILabel!
    var myURLArtistAndSongString = "https://radiopleer.com/info/ultra.txt"
    let radioPlayer = RadioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString = "https://nashe1.hostingradio.ru:18000/ultra-128.mp3"
        
        radioPlayer.player.isAutoPlay = false
        radioPlayer.player.radioURL = URL(string: urlString)!
        
        startStopRadio.layer.cornerRadius = startStopRadio.layer.frame.width/2
        
        updateArtistAndSong()
        //        setupConfigPlayer()
        setupNotifications()
        setupRemoteCommandCenter()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func updateArtistAndSong(){
        DispatchQueue.global(qos: .background).async {
            while true{
                
                if let myURL = URL(string: self.myURLArtistAndSongString) {
                    
                    do{
                        let myHTMLString = try String(contentsOf: myURL, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                        
                        let substrings = myHTMLString.components(separatedBy: "\"")
                        
                        var _artist: String?
                        var _song: String?
                        
                        if substrings.count == 9{
                            
                            for (i,substring) in substrings.enumerated(){
                                
                                if substring == ":"{
                                    if _artist == nil{
                                        _artist = substrings[i+1]
                                    }
                                    else{
                                        _song = substrings[i+1]
                                    }
                                }
                            }
                        }
                        else{
                            print("myHTMLString is wrong!")
                        }
                        if let artist = _artist, let song = _song{
                            DispatchQueue.main.async {
                                self.artistName.text = artist
                                self.songName.text = song
                            }
                        }
                    }
                    catch{
                        print("Error with text from URL!!!!")
                    }
                }
                usleep(1000000)
            }
        }
    }
    
    
    
    func setupRemoteCommandCenter() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { event in
            return .success
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { event in
            return .success
        }
        
        //        // Add handler for Next Command
        //        commandCenter.nextTrackCommand.addTarget { event in
        //            return .success
        //        }
        //
        //        // Add handler for Previous Command
        //        commandCenter.previousTrackCommand.addTarget { event in
        //            return .success
        //        }
    }
    
    //    func setupConfigPlayer(){
    //        let urlString = "https://nashe1.hostingradio.ru:18000/ultra-128.mp3"
    //
    //        let url = URL(string: urlString)!
    //
    //        let playerItem = AVPlayerItem(url: url)
    //        playerItem.preferredForwardBufferDuration = 100
    //
    //        player = AVPlayer(playerItem:playerItem)
    ////        player.rate = 0.0
    //    }
    
    @IBAction func startStopRadioDidTapped(_ sender: UIButton) {
        
        if isPlaying{
            sender.setTitle("Play", for: .normal)
            radioPlayer.player.pause()
            isPlaying = false
        }
        else{
            sender.setTitle("Pause", for: .normal)
            radioPlayer.player.play()
            isPlaying = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNotifications() {
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self,
//                                       selector: #selector(handleInterruption),
//                                       name: .AVAudioSessionInterruption,
//                                       object: AVAudioSession.sharedInstance())
        
    }
    
    @objc func handleInterruption(notification: NSNotification) {
        print("handleInterruption")
        guard let value = (notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber)?.uintValue,
            let interruptionType =  AVAudioSessionInterruptionType(rawValue: value)
            else {
                print("notification.userInfo?[AVAudioSessionInterruptionTypeKey]", notification.userInfo?[AVAudioSessionInterruptionTypeKey])
                return }
        switch interruptionType {
        case .began:
            print("began")
            radioPlayer.player.pause()
            if radioPlayer.player.rate == 0.0{
                startStopRadio.setTitle("Play", for: .normal)
                isPlaying = false
            }
            /**/
            do {
                try AVAudioSession.sharedInstance().setActive(false)
                print("AVAudioSession is inactive")
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        default :
            print("ended")
            if let optionValue = (notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? NSNumber)?.uintValue, AVAudioSessionInterruptionOptions(rawValue: optionValue) == .shouldResume {
                print("should resume")
                // ok to resume playing, re activate session and resume playing
                /**/
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                    print("AVAudioSession is Active again")
                    radioPlayer.player.play()
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                self.startStopRadio.setTitle("Pause", for: .normal)
                self.isPlaying = true
            }
        }
    }

        //    @objc func handleInterruption(notification: Notification) {
        //        guard let userInfo = notification.userInfo,
        //            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
        //            let type = AVAudioSessionInterruptionType(rawValue: typeValue) else {
        //                return
        //        }
        //        if type == .began {
        //
        //            if radioPlayer.player.rate == 0.0{
        //                startStopRadio.setTitle("Play", for: .normal)
        //                //            player.pause()
        //                isPlaying = false
        //            }
        //        }
        //        else if type == .ended {
        //            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
        //                let options = AVAudioSessionInterruptionOptions(rawValue: optionsValue)
        //                if options.contains(.shouldResume) {
        //
        //                    do{
        //                        print("AVAudioSession.sharedInstance().isOtherAudioPlaying = \(AVAudioSession.sharedInstance().isOtherAudioPlaying)")
        //                        try AVAudioSession.sharedInstance().setActive(true)
        //                    }
        //                    catch{
        //                        print("fuck")
        //                    }
        //                        self.startStopRadio.setTitle("Pause", for: .normal)
        ////                        self.setupConfigPlayer()
        //                        self.radioPlayer.player.play()
        //                        self.isPlaying = true
        //
        //                } else {
        //                    // Interruption Ended - playback should NOT resume
        //                }
        //            }
        //        }
        //    }
}

