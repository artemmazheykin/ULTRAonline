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


protocol MagicPlayerDelegate {
    func playPauseStopDidTapped()
}

class MagicPlayer {
    
    var asset: AVAsset!
    private var avPlayer: AVPlayer!
    private var systemPlayer = MPMusicPlayerController.systemMusicPlayer
    private var playerItem: AVPlayerItem?
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
    var delegate: MagicPlayerDelegate?
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
            stop()
            let audiosession = AVAudioSession.sharedInstance()
            do{
                try audiosession.setActive(false)
            }
            catch{
                print("errorrrr!!!!!")
            }
            favoriteSongIDsDescriptor.startItemID = id
            let item = systemPlayer.nowPlayingItem!
            let duration = item.playbackDuration
            item.
            systemPlayer.setQueue(with: favoriteSongIDsDescriptor)
            systemPlayer.play()
        }
    }
    
    open func timeControlStatus() -> AVPlayerTimeControlStatus{
        return avPlayer.timeControlStatus
    }
    open func play() {
        
        
        avPlayer?.play()
        DispatchQueue.global(qos: .background).async {
            
            
            usleep(500000)
            if self.avPlayer?.timeControlStatus.rawValue == 1 || self.avPlayer?.timeControlStatus.rawValue == 0{
                self.setupPlayer(with: self.asset)
                self.avPlayer?.play()
            }
        }
        isPlaying = true
        delegate?.playPauseStopDidTapped()
    }
    
    open func pause() {
        guard let avPlayer = avPlayer else { return }
        avPlayer.pause()
        isPlaying = false
        delegate?.playPauseStopDidTapped()
    }

    open func stop() {
        guard let avPlayer = avPlayer else { return }
        avPlayer.pause()
        avPlayer.replaceCurrentItem(with: nil)
        isPlaying = false
        delegate?.playPauseStopDidTapped()

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

    }
    
    @objc private func handlePlaybackState(notification: Notification) {
        switch systemPlayer.playbackState {
        case .playing:
            print("play")
        case .paused, .stopped:
            print("stop")
            
        default:
            break
        }
        
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
