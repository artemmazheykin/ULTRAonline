//
//  BottomPlayerView.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 29.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import UIKit

class BottomPlayerView: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var songNameLabel: UILabel!
    
    @IBOutlet weak var previousSongButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextSongButton: UIButton!
    
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

        slider.setThumbImage(#imageLiteral(resourceName: "vertical-line"), for: .normal)
        slider.setThumbImage(#imageLiteral(resourceName: "play"), for: .highlighted)

        addSubview(contentView)
        contentView.backgroundColor = UIColor.clear
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        songImageView.layer.cornerRadius = 3
        songImageView.layer.masksToBounds = true
        songImageView.layer.borderWidth = 0.25
        songImageView.layer.borderColor = UIColor(red: 123/255, green: 123/255, blue: 123/255, alpha: 1.0).cgColor
        
        slider.addTarget(self, action: #selector (dragDidBegin), for: .touchDragInside)
        slider.addTarget(self, action: #selector (dragDidEnd), for: .touchUpInside)
        slider.setThumbImage(#imageLiteral(resourceName: "vertical-line"), for: .normal)

    }
    
    // from git
    
    // MARK: Constants
    
    private let maximumUnitCount = 2
    private let sliderMinimumValue: Float = 0
    private let sliderMaximumValue: Float = 1.0
    
    // MARK: Properties
    
    var delegate: PlayerSliderProtocol?
    var duration: TimeInterval = TimeInterval() {
        didSet {
            updateProgress(self.progress)
        }
    }
    
    var progress: Float {
        set(newValue) {
            guard !isDragging else {
                return
            }
            updateProgress(newValue)
        }
        
        get {
            return _progress
        }
    }
    
    private var _progress: Float = 0
    private var isDragging = false
    
    // MARK: Outlets
    
    @IBOutlet private weak var pastLabel: UILabel!
    @IBOutlet private weak var remainLabel: UILabel!
    @IBAction private func sliderValueDidChanged(_ sender: Any) {
        updateProgress(slider.value)
    }
    
    // MARK:
    private func updateProgress(_ progress: Float) {
        var actualValue = progress >= sliderMinimumValue ? progress: sliderMinimumValue
        actualValue = progress <= sliderMaximumValue ? actualValue: sliderMaximumValue
        
        self._progress = actualValue
        
        self.slider.value = actualValue
        
        let pastInterval = Float(duration) * actualValue
        let remainInterval = Float(duration) - pastInterval
        
        self.pastLabel.text = intervalToString(TimeInterval(pastInterval))
        self.remainLabel.text = intervalToString(TimeInterval(remainInterval))
    }
    
    private func intervalToString (_ interval: TimeInterval) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.maximumUnitCount = maximumUnitCount
        return formatter.string(from: interval)
    }
    
    @objc private func dragDidBegin() {
        isDragging = true
    }
    
    @objc private func dragDidEnd() {
        self.isDragging = false
        self.notifyDelegate()
    }
    
    private func notifyDelegate() {
        let timePast = self.duration * Double(slider.value)
        self.delegate?.onValueChanged(progress: slider.value, timePast: timePast)
    }

}

protocol PlayerSliderProtocol: class {
    func onValueChanged(progress: Float, timePast: TimeInterval)
}

