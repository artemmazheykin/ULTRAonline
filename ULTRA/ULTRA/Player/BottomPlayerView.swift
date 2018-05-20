//
//  BottomPlayerView.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 29.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import UIKit

protocol SliderDelegate {
    func sliderValueChanged(value: Float)
}

protocol ButtonDelegate {
    func playbackButtonDidPressed(kindOfButton: KindOfPressedButton)
}


enum KindOfPressedButton{
    case previousTrack, play, pause, nextTrack
}


class BottomPlayerView: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var songNameLabel: UILabel!
    
    @IBOutlet weak var passedTimeLabel: UILabel!
    @IBOutlet weak var remainedTimeLabel: UILabel!
    
    
    @IBOutlet weak var previousSongButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextSongButton: UIButton!
    var editingInProcess = false
    
    var sliderDelegate: SliderDelegate?
    var buttonDelegate: ButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        instanceFromNib()
    }
    
    @IBAction func nextTrackTouchDown(_ sender: UIButton) {
        let backgroundView = UIView()
        backgroundView.tag = 777
        print("sender.frame.origin = \(sender.frame.origin)")
        backgroundView.alpha = 0.5
        backgroundView.layer.cornerRadius = sender.frame.width/2
        backgroundView.frame.size = CGSize(width: sender.frame.width, height: sender.frame.height)
        backgroundView.backgroundColor = UIColor.gray
        sender.insertSubview(backgroundView, at: 0)
        UIView.animate(withDuration: 0.3, animations: {
            let resize = CGFloat(10)
            backgroundView.frame.size = CGSize(width: sender.frame.width+resize, height: sender.frame.height+resize)
            backgroundView.layer.cornerRadius = (sender.frame.width+resize)/2
            backgroundView.center = CGPoint(x: sender.frame.width/2, y: sender.frame.height/2)
        }) { (result) in
            for view in sender.subviews{
                if view.tag == 777{
                    view.removeFromSuperview()
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        instanceFromNib()
    }
    
    func instanceFromNib(){
                
        Bundle.main.loadNibNamed("BottomPlayer", owner: self, options: nil)
        var darkBlur:UIBlurEffect = UIBlurEffect()
        if #available(iOS 10.0, *) { //iOS 10.0 and above
            darkBlur = UIBlurEffect(style: UIBlurEffectStyle.regular)//prominent,regular,extraLight, light, dark
        } else { //iOS 8.0 and above
            darkBlur = UIBlurEffect(style: UIBlurEffectStyle.dark) //extraLight, light, dark
        }
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = contentView.frame //your view that have any objects
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)

        slider.setThumbImage(#imageLiteral(resourceName: "smallDot"), for: .normal)
        slider.setThumbImage(#imageLiteral(resourceName: "bigDot"), for: .highlighted)
        slider.minimumTrackTintColor = UIColor.black
        slider.setValue(0, animated: false)
        
        addSubview(contentView)
        contentView.backgroundColor = UIColor.clear
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        songImageView.layer.cornerRadius = 3
        songImageView.layer.masksToBounds = true
        songImageView.layer.borderWidth = 0.25
        songImageView.layer.borderColor = UIColor(red: 123/255, green: 123/255, blue: 123/255, alpha: 1.0).cgColor
        slider.isContinuous = true
        switch MagicPlayer.shared.systemPlayer.playbackState{
        case .playing, .paused:
            self.playPauseButton.tag = 1
        default:
            self.playPauseButton.tag = 0
        }

        previousSongButton.setImage(#imageLiteral(resourceName: "previous-track"), for: .normal)
        updateStartStopButton()
        nextSongButton.setImage(#imageLiteral(resourceName: "next-track"), for: .normal)
    }
    
    func updateStartStopButton(){
        DispatchQueue.main.async {
            
            switch self.playPauseButton.tag {
            case 0:
                if MagicPlayer.shared.timeControlStatus() == .paused{
                    self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
                }else{
                    self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                }
                
            case 1:
                switch MagicPlayer.shared.systemPlayer.playbackState{
                case .paused:
                    self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
                default:
                    self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                }
                
            default:
                break
            }
        }
    }
    
    @IBAction func valueChanged(_ sender: UISlider) {
        
        editingInProcess = true
    }
    
    
    @IBAction func editingDidEnd(_ sender: UISlider) {
        
        sliderDelegate?.sliderValueChanged(value: sender.value)
        editingInProcess = false
        
    }

    @IBAction func previousTrackButtonDidTapped(_ sender: UIButton) {
        buttonDelegate?.playbackButtonDidPressed(kindOfButton: .previousTrack)
    }
    
    @IBAction func playButtonDidTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if MagicPlayer.shared.isPlaying{
                MagicPlayer.shared.pause()
                MagicPlayer.shared.isPlaying = false
            }
            else{
                MagicPlayer.shared.play()
                MagicPlayer.shared.isPlaying = true
            }
        case 1:
            switch MagicPlayer.shared.systemPlayer.playbackState.rawValue{
            case 2:
                buttonDelegate?.playbackButtonDidPressed(kindOfButton: .play)
                sender.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            default:
                buttonDelegate?.playbackButtonDidPressed(kindOfButton: .pause)
                sender.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            }
            
        default:
            break
        }
        
    }
    
    @IBAction func nextTrackButtonDidTapped(_ sender: UIButton) {
        buttonDelegate?.playbackButtonDidPressed(kindOfButton: .nextTrack)
    }
    
    
    
    
    
}

