//
//  ViewController.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 14.02.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

//var streams = {
//    ultra: {stream64: "https://nashe1.hostingradio.ru:18000/ultra-64.mp3", stream128: "https://nashe1.hostingradio.ru:18000/ultra-128.mp3", tags: "//radiopleer.com/info/ultra.txt", last: "//radiopleer.com/info/ultra_last_tracks.txt"},ultrahd: {stream64: "https://nashe1.hostingradio.ru:18000/ultra-192.mp3", stream128: "https://nashe1.hostingradio.ru:18000/ultra-192.mp3", tags: "//radiopleer.com/info/ultra.txt", last: "//radiopleer.com/info/ultra_last_tracks.txt"}



// https://radiopleer.com/info/ultra.txt current
//https://radiopleer.com/info/ultra_last_tracks.txt last 10
//https://nashe1.hostingradio.ru:18000/ultra-64.mp3 64
//https://nashe1.hostingradio.ru:18000/ultra-128.mp3 128
//https://nashe1.hostingradio.ru:18000/ultra-192.mp3 192



import UIKit
import AVFoundation
import MediaPlayer
import PromiseKit

protocol MainScreenControllerDelegate{
    func likeOrDislikeDidTapped(currentSong: SongModel)
}

class MainScreenController: UIViewController, UIPopoverPresentationControllerDelegate{
    
    
    @IBOutlet weak var startStopRadio: UIButton!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var starButton: UIButton!
    var delegate: MainScreenControllerDelegate?
    
    var myURLArtistAndSongString = "https://radiopleer.com/info/ultra.txt"
    var last10SongsUrl = "https://radiopleer.com/info/ultra_last_tracks.txt"
    var last10SongsStrings: [String] = []
    
    let radioPlayer = MagicPlayer.shared
    @IBOutlet weak var artistImageFromVC: UIImageView!
    weak var navigator: Navigator!
    weak var systemParametersService:SystemParametersService!
    weak var songService: SongService!
    var networkHelper: NetworkHelper = NetworkHelperImpl()
    var currentArtistName:String!
    var currentSongName:String!
    var isDownloadingMediaContentPermited: Bool!{
        didSet{
            DataSingleton.shared.isDownloadingMediaContentPermited = self.isDownloadingMediaContentPermited
            currentSongName = "_"
        }
    }
    
    var currentSong: SongModel!{
        didSet{
            let commandCenter = MPRemoteCommandCenter.shared()
            DispatchQueue.main.async {
                
                commandCenter.dislikeCommand.isActive = !self.currentSong.isFavorite
                commandCenter.likeCommand.isActive = self.currentSong.isFavorite
                self.starButton.setImage(self.currentSong.isFavorite ? #imageLiteral(resourceName: "star-filled") : #imageLiteral(resourceName: "star-unfilled"), for: .normal)
                
            }
        }
    }
    var favoriteSongs:[ArtistModel] = []
    let bottomPlayerView = BottomPlayerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomPlayerView.passedTimeLabel.text = ""
        bottomPlayerView.remainedTimeLabel.text = ""
        bottomPlayerView.songNameLabel.text = ""
        
        radioPlayer.mainScreenDelegate = self
        bottomPlayerView.sliderDelegate = radioPlayer
        bottomPlayerView.buttonDelegate = radioPlayer
        radioPlayer.slider = bottomPlayerView.slider
        radioPlayer.bottomPlayerView = bottomPlayerView
        DataSingleton.shared.delegateMainScreenVC = self
        isDownloadingMediaContentPermited = (UserDefaults.standard.value(forKey: "IsDownloadingMediaContentPermited") as? Bool) ?? true
        
        favoriteSongs = songService.getFavoriteArtistsFromUserDefaults()
        artistImageFromVC.layer.borderWidth = 0.25
        artistImageFromVC.layer.borderColor = UIColor(red: 123/255, green: 123/255, blue: 123/255, alpha: 1.0).cgColor
        artistImageFromVC.layer.cornerRadius = 5
        artistImageFromVC.layer.masksToBounds = true
        artistImageFromVC.image = #imageLiteral(resourceName: "ultra_logo_black")
        //create a new button
        
        let favoriteButton: UIButton = UIButton(type: .custom)
        favoriteButton.setImage(#imageLiteral(resourceName: "purplesilver_icon_27"), for: .normal)
        //add function for button
        favoriteButton.addTarget(self, action: #selector(didTappedGoToFavoriteButton), for: .touchUpInside)
        //set frame
        let barButton = UIBarButtonItem(customView: favoriteButton)
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        favoriteButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let settingsButton: UIButton = UIButton(type: .custom)
        settingsButton.setImage(#imageLiteral(resourceName: "gears-80"), for: .normal)
        //add function for button
        settingsButton.addTarget(self, action: #selector(didTappedSettingsButton), for: .touchUpInside)
        //set frame
        let barButton2 = UIBarButtonItem(customView: settingsButton)
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButton2
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        settingsButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        startStopRadio.setImage(#imageLiteral(resourceName: "play-button-circled-100"), for: .normal)
        
        if radioPlayer.isPlaying{
            updateStartStopButton()
        }
        updateArtistAndSong()
        setupRemoteCommandCenter()
        
        if let frame = UIApplication.shared.keyWindow?.frame{
            bottomPlayerView.frame = CGRect(x: 0, y: frame.height - 80, width: frame.width, height: 80)
            UIApplication.shared.keyWindow?.addSubview(bottomPlayerView)

        }
        
        //        songService.resetFavourites()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if currentSong != nil{
            currentSong = songService.isThatSongFaforiteChecking(artist: currentSong.artistName, song: currentSong.songName)
        }
    }
    
    func updateStartStopButton(){
        if radioPlayer.timeControlStatus().rawValue == 0{
            DispatchQueue.main.async {
                self.startStopRadio.setImage(#imageLiteral(resourceName: "play-button-circled-100"), for: .normal)
            }
        }else{
            DispatchQueue.main.async {
                self.startStopRadio.setImage(#imageLiteral(resourceName: "pause-button-100"), for: .normal)
            }
        }
    }
    
    func updateArtistAndSong(){
        
        DispatchQueue.global(qos: .background).async {
            while true{
                
                self.myURLArtistAndSongString.getArtistAndSongFromURL(){tuple in
                    
                    if let artistAndSong = tuple{
                        if self.currentSongName != artistAndSong.song{
                            self.currentSong = self.songService.isThatSongFaforiteChecking(artist: artistAndSong.artist, song: artistAndSong.song)
                            self.currentArtistName = artistAndSong.artist
                            self.currentSongName = artistAndSong.song
                            DispatchQueue.main.async {
                                self.updateMedia()
                            }
                            if self.isDownloadingMediaContentPermited{
                                _ = self.networkHelper.getUrlImage(metadata: self.currentSong.artistAndSongName, size: 500).done{urlOpt in
                                    if let url = urlOpt{
                                        self.artistImageFromVC.kf.setImage(with: url, completionHandler: { (image, _, _, _) in
                                            
                                            if image == nil{
                                                self.artistImageFromVC.image = #imageLiteral(resourceName: "ultra_logo_black")
                                            }
                                            self.updateMedia()
                                        })
                                    }
                                    else{
                                        self.artistImageFromVC.image = #imageLiteral(resourceName: "ultra_logo_black")
                                        self.updateMedia()
                                    }
                                }
                            }else{
                                DispatchQueue.main.async {
                                    self.artistImageFromVC.image = #imageLiteral(resourceName: "ultra_logo_black")
                                }
                            }
                        }
                    }
                }
                usleep(1000000)
            }
        }
    }
    
    func updateMedia(){
        artistName.fadeTransition(0.5)
        songName.fadeTransition(0.5)
        artistName.text = currentArtistName
        songName.text = currentSongName
        radioPlayer.currentRadioSongName = currentSongName
        radioPlayer.currentRadioSongImage = artistImageFromVC.image
        
        self.updateLockScreen(artist: self.currentArtistName, song: self.currentSongName, image: self.artistImageFromVC.image!)
    }
    
    
    func updateLockScreen(artist: String, song: String, image: UIImage) {
        
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        
        //        if let image = track?.artworkImage {
        //            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image)
        //        }
        
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { (size) -> UIImage in
            return image
        })
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = song
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
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
        commandCenter.likeCommand.localizedTitle = "Нравится"
        commandCenter.dislikeCommand.localizedTitle = "Не нравится"
        commandCenter.likeCommand.addTarget(self, action: #selector(likeLockScreen))
        commandCenter.dislikeCommand.addTarget(self, action: #selector(dislikeLockScreen))
//        commandCenter.nextTrackCommand.addTarget{ event in
//        return .success
//        }
    }
    
//    @objc func likeOrDislike(){
//        if currentSong != nil{
//            
//            currentSong.isFavorite = !currentSong.isFavorite
//            
//            if currentSong.isFavorite{
//                
//                DataSingleton.shared.addSongAndImageToFavorites(songModel: currentSong)
//                
//            }else{
//                DataSingleton.shared.deleteSongAndImageFromFavorites(songModel: currentSong)
//            }
//            starButton.setImage(currentSong.isFavorite ? #imageLiteral(resourceName: "star-filled") : #imageLiteral(resourceName: "star-unfilled"), for: .normal)
//            updateCommandCenter()
//
//        }
//    }
    
    @objc func dislikeLockScreen(){
        if currentSong != nil{
            
            currentSong.isFavorite = false
            
            DataSingleton.shared.deleteSongAndImageFromFavorites(songModel: currentSong)
            starButton.setImage(currentSong.isFavorite ? #imageLiteral(resourceName: "star-filled") : #imageLiteral(resourceName: "star-unfilled"), for: .normal)
            updateCommandCenter()
            delegate?.likeOrDislikeDidTapped(currentSong: currentSong)
        }
    }

    @objc func likeLockScreen(){
        if currentSong != nil{
            
            currentSong.isFavorite = true
            
            DataSingleton.shared.addSongAndImageToFavorites(songModel: currentSong)
            starButton.setImage(currentSong.isFavorite ? #imageLiteral(resourceName: "star-filled") : #imageLiteral(resourceName: "star-unfilled"), for: .normal)
            updateCommandCenter()
            delegate?.likeOrDislikeDidTapped(currentSong: currentSong)
        }
    }

    @IBAction func startStopRadioDidTapped(_ sender: UIButton) {
        
        if radioPlayer.isPlaying{
            sender.setImage(#imageLiteral(resourceName: "play-button-circled-100"), for: .normal)
            radioPlayer.pause()
            radioPlayer.isPlaying = false
        }
        else{
            sender.setImage(#imageLiteral(resourceName: "pause-button-100"), for: .normal)
            radioPlayer.play()
            radioPlayer.isPlaying = true
        }
    }
    
    
    @IBAction func didTappedLikeButtonOnVC(_ sender: UIButton) {
        
        if currentSong != nil{
            
            currentSong.isFavorite = !currentSong.isFavorite
            
            if currentSong.isFavorite{
                DataSingleton.shared.addSongAndImageToFavorites(songModel: currentSong)
            }else{
                DataSingleton.shared.deleteSongAndImageFromFavorites(songModel: currentSong)
            }
            sender.setImage(currentSong.isFavorite ? #imageLiteral(resourceName: "star-filled") : #imageLiteral(resourceName: "star-unfilled"), for: .normal)
            updateCommandCenter()

        }
    }
    
    func updateCommandCenter(){
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.dislikeCommand.isActive = !currentSong.isFavorite
        commandCenter.likeCommand.isActive = currentSong.isFavorite
    }
    
    @IBAction func didTappedGoToFavoriteButton(_ sender: UIBarButtonItem) {
        navigator.favouriteViewController(didTappedButtonFrom: self)
    }
    
    @IBAction func didTappedButtonToLast10Songs(_ sender: UIButton) {
        
        // get a reference to the view controller for the popover
        let popController = UIStoryboard(name: "Story", bundle: nil).instantiateViewController(withIdentifier: "Last10SongController") as! Last10SongController
        
        popController.last10SongsStrings = DataSingleton.shared.last10SongsStrings
        popController.verifiedLast10songs = DataSingleton.shared.last10Songs
        popController.preferredContentSize = CGSize(width: 350, height: 450)
        // set the presentation style
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        // set up the popover presentation controller
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = self.view
        
        popController.popoverPresentationController?.sourceRect = sender.frame
        
        // present the popover
        self.present(popController, animated: true, completion: nil)
        
    }
    
    @IBAction func didTappedSettingsButton(_ sender: UIButton) {
        
        // get a reference to the view controller for the popover
        let popController = UIStoryboard(name: "Story", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        
//        popController.last10SongsStrings = DataSingleton.shared.last10SongsStrings
//        popController.verifiedLast10songs = DataSingleton.shared.last10Songs
        popController.preferredContentSize = CGSize(width: 350, height: 300)
        // set the presentation style
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        // set up the popover presentation controller
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.barButtonItem = self.navigationItem.leftBarButtonItem
        popController.popoverPresentationController?.sourceRect = sender.frame

        // present the popover
        self.present(popController, animated: true, completion: nil)

    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension MainScreenController: MagicPlayerDelegate{

    func playPauseStopDidTapped() {
        updateStartStopButton()
    }

}

extension MainScreenController: DataSingletonDelegate{
    
    func favoriteSongsHaveChanged() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.dislikeCommand.isActive = !currentSong.isFavorite
        commandCenter.likeCommand.isActive = currentSong.isFavorite
    }
}

