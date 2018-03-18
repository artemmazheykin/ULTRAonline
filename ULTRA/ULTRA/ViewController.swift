//
//  ViewController.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 14.02.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

protocol vcDelegate {
    func doPlay()
}

// https://radiopleer.com/info/ultra.txt
import UIKit
import AVFoundation

class ViewController: UIViewController/*, vcDelegate */{
    
//    var delegate:
//    func doPlay() {
//        <#code#>
//    }
//
    
//    let audioSession = AVAudioSession.sharedInstance()

    var player : AVPlayer!
    @IBOutlet weak var startStopRadio: UIButton!
    var isPlaying = false
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var songName: UILabel!
    let myURLArtistAndSongString = "https://radiopleer.com/info/ultra.txt"
    var stream: AudioFileStreamID!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        stream = AudioFileStreamID
        
        startStopRadio.layer.cornerRadius = startStopRadio.layer.frame.width/2
        
        
        updateArtistAndSong()
        setupConfigPlayer()
        setupNotifications()
        
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

    func setupConfigPlayer(){
        let url = "https://nashe1.hostingradio.ru:18000/ultra-128.mp3"
        let playerItem = AVPlayerItem(url: URL(string: url)!)
        playerItem.preferredForwardBufferDuration = 100
        
        player = AVPlayer(playerItem:playerItem)
//        player.rate = 0.0
    }
    
    @IBAction func startStopRadioDidTapped(_ sender: UIButton) {
        
        if isPlaying{
            sender.setTitle("Play", for: .normal)
            player.pause()
            isPlaying = false
        }
        else{
            sender.setTitle("Pause", for: .normal)
            player.play()
            isPlaying = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleInterruption),
                                       name: .AVAudioSessionInterruption,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleReset),
                                       name: .AVAudioSessionMediaServicesWereReset,
                                       object: nil)

        notificationCenter.addObserver(self,
                                       selector: #selector(handleRuntimeError),
                                       name: .AVCaptureSessionRuntimeError,
                                       object: nil)

        notificationCenter.addObserver(self,
                                       selector: #selector(handleRuntimeError),
                                       name: .session,
                                       object: nil)

    }
    
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSessionInterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
            startStopRadio.setTitle("Play", for: .normal)
            player.pause()
            isPlaying = false
            
        }
        else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSessionInterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    
                    do{
                        try AVAudioSession.sharedInstance().setActive(true)
                    }
                    catch{
                        print("fuck")
                    }
                        self.startStopRadio.setTitle("Pause", for: .normal)
                        self.setupConfigPlayer()
                        self.player.play()
                        self.isPlaying = true
                    
                } else {
                    // Interruption Ended - playback should NOT resume
                }
            }
        }
    }
    
    @objc func handleReset(notification: Notification) {
        
        print("handleReset!!!!!!!")
    }
    
    @objc func handleRuntimeError(notification: Notification) {
        
        print("handleRuntimeError!!!!!!!")
    }

}

