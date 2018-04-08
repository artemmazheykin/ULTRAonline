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
    private var systemPlayer = MPMusicPlayerController.systemMusicPlayer
    private var playerItem: AVPlayerItem?
    weak var slider: UISlider!
    weak var bottomPlayerView: BottomPlayerView!
    var timer = Timer()
    var displayLink = CADisplayLink()
    var nowPlaying: MPMediaItem?
    
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
            
            
            let duration = item.playbackDuration
            print("duration = \(duration)")

            if duration == 0.0{
                DispatchQueue.global(qos: .background).async {
                    usleep(500000)
                    DispatchQueue.main.async {
                        self.updateSlider()
                    }
                }
            }
            
            
            
            
            self.bottomPlayerView.songNameLabel.text = item.title
            self.bottomPlayerView.songImageView.image = image
            self.slider.maximumValue = Float(duration)
            self.slider.value = 0.0
            
            
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                self.updateTime()
            })
            RunLoop.current.add(timer, forMode: .commonModes)
            timer.fire()
            
//            self.displayLink = CADisplayLink(target: self, selector: #selector(self.updateTime))
//            self.displayLink.preferredFramesPerSecond = 1
//            self.displayLink.add(to: .current, forMode: .commonModes)
        
        }
    }
    
    @objc func updateTime() {
        
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
            //            updateSlider()
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
