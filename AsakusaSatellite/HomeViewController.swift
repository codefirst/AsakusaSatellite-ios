//
//  HomeViewController.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/18.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import AsakusaSatellite


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
    
    // MARK: - init
    
    override init() {
        roomsView = UICollectionView(frame: CGRectZero, collectionViewLayout: roomsLayout)
        super.init(nibName: nil, bundle: nil)
        
        title = AppFullName
        
        roomsView.registerClass(RoomCell.self, forCellWithReuseIdentifier: kCellID)
        roomsView.dataSource = self
        roomsView.delegate = self
        
        roomsLayout.scrollDirection = .Vertical
        roomsLayout.itemSize = CGSizeMake(150, 150)
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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Sign Out", comment: ""), style: .Plain, target: self, action: "signout:")
        
        let autolayout = view.autolayoutFormat(nil, ["rooms": roomsView])
        autolayout("H:|[rooms]|")
        autolayout("V:|[rooms]|")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadRoomList()
    }
    
    func reloadRoomList() {
        client = Client(apiKey: UserDefaults.apiKey)
        client?.roomList() { response in
            switch response {
            case .Success(let many):
                self.rooms = many().items
            case .Failure(let error):
                let ac = UIAlertController(title: NSLocalizedString("Offline", comment: ""), message: error?.localizedDescription, preferredStyle: .Alert)
                self.presentViewController(ac, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Actions
    
    func signout(sender: AnyObject?) {
        UserDefaults.apiKey = nil
        reloadRoomList()
    }
    
    // MARK: - Collection View
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = roomsView.dequeueReusableCellWithReuseIdentifier(kCellID, forIndexPath: indexPath) as RoomCell
        cell.room = rooms[indexPath.item]
        return cell
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
        let sat = SatelliteImageView(frame: CGRectZero)
        let nameLabel = UILabel()
        
        private let defaultImageURL = ""
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            nameLabel.textColor = Appearance.tintColor
            nameLabel.font = UIFont.systemFontOfSize(14)
            nameLabel.numberOfLines = 2
            nameLabel.textAlignment = .Center
            nameLabel.lineBreakMode = .ByWordWrapping
            
            let autolayout = contentView.autolayoutFormat(["p": 8], ["sat": sat, "name": nameLabel])
            autolayout("H:|[sat]|")
            autolayout("H:|[name]|")
            autolayout("V:|-p-[sat]-p-[name]|")
        }
 
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
