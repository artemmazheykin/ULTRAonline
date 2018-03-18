//
//  MagicPlayer.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 18.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import UIKit
import AVFoundation

protocol MagicPlayerDelegate {
    func playPauseStopDidTapped()
}

class MagicPlayer {
    
    var asset: AVAsset!
    private var player: AVPlayer!
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

    }
    
    open func timeControlStatus() -> AVPlayerTimeControlStatus{
        return player.timeControlStatus
    }
    open func play() {
        
        
        player?.play()
        DispatchQueue.global(qos: .background).async {
            
            
            usleep(500000)
            if self.player?.timeControlStatus.rawValue == 1 || self.player?.timeControlStatus.rawValue == 0{
                self.setupPlayer(with: self.asset)
                self.player?.play()
            }
        }
        isPlaying = true
        delegate?.playPauseStopDidTapped()
    }
    
    open func pause() {
        guard let player = player else { return }
        player.pause()
        isPlaying = false
        delegate?.playPauseStopDidTapped()
    }

    open func stop() {
        guard let player = player else { return }
        player.replaceCurrentItem(with: nil)
        isPlaying = false
        delegate?.playPauseStopDidTapped()

    }

    private func setupPlayer(with asset: AVAsset) {
        if player == nil {
            player = AVPlayer()
        }
        
        playerItem = AVPlayerItem(asset: asset)
        player?.replaceCurrentItem(with: playerItem)
        
    }    
    
    private func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleInterruption), name: .AVAudioSessionInterruption, object: nil)
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
