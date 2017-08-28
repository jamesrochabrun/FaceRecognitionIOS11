//
//  FaceBoxable.swift
//  FaceRecognitionIOS11
//
//  Created by James Rochabrun on 8/27/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.

import Foundation
import UIKit

//MARK: Logic to present a box on top of a recognized face

protocol FaceBoxable {}

extension FaceBoxable where Self: UIView {
    
    func createAnimatedBoxForFace(with image: UIImage, and rect: CGRect) -> UIView {
        
        let imageScaledHeight = self.getImageScaledHeight(from: image)
        let transformFlip = CGAffineTransform.init(scaleX: 1, y: -1).translatedBy(x: 0, y: -imageScaledHeight - self.frame.height / 2 + imageScaledHeight / 2)
        let transformScale = CGAffineTransform.identity.scaledBy(x: self.frame.width, y: imageScaledHeight)
        let converted_rect = rect.applying(transformScale).applying(transformFlip)
        
        let faceBox = UIView()
        faceBox.layer.borderColor = #colorLiteral(red: 0.8941176471, green: 0, blue: 0.8784313725, alpha: 1)
        faceBox.layer.borderWidth = 2
        faceBox.layer.cornerRadius = 8
        faceBox.frame = converted_rect
        faceBox.backgroundColor = UIColor(white: 1, alpha: 0.5)
        faceBox.layer.transform = CATransform3DMakeScale(0, 0, 0)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            faceBox.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }, completion: nil)
        return faceBox
    }
    
    func getImageScaledHeight(from image: UIImage) -> CGFloat {
        return self.frame.size.width / image.size.width * image.size.height
    }
}



