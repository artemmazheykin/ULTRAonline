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
    case previousTrack, play, nextTrack
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
        
        let previousImage = #imageLiteral(resourceName: "previous-track").withRenderingMode(.alwaysTemplate)
        let playImage = #imageLiteral(resourceName: "play").withRenderingMode(.alwaysTemplate)
        let nextImage = #imageLiteral(resourceName: "next-track").withRenderingMode(.alwaysTemplate)

        
        previousSongButton.setImage(previousImage, for: .normal)
//        previousSongButton.backgro
        
        playPauseButton.setImage(playImage, for: .normal)
        nextSongButton.setImage(nextImage, for: .normal)
        
        
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
        buttonDelegate?.playbackButtonDidPressed(kindOfButton: .play)
    }
    
    @IBAction func nextTrackButtonDidTapped(_ sender: UIButton) {
        buttonDelegate?.playbackButtonDidPressed(kindOfButton: .nextTrack)
    }
    
    
    
    
    
}

