//
//  PageControllerViewModel.swift
//  FaceRecognitionIOS11
//
//  Created by James Rochabrun on 8/27/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//
import Foundation
import UIKit

struct PageControllerViewModel {
    
    private let dummyImages: [UIImage]
    
    init(images: [UIImage]) {
        self.dummyImages = images
    }
    
    func getImage(at index: IndexPath) -> UIImage {
        return self.dummyImages[index.item]
    }
    
    func getCount() -> Int {
        return self.dummyImages.count
    }
}
