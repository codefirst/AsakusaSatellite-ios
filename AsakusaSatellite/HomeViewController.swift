//
//  HomeViewController.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/18.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import AsakusaSatellite
import NorthLayout


private let kCellID = "Room"
private let kDefaultProfileImageURL = NSURL(string: "data:image/gif;base64,R0lGODlhEAAQAMQfAFWApnCexR4xU1SApaJ3SlB5oSg9ZrOVcy1HcURok/Lo3iM2XO/i1lJ8o2eVu011ncmbdSc8Zc6lg4212DZTgC5Hcmh3f8OUaDhWg7F2RYlhMunXxqrQ8n6s1f///////yH5BAEAAB8ALAAAAAAQABAAAAVz4CeOXumNKOpprHampAZltAt/q0Tvdrpmm+Am01MRGJpgkvBSXRSHYPTSJFkuws0FU8UBOJiLeAtuer6dDmaN6Uw4iNeZk653HIFORD7gFOhpARwGHQJ8foAdgoSGJA1/HJGRC40qHg8JGBQVe10kJiUpIQA7")! // FIXME: haneke cannot read data: scheme


class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var client: Client?
    var rooms: [Room] = [] {
        didSet {
            self.roomsView.reloadData()
        }
    }
    let roomsView: UICollectionView
    let roomsLayout = UICollectionViewFlowLayout()

    private var displayLink: CADisplayLink?
    
    // MARK: - init
    
    init() {
        roomsView = UICollectionView(frame: .zero, collectionViewLayout: roomsLayout)
        super.init(nibName: nil, bundle: nil)
        
        title = AppFullName
        
        roomsView.register(RoomCell.self, forCellWithReuseIdentifier: kCellID)
        roomsView.dataSource = self
        roomsView.delegate = self
        
        roomsLayout.scrollDirection = .vertical
        roomsLayout.itemSize = CGSize(width: 150, height: 150)
        roomsLayout.minimumInteritemSpacing = 0
        roomsLayout.minimumLineSpacing = 22
        roomsLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Controller
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = Appearance.backgroundColor
        roomsView.backgroundColor = view.backgroundColor
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Sign Out", comment: ""), style: .plain, target: self, action: #selector(auth(_:)))
        
        let autolayout = view.northLayoutFormat([:], ["rooms": roomsView])
        autolayout("H:|[rooms]|")
        autolayout("V:|[rooms]|")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadCachedRoomList()
        reloadRoomList()
        startAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopAnimation()
    }
    
    // MARK: - Caches

    private func loadCachedRoomList() {
        guard let items = CachedRoomList.loadCachedRoomList() else { return }
        rooms = items
    }
    
    // MARK: -
    
    func reloadRoomList() {
        client = Client(apiKey: UserDefaults.apiKey)
        client?.roomList() { response in
            switch response {
            case .success(let many):
                self.rooms = many.items
                CachedRoomList.cacheRoomList(many)
            case .failure(let error):
                let ac = UIAlertController(title: NSLocalizedString("Offline", comment: ""), message: error?.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Actions

    @objc private func auth(_ sender: AnyObject?) {
        if UserDefaults.apiKey == nil {
            signin()
        } else {
            signout()
        }
    }

    private func signin() {
        UserDefaults.apiKey = nil

        let welcome = WelcomeViewController()
        navigationController?.pushViewController(welcome, animated: true)

        navigationItem.leftBarButtonItem?.title = NSLocalizedString("Sign Out", comment: "")
    }

    private func signout() {
        UserDefaults.apiKey = nil
        reloadRoomList()
        navigationItem.leftBarButtonItem?.title = NSLocalizedString("Sign In", comment: "")
    }
    
    // MARK: - Animations
    
    fileprivate func startAnimation() {
        stopAnimation()
        
        displayLink = CADisplayLink(target: self, selector: #selector(displayLink(_:)))
        displayLink?.frameInterval = 2
        displayLink?.add(to: .main, forMode: .commonModes)
    }
    
    private func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    func displayLink(_ sender: CADisplayLink) {
        for i in 0..<rooms.count {
            if let cell = roomsView.cellForItem(at: IndexPath(item: i, section: 0)) as? RoomCell {
                cell.sat.displayLink(sender: sender)
            }
        }
    }
    
    // MARK: - Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rooms.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = roomsView.dequeueReusableCell(withReuseIdentifier: kCellID, for: indexPath) as! RoomCell
        cell.room = rooms[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let room = rooms[indexPath.item]
        if let c = client {
            let vc = RoomViewController(client: Client(rootURL: c.rootURL, apiKey: UserDefaults.apiKey), room: room)
            UserDefaults.currentRoom = room
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - RoomCell
    
    private class RoomCell: UICollectionViewCell {
        var room: Room? {
            didSet {
                nameLabel.text = room?.name
                let urls = (room?.ownerAndMembers ?? []).map{NSURL(string: $0.profileImageURL) ?? kDefaultProfileImageURL}
                sat.imageURLs = (urls.count > 0 ? urls : [kDefaultProfileImageURL]) // default image for public room with no owner
            }
        }
        let sat = SatelliteImageView(frame: .zero)
        let nameLabel = UILabel()
        
        private let defaultImageURL = ""
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            nameLabel.textColor = Appearance.tintColor
            nameLabel.font = UIFont.systemFont(ofSize: 14)
            nameLabel.numberOfLines = 2
            nameLabel.textAlignment = .center
            nameLabel.lineBreakMode = .byWordWrapping
            
            let autolayout = contentView.northLayoutFormat(["p": 8], ["sat": sat, "name": nameLabel])
            autolayout("H:|[sat]|")
            autolayout("H:|[name]|")
            autolayout("V:|-p-[sat]-p-[name]|")
        }
 
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
