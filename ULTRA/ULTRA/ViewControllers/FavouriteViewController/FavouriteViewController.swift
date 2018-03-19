//
//  FavouriteViewController.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 10.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import UIKit
import Kingfisher


class FavouriteViewController: UIViewController{

    @IBOutlet weak var favoritesTable: UITableView!
    
    @IBOutlet weak var headerView: UIView!
    
    weak var navigator: Navigator!
    weak var songService: SongService!
    var networkHelper: NetworkHelper = NetworkHelperImpl()
    var favoriteSongs:[SongModel] = []
    var favoriteSongImages:[String:UIImage] = [:]
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFavoriteSongs()
        let mainVc = self.navigationController?.viewControllers[0] as! MainScreenController
        mainVc.delegate = self
        favoritesTable.delegate = self
        favoritesTable.dataSource = self
        reloadSection()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        print("favoriteSongs.count = \(favoriteSongs.count)")

        // Do any additional setup after loading the view.
    }
    
    func updateFavoriteSongs(){
        var unsortedFavoriteSongs:[SongModel] = []

        for songDic in DataSingleton.shared.songs{
            unsortedFavoriteSongs.append(songDic.value)
        }

        favoriteSongImages = DataSingleton.shared.images

        favoriteSongs = unsortedFavoriteSongs.sorted { (song1, song2) -> Bool in
            return song1.dateOfCreation > song2.dateOfCreation
        }
    }
    
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        print("!!!!!!!!!!!!!!!!!!!!!!!!!")
//        if favoriteSongs.count != DataSingleton.shared.images.count{
//            favoritesTable.reloadData()
//            
//        }
//    }
    
    @objc func didTappedAppleMusicButton(){
        
        if selectedIndexPath != nil{
            _ = networkHelper.getUrlSong(metadata: favoriteSongs[selectedIndexPath!.row].artistAndSongName).done{ urlOpt in
                if let url = urlOpt{
                    if UIApplication.shared.canOpenURL(url)
                    {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    
    @objc func didTappedArtistButton(){
        
        if selectedIndexPath != nil{
            _ = networkHelper.getUrlArtist(metadata: favoriteSongs[selectedIndexPath!.row].artistName).done{ urlOpt in
                if let url = urlOpt{
                    if UIApplication.shared.canOpenURL(url)
                    {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }


    
    @objc func didTappedCopyNameButton(){
        
        let cell = favoriteSongs[selectedIndexPath!.row]
        UIPasteboard.general.string = cell.artistAndSongName
        let copyView = UILabel()

        copyView.text = "Название трека скопировано в буфер обмена"
        copyView.numberOfLines = 2
        copyView.adjustsFontSizeToFitWidth = true
        copyView.textAlignment = .center
        copyView.layer.cornerRadius = 20
        copyView.layer.masksToBounds = true
        copyView.backgroundColor = UIColor.gray
        view.addSubview(copyView)
        copyView.translatesAutoresizingMaskIntoConstraints = false
        var constraints:[NSLayoutConstraint] = []
        
        constraints.append(copyView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0))
        constraints.append(copyView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0))
        constraints.append(copyView.widthAnchor.constraint(equalToConstant: view.frame.width*0.8))
        constraints.append(copyView.heightAnchor.constraint(equalToConstant: 60))
        view.addConstraints(constraints)
        NSLayoutConstraint.activate(constraints)
        DispatchQueue.global(qos: .background).async {
            sleep(1)
            DispatchQueue.main.async {
                copyView.fadeOut()
//                copyView.removeFromSuperview()
            }
        }
        
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

extension FavouriteViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            let mainVc = self.navigationController?.viewControllers[0] as! MainScreenController
            let deletingSong = favoriteSongs[indexPath.row]
            if deletingSong.artistAndSongName == mainVc.currentSong.artistAndSongName{
                mainVc.currentSong.isFavorite = !mainVc.currentSong.isFavorite
            }
            
            DataSingleton.shared.deleteSongAndImageFromFavorites(songModel: favoriteSongs[indexPath.row])
            favoriteSongs.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()

            reloadSection()
        }
    }
    
    func reloadSection(indexPath: IndexPath? = nil){
        for view in headerView.subviews{
            view.removeFromSuperview()
        }
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 130, height: 130))
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0.25
        imageView.layer.borderColor = UIColor(red: 123/255, green: 123/255, blue: 123/255, alpha: 1.0).cgColor

        headerView.addSubview(imageView)
        headerView.backgroundColor = .white
        let view = UIView(frame: CGRect(x: 0, y: headerView.frame.height, width: headerView.frame.width, height: 0.5))
        view.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 222/255, alpha: 1.0)
        headerView.addSubview(view)

        if indexPath == nil{
            let infoLabel = UILabel(frame: CGRect(x: 150, y: 10, width: Int(headerView.frame.width) - 160, height: 130))
            infoLabel.text = "Здесь можно посмотреть понравившиеся треки и найти исполнителя в Apple Music"
            infoLabel.numberOfLines = 10
            infoLabel.adjustsFontSizeToFitWidth = true
            headerView.addSubview(infoLabel)
            let imageView = headerView.subviews[0] as! UIImageView
            imageView.image = #imageLiteral(resourceName: "ultra_logo_black")
            imageView.backgroundColor = .black
            imageView.contentMode = .scaleAspectFit
        }
        else{
            let cell = favoritesTable.cellForRow(at: indexPath!) as! FavoriteSongCell
            let songNameLabel = UILabel()
            let artistNameButton = UIButton()
            headerView.addSubview(artistNameButton)
            headerView.addSubview(songNameLabel)
            songNameLabel.translatesAutoresizingMaskIntoConstraints = false
            artistNameButton.translatesAutoresizingMaskIntoConstraints = false

            songNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
            artistNameButton.setTitle(favoriteSongs[indexPath!.row].artistName, for: .normal)
            artistNameButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            artistNameButton.setTitleColor(cell.artistNameLabel.textColor, for: .normal)
            artistNameButton.setTitleColor(UIColor.red, for: .highlighted)

            songNameLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10).isActive = true
            
            songNameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: +10).isActive = true
            songNameLabel.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -10).isActive = true
            artistNameButton.leftAnchor.constraint(equalTo: songNameLabel.leftAnchor).isActive = true
            artistNameButton.topAnchor.constraint(equalTo: songNameLabel.bottomAnchor).isActive = true
            artistNameButton.addTarget(self, action: #selector(didTappedArtistButton), for: .touchUpInside)
            songNameLabel.text = favoriteSongs[indexPath!.row].songName
            songNameLabel.numberOfLines = 2
            songNameLabel.adjustsFontSizeToFitWidth = true

            imageView.image = cell.artistImage.image
            imageView.backgroundColor = .black
            imageView.contentMode = .scaleAspectFit
            let appleMusicButton = UIButton(frame: CGRect(x: self.view.frame.width - 60, y: 90, width: 50, height: 50))
            headerView.addSubview(appleMusicButton)
            
            if selectedIndexPath != nil{
                _ = networkHelper.getUrlSong(metadata: favoriteSongs[selectedIndexPath!.row].artistAndSongName).done{ urlOpt in
                    if let _ = urlOpt{
                        appleMusicButton.setImage(#imageLiteral(resourceName: "ITunes"), for: .normal)
                        appleMusicButton.addTarget(self, action: #selector(self.didTappedAppleMusicButton), for: .touchUpInside)
                    }else{
                        appleMusicButton.setImage(#imageLiteral(resourceName: "copyImage"), for: .normal)
                        appleMusicButton.addTarget(self, action: #selector(self.didTappedCopyNameButton), for: .touchUpInside)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Cтереть"
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if selectedIndexPath == indexPath{
            tableView.deselectRow(at: indexPath, animated: false)
            selectedIndexPath = nil
            reloadSection(indexPath: selectedIndexPath)
        }else{
            selectedIndexPath = indexPath
            reloadSection(indexPath: selectedIndexPath)
        }        

    }
    
}

extension FavouriteViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = favoritesTable.dequeueReusableCell(withIdentifier: "FavoriteSongCell") as! FavoriteSongCell
        let song = favoriteSongs[indexPath.row]
        
        cell.songNameLabel.text = song.songName
        cell.artistNameLabel.text = song.artistName
        cell.artistImage.image = #imageLiteral(resourceName: "ultra_logo_black")
            DispatchQueue.global(qos: .background).async {
                if let image = self.favoriteSongImages[song.artistAndSongName]{
                    DispatchQueue.main.async {
                        cell.artistImage.image = image
                    }
                }else{
                    if DataSingleton.shared.isDownloadingMediaContentPermited{
                        
                        _ = self.networkHelper.getUrlImage(metadata: song.artistAndSongName, size: 300).done{urlOpt in
                            if let url = urlOpt{
                                cell.artistImage.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "ultra_logo_black"), completionHandler: { (imageOpt, _, _, _) in
                                    if let image = imageOpt{
                                        DataSingleton.shared.images[song.artistAndSongName] = image
                                        ImageCache.default.store(image, forKey: song.artistAndSongName)
                                    }else{
                                        cell.artistImage.image = #imageLiteral(resourceName: "ultra_logo_black")
                                    }
                                })
                            }
                            else{
                                cell.artistImage.image = #imageLiteral(resourceName: "ultra_logo_black")
                            }
                        }
                    }
                }
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

extension UIView{
    
    /// Parameter duration: custom animation duration
    func fadeIn(withDuration duration: TimeInterval = 1.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        })
    }
    
    /// Fade out a view with a duration
    ///
    /// - Parameter duration: custom animation duration
    func fadeOut(withDuration duration: TimeInterval = 1.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        })
    }
    
    func addLabelCopy(){
        let copyLabel = UILabel()
        copyLabel.backgroundColor = UIColor.clear
        self.addSubview(copyLabel)
        copyLabel.translatesAutoresizingMaskIntoConstraints = false
        copyLabel.text = "Название трека скопировано в буфер обмена"
        copyLabel.numberOfLines = 2
        copyLabel.adjustsFontSizeToFitWidth = true

        var constraints:[NSLayoutConstraint] = []
        
        constraints.append(copyLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0))
        constraints.append(copyLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0))
        constraints.append(copyLabel.widthAnchor.constraint(equalToConstant: self.frame.width))
        constraints.append(copyLabel.heightAnchor.constraint(equalToConstant: 50))
        self.addConstraints(constraints)
        NSLayoutConstraint.activate(constraints)

    }
}

extension FavouriteViewController: MainScreenControllerDelegate{
    
    func likeOrDislikeDidTapped(currentSong: SongModel) {
    
        switch currentSong.isFavorite{
        case true:
            favoriteSongs.insert(currentSong, at: 0)
            favoritesTable.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        case false:
            for (i,song) in favoriteSongs.enumerated(){
                var index:Int!
                if song.artistAndSongName == currentSong.artistAndSongName{
                    index = i
                }
                if let index = index{
                    favoriteSongs.remove(at: index)
                    favoritesTable.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            }
        }
    }
}
    
    

