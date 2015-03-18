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
        roomsLayout.itemSize = CGSizeMake(148, 148)
        roomsLayout.minimumInteritemSpacing = 8
        roomsLayout.minimumLineSpacing = 8
        roomsLayout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Controller
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = Appearance.backgroundColor
        roomsView.backgroundColor = view.backgroundColor
        
        let autolayout = view.autolayoutFormat(nil, ["rooms": roomsView])
        autolayout("H:|[rooms]|")
        autolayout("V:|[rooms]|")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
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
            }
        }
        let nameLabel = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            nameLabel.textColor = Appearance.tintColor
            nameLabel.font = UIFont.systemFontOfSize(14)
            nameLabel.numberOfLines = 2
            nameLabel.textAlignment = .Center
            nameLabel.lineBreakMode = .ByWordWrapping
            
            let autolayout = contentView.autolayoutFormat(["p": 8], ["name": nameLabel])
            autolayout("H:|[name]|")
            autolayout("V:[name]|")
        }
 
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
