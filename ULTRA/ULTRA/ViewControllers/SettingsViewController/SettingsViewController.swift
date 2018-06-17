//
//  SettingsViewController.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 17.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import UIKit
import PromiseKit

class SettingsViewController: UIViewController {

    var authorisationHelper: AuthorisationHelper!

    @IBOutlet weak var bitrateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var artworkSegmentedControl: UISegmentedControl!
    @IBOutlet weak var autoPlaySegmentedControl: UISegmentedControl!
    @IBOutlet weak var addToAppleMusicSegmentedControl: UISegmentedControl!
    
    
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
        
        if let flag = UserDefaults.standard.value(forKey: "IsAutoAddingToAppleMusicPermited") as? Bool{
            if UserDefaults.standard.value(forKey: "UserToken") == nil{
                addToAppleMusicSegmentedControl.selectedSegmentIndex = 1
            }else{
                addToAppleMusicSegmentedControl.selectedSegmentIndex = flag ? 0 : 1
            }
        }else{
            addToAppleMusicSegmentedControl.selectedSegmentIndex = 1
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
    
    @IBAction func didTappedOnAddToAppleMusic(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            
            if UserDefaults.standard.value(forKey: "UserToken") == nil{
                
                _ = authorisationHelper.requestUserToken().done{ result in
                    if result == nil{
                        self.addToAppleMusicSegmentedControl.selectedSegmentIndex = 1
                        return
                    }
                }
            }
            UserDefaults.standard.set(true, forKey: "IsAutoAddingToAppleMusicPermited")
        case 1:
            UserDefaults.standard.set(false, forKey: "IsAutoAddingToAppleMusicPermited")
        default: break
        }
        
    }
    
    
    @IBAction func didTappedSendReview(_ sender: UIButton) {
//  app id 1360797374
        let appID = "1360797374"
        let urlStr = "itms-apps://itunes.apple.com/app/id\(appID)" // (Option 1) Open App Page
//        let urlStr = "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(appID)" // (Option 2) Open App Review Tab
        
        
        if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
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
