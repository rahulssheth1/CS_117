//
//  FeedTableViewCell.swift
//  InternTest
//
//  Created by Rahul Sheth on 7/27/17.
//  Copyright © 2017 Rahul Sheth. All rights reserved.
//

import Foundation
import UIKit

class RecruiterFeedTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    var activityIndicator: UIActivityIndicatorView!
    
    var object: User? {
        didSet {
            
            activityIndicator.startAnimating()
            object?.imageView?.addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions.new, context: nil)
            
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "image") {
            activityIndicator.hidesWhenStopped = true
            activityIndicator.stopAnimating()
            if (self.object?.imageView?.image?.size.height != nil && self.object?.imageView?.image?.size.width != nil) {
                if (self.object?.imageView?.image?.size.height.isLess(than: (self.object?.imageView?.image?.size.width)!))! {
                    self.object?.imageView?.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
                } else {
                    self.object?.imageView?.widthAnchor.constraint(equalToConstant: CGFloat(width / 3) ).isActive = true
                }
            } else {
                self.object?.imageView?.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
            }
        }
    }
    deinit {
        object?.imageView?.removeObserver(self, forKeyPath: "image")
    }
    var width: Int
    var height: Int
    var collectionView: UICollectionView
    var imageArray = [UIImage]()
    var companyDescription = UILabel()
    var videoURL = String()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CellID")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellID", for: indexPath)
        cell.backgroundColor = UIColor.white
        companyDescription.text = self.object?.companyDesc
        companyDescription.numberOfLines = 0
        companyDescription.lineBreakMode = .byWordWrapping
        switch indexPath.item {
        case 0:
            let backView = UIView()
            cell.addSubview(backView)
            backView.translatesAutoresizingMaskIntoConstraints = false
            backView.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
            backView.backgroundColor = UIColor.black
            backView.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
            backView.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            backView.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            cell.addSubview((self.object?.imageView)!)
            self.object?.imageView?.translatesAutoresizingMaskIntoConstraints = false
            if (self.object?.imageView?.image?.size.height != nil && self.object?.imageView?.image?.size.width != nil) {
                if (self.object?.imageView?.image?.size.height.isLess(than: (self.object?.imageView?.image?.size.width)!))! {
                    self.object?.imageView?.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
                } else {
                    self.object?.imageView?.widthAnchor.constraint(equalToConstant: CGFloat(width / 3) ).isActive = true
                }
            } else {
                self.object?.imageView?.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
            }
            self.object?.imageView?.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
            self.object?.imageView?.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            self.object?.imageView?.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            cell.addSubview(self.activityIndicator)
            self.activityIndicator.color = UIColor.gray
            self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            self.activityIndicator.leftAnchor.constraint(equalTo: (self.object?.imageView?.leftAnchor)!).isActive = true
            self.activityIndicator.rightAnchor.constraint(equalTo: (self.object?.imageView?.rightAnchor)!).isActive = true
            self.activityIndicator.topAnchor.constraint(equalTo: (self.object?.imageView?.topAnchor)!).isActive = true
            self.activityIndicator.bottomAnchor.constraint(equalTo: (self.object?.imageView?.bottomAnchor)!).isActive = true
            
            break
        case 1:
            cell.addSubview(companyDescription)
            companyDescription.translatesAutoresizingMaskIntoConstraints = false
            companyDescription.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            companyDescription.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            companyDescription.textAlignment = .center
            companyDescription.widthAnchor.constraint(equalToConstant: cell.bounds.width * 0.7).isActive = true
            companyDescription.heightAnchor.constraint(equalToConstant: cell.bounds.height).isActive = true
            break
        case 2:
            break
        case 3:
            break
        case 4:
            break
        case 5:
            break
        default:
            break
        }
        return cell
    }
    

    init(style: UITableViewCellStyle, reuseIdentifier: String?, pWidth: Int, pHeight: Int) {
        width = pWidth
        height = pHeight
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: width, height: height)
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        super.init(style: style, reuseIdentifier: "CellID")
        collectionView.delegate = self
        collectionView.dataSource = self
        self.addSubview(collectionView)
       
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpCollection()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        setUpCollection()
    }
    
    func setUpCollection() {
        collectionView = UICollectionView(frame: CGRect.zero)
        collectionView.delegate = self
        collectionView.dataSource = self
        self.addSubview(collectionView)
    }
   
   
//    var activityIndicator: UIActivityIndicatorView!
//    
//    var object: User? {
//        didSet {
//            
//            activityIndicator.startAnimating()
//            object?.imageView?.addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions.new, context: nil)
//            
//        }
//    }
//    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if (keyPath == "image") {
//            activityIndicator.hidesWhenStopped = true
//            activityIndicator.stopAnimating()
//            
//        }
//    }
//    deinit {
//        object?.imageView?.removeObserver(self, forKeyPath: "image")
//    }
}

