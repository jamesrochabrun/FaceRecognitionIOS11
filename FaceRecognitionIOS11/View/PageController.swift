//
//  ViewController.swift
//  FaceRecognitionIOS11
//
//  Created by James Rochabrun on 8/26/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.

import UIKit

class PageController: UICollectionViewController {
    
    private var images: [UIImage] = [#imageLiteral(resourceName: "barza")]
    
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
        cell.viewModel = PageCellViewModel(photo: images[indexPath.item])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
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










