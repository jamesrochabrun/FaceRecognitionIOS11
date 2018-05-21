//
//  ViewController.swift
//  FaceRecognitionIOS11
//
//  Created by James Rochabrun on 8/26/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.

import UIKit

class PageController: UICollectionViewController {
    
    private var images: [UIImage] =  [#imageLiteral(resourceName: "sasha4"),  #imageLiteral(resourceName: "p1"), #imageLiteral(resourceName: "p6"), #imageLiteral(resourceName: "p7"), #imageLiteral(resourceName: "p9"), #imageLiteral(resourceName: "p10"), #imageLiteral(resourceName: "p2"), #imageLiteral(resourceName: "p3"), #imageLiteral(resourceName: "p4"), #imageLiteral(resourceName: "people2"), #imageLiteral(resourceName: "grid1"), #imageLiteral(resourceName: "family1"), #imageLiteral(resourceName: "family2"), #imageLiteral(resourceName: "people1")]
    private lazy var viewModel = PageControllerViewModel(images: self.images)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(PageCell.self)
        collectionView?.isPagingEnabled = true
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: PageCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.viewModel = PageCellViewModel(photo: self.viewModel.getImage(at: indexPath))
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.getCount()
    }
}

extension PageController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}










