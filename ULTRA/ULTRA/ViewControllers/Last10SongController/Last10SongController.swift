//
//  Last10SongController.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 10.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import UIKit
import PromiseKit

class Last10SongController: UIViewController{
    
    @IBOutlet weak var songsTableView: UITableView!
    var verifiedLast10songs: [SongModel] = []
    var last10SongsStrings: [String] = []{
        didSet{
            if songsTableView != nil{
                songsTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataSingleton.shared.delegate = self

        songsTableView.delegate = self
        songsTableView.dataSource = self
        
        
        songsTableView.tableFooterView = UIView()
        
        // Do any additional setup after loading the view.
    }
    
    @objc func starDidTapped(sender: UIButton){
        let navc = self.popoverPresentationController?.presentingViewController as! UINavigationController
        let vc = navc.viewControllers.first as! MainScreenController
        
        let song = verifiedLast10songs[sender.tag]
        song.isFavorite = !song.isFavorite
        
        if song.isFavorite{
            DataSingleton.shared.addSongAndImageToFavorites(songModel: song)
        }else{
            DataSingleton.shared.deleteSongAndImageFromFavorites(songModel: song)
        }
        if song.artistName == vc.currentSong.artistName && song.songName == vc.currentSong.songName{
            vc.currentSong = song
        }
        sender.setImage(song.isFavorite ? #imageLiteral(resourceName: "star-filled") : #imageLiteral(resourceName: "star-unfilled"), for: .normal)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension Last10SongController: UITableViewDelegate{
    
}

extension Last10SongController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return last10SongsStrings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = songsTableView.dequeueReusableCell(withIdentifier: "SongCell") as! SongCell
        
        cell.starButton.tag = indexPath.row
        cell.starButton.setImage(verifiedLast10songs[indexPath.row].isFavorite ? #imageLiteral(resourceName: "star-filled") : #imageLiteral(resourceName: "star-unfilled"), for: .normal)
        
        cell.starButton.addTarget(self, action: #selector(starDidTapped(sender:)), for: .touchUpInside)
        
        cell.songNameLabel.text = last10SongsStrings[indexPath.row]
        return cell
    }
}

extension Last10SongController: DataSingletonDelegate{
    
    func last10SongsHaveChanged(last10Songs: [SongModel], last10SongsStrings: [String]) {
        self.verifiedLast10songs = last10Songs
        self.last10SongsStrings = last10SongsStrings
    }
}




