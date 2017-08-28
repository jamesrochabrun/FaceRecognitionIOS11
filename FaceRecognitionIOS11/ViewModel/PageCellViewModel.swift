//
//  PageCellViewModel.swift
//  FaceRecognitionIOS11
//
//  Created by James Rochabrun on 8/26/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//
import Foundation
import UIKit

struct PageCellViewModel {
    
    private let image: UIImage
    
    init(photo: UIImage) {
        self.image = photo
    }
    
    func photoImage() -> UIImage {
        return self.image
    }
    
    func cgImage() -> CGImage? {
        return self.image.cgImage
    }
}
