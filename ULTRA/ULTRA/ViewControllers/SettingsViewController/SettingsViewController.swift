//
//  SettingsViewController.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 17.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var bitrateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var artworkSegmentedControl: UISegmentedControl!
    @IBOutlet weak var autoPlaySegmentedControl: UISegmentedControl!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let streamValue = UserDefaults.standard.value(forKey: "CurrentStreamRate") as? String{
            bitrateSegmentedControl.selectedSegmentIndex = StreamRate.init(kbps: streamValue)!.index
        }else{
            bitrateSegmentedControl.selectedSegmentIndex = 1
        }
        
        if let flag = UserDefaults.standard.value(forKey: "IsDownloadingMediaContentPermited") as? Bool{
            artworkSegmentedControl.selectedSegmentIndex = flag ? 0 : 1
        }else{
            artworkSegmentedControl.selectedSegmentIndex = 0
        }
        
        if let flag = UserDefaults.standard.value(forKey: "IsAutoPlay") as? Bool{
            autoPlaySegmentedControl.selectedSegmentIndex = flag ? 0 : 1
        }else{
            autoPlaySegmentedControl.selectedSegmentIndex = 1
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTappedOnBitrate(_ sender: UISegmentedControl) {
        
        
        let currentStream = StreamRate.init(kbps: sender.titleForSegment(at: sender.selectedSegmentIndex)!)!
        let radioPlayer = MagicPlayer.shared
        radioPlayer.radioURL = currentStream.streamURL
        UserDefaults.standard.set(currentStream.stringForUserDefaults, forKey: "CurrentStreamRate")
        
    }
    
    @IBAction func didTappedOnDownloadArtwork(_ sender: UISegmentedControl) {
        let navc = self.popoverPresentationController?.presentingViewController as! UINavigationController
        let vc = navc.viewControllers.first as! MainScreenController

        switch sender.selectedSegmentIndex{
        case 0:
            vc.isDownloadingMediaContentPermited = true
        case 1:
            vc.isDownloadingMediaContentPermited = false
        default: break
        }
        UserDefaults.standard.set(vc.isDownloadingMediaContentPermited, forKey: "IsDownloadingMediaContentPermited")

        
        
    }

    @IBAction func didTappedOnAutoPlay(_ sender: UISegmentedControl) {
        let player = MagicPlayer.shared
        
        switch sender.selectedSegmentIndex{
        case 0:
            player.isAutoPlay = true
        case 1:
            player.isAutoPlay = false
        default: break
        }
        UserDefaults.standard.set(player.isAutoPlay, forKey: "IsAutoPlay")
        
        
        
    }

    
    @IBAction func didTappedSendReview(_ sender: UIButton) {
        
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
