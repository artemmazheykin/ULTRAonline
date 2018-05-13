//
//  MagicPlayer.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 18.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import UIKit
import AVFoundation
import StoreKit
import MediaPlayer


@objc protocol MagicPlayerDelegate: class {
    @objc optional func playPauseStopDidTapped()
    @objc optional func updateSystemPlayer()
}

class MagicPlayer{
    
    var asset: AVAsset!
    private var avPlayer: AVPlayer!
    private var systemPlayer = MPMusicPlayerController.systemMusicPlayer//.applicationMusicPlayer
    private var playerItem: AVPlayerItem?
    weak var slider: UISlider!
    weak var bottomPlayerView: BottomPlayerView!
    var timer = Timer()
    var displayLink = CADisplayLink()
    var nowPlaying: MPMediaItem?
    var networkHelper = NetworkHelperImpl()

    open var radioURL: URL{
        didSet{
            asset = AVAsset(url: radioURL)
            setupPlayer(with: asset)
            
            if isPlaying{
                play()
            }
            
        }
    }
    open var isAutoPlay: Bool{
        didSet{
            if isAutoPlay{
                play()
            }
        }
    }
    
    open var isPlaying = false
    
    var mainScreenDelegate: MagicPlayerDelegate?
    var favorVCDelegate: MagicPlayerDelegate?
    
    var favoriteSongIDsDescriptor: MPMusicPlayerStoreQueueDescriptor!
    
    open static let shared = MagicPlayer()
    
    init() {
        systemPlayer.prepareToPlay()
        if let isAutoplayFromUserDefaults = UserDefaults.standard.value(forKey: "IsAutoPlay") as? Bool{
            isAutoPlay = isAutoplayFromUserDefaults
            print("isAutoPlay = \(isAutoPlay)")
        }
        else{
            isAutoPlay = false
        }
        if let streamUrlString = UserDefaults.standard.value(forKey: "CurrentStreamRate") as? String{
            let currentStreamEnum = StreamRate.init(kbps: streamUrlString) ?? StreamRate._128
            radioURL = currentStreamEnum.streamURL
        }
        else{
            radioURL = StreamRate._128.streamURL
        }
        asset = AVAsset(url: radioURL)
        setupPlayer(with: asset)
        
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        }
        catch{
            print("Error with setting audiosession!!!!!")
        }
        setupNotifications()
        if isAutoPlay{
            play()
        }
        systemPlayer.repeatMode = .all
        systemPlayer.beginGeneratingPlaybackNotifications()
    }
    
    deinit {
        systemPlayer.endGeneratingPlaybackNotifications()
    }
    
    open func systemPlayerPlay(id: String?){
        if let id = id{
            DispatchQueue.global(qos: .userInitiated).async {
                self.stop()
                let audiosession = AVAudioSession.sharedInstance()
                do{
                    try audiosession.setActive(false)
                }
                catch{
                    print("errorrrr!!!!!")
                }
//                var items = MPMediaQuery.songs().items!
//                var ultaItems = [MPMediaItem]()
//                
//                for item in items{
//                    print("item.name = \(item.playbackStoreID)")
//                    
//                }
                self.favoriteSongIDsDescriptor.startItemID = id
                self.systemPlayer.setQueue(with: self.favoriteSongIDsDescriptor)
                self.systemPlayer.play()
            }
        }
    }
    
    func updateSlider(){

        if let item = nowPlaying{
            print("item.playbackStoreID = \(item.playbackStoreID)")
            var artistAndSong = ""
            
            for keyValue in DataSingleton.shared.trackIds{
                if keyValue.value == item.playbackStoreID{
                    artistAndSong = keyValue.key
                }
            }
            
            let image = DataSingleton.shared.images[artistAndSong]
            let appleMusicArtwork = item.artwork
            let appleMusicImage = appleMusicArtwork?.image(at: CGSize(width: 300, height: 300))

            _ = networkHelper.getSongDuration(id: item.playbackStoreID).done{
                duration in
                self.slider.maximumValue = Float(duration/1000)
                self.bottomPlayerView.songNameLabel.text = item.title
                if image != nil{
                    self.bottomPlayerView.songImageView.image = image
                }else{
                    self.bottomPlayerView.songImageView.image = appleMusicImage
                }
                self.slider.value = 0.0

            }
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in
                self.updateTime()
            })
            
            RunLoop.current.add(timer, forMode: .commonModes)
            timer.fire()
            
//            self.displayLink = CADisplayLink(target: self, selector: #selector(self.updateTime))
//            self.displayLink.preferredFramesPerSecond = 1
//            self.displayLink.add(to: .current, forMode: .commonModes)
        
        }
    }
    
    func updateSliderInBackgroundThread(){
        DispatchQueue.global(qos: .background).async {
            while true{
                usleep(300000)
                if !self.bottomPlayerView.editingInProcess{
                    DispatchQueue.main.async {
                        self.slider.setValue(Float(self.systemPlayer.currentPlaybackTime), animated: true)
                    }
                }
            }
        }
    }
    
    func timeSecondsToFormatted (interval: Int) -> String{
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        
        let formattedString = formatter.string(from: TimeInterval(interval))!
        return formattedString
    }
    
    @objc func updateTime() {
        
        let passedTime = Int(slider.value)
        let remainedTime = Int(slider.maximumValue - slider.value)
        
        if passedTime < 10 {
            bottomPlayerView.passedTimeLabel.text = "0:0\(timeSecondsToFormatted(interval: passedTime))"
        }else if passedTime < 60{
            bottomPlayerView.passedTimeLabel.text = "0:\(timeSecondsToFormatted(interval: passedTime))"
        }else{
            bottomPlayerView.passedTimeLabel.text = timeSecondsToFormatted(interval: passedTime)
        }
        
        if remainedTime < 10 {
            bottomPlayerView.remainedTimeLabel.text = "-0:0\(timeSecondsToFormatted(interval: remainedTime))"
        }else if remainedTime < 60{
            bottomPlayerView.remainedTimeLabel.text = "-0:\(timeSecondsToFormatted(interval: remainedTime))"
        }else{
            bottomPlayerView.remainedTimeLabel.text = "-\(timeSecondsToFormatted(interval: remainedTime))"
        }

        if !bottomPlayerView.editingInProcess{
            DispatchQueue.main.async {
                self.slider.setValue(Float(self.systemPlayer.currentPlaybackTime), animated: true)
            }
        }
    }
    
    open func timeControlStatus() -> AVPlayerTimeControlStatus{
        return avPlayer.timeControlStatus
    }
    open func play() {
        
        systemPlayer.stop()
        avPlayer?.play()
        DispatchQueue.global(qos: .background).async {
            
            
            usleep(500000)
            if self.avPlayer?.timeControlStatus.rawValue == 1 || self.avPlayer?.timeControlStatus.rawValue == 0{
                self.setupPlayer(with: self.asset)
                self.avPlayer?.play()
            }
        }
        isPlaying = true
        mainScreenDelegate?.playPauseStopDidTapped?()
    }
    
    open func pause() {
        guard let avPlayer = avPlayer else { return }
        avPlayer.pause()
        isPlaying = false
        mainScreenDelegate?.playPauseStopDidTapped?()
    }
    
    open func stop() {
        guard let avPlayer = avPlayer else { return }
        avPlayer.pause()
        avPlayer.replaceCurrentItem(with: nil)
        isPlaying = false
        mainScreenDelegate?.playPauseStopDidTapped?()
        
    }
    
    private func setupPlayer(with asset: AVAsset) {
        if avPlayer == nil {
            avPlayer = AVPlayer()
        }
        
        playerItem = AVPlayerItem(asset: asset)
        avPlayer?.replaceCurrentItem(with: playerItem)
        
    }    
    
    private func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleInterruption), name: .AVAudioSessionInterruption, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handlePlaybackState), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handlePlayingItem), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: systemPlayer)
    }
    
    @objc private func handlePlaybackState(notification: Notification) {
        switch systemPlayer.playbackState {
        case .playing:
//            updateSliderInBackgroundThread()
            print("play")
            return
        case .paused, .stopped:
            print("stop")
            return
        default:
            break
        }
    }
    
    @objc private func handlePlayingItem(notification: Notification) {
        timer.invalidate()
        nowPlaying = systemPlayer.nowPlayingItem
        updateSlider()
    }
    
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSessionInterruptionType(rawValue: typeValue) else {
                return
        }
        
        switch type {
        case .began:
            DispatchQueue.main.async {
                self.pause()
            }
            do{
                try AVAudioSession.sharedInstance().setActive(false)
            }
            catch{
                print("error")
            }
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { break }
            let options = AVAudioSessionInterruptionOptions(rawValue: optionsValue)
            do{
                try AVAudioSession.sharedInstance().setActive(true, with: .notifyOthersOnDeactivation)
            }
            catch{
                print("error")
            }
            DispatchQueue.main.async {
                options.contains(.shouldResume) ? self.play() : self.pause()
            }
        }
    }
    
}

extension MagicPlayer: SliderDelegate{
    
    func sliderValueChanged(value: Float){
        systemPlayer.currentPlaybackTime = TimeInterval(value)
    }
}

extension MagicPlayer: ButtonDelegate{
    
    func playbackButtonDidPressed(kindOfButton: KindOfPressedButton) {
     
        switch kindOfButton{
        case .previousTrack:
            systemPlayer.skipToPreviousItem()
        case .play:
            systemPlayer.play()
        case .nextTrack:
            systemPlayer.skipToNextItem()
        }
    }
}






