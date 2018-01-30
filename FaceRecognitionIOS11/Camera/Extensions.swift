//
//  Extensions.swift
//  FaceRecognitionIOS11
//
//  Created by James Rochabrun on 1/30/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//
import Foundation
import AVFoundation
import UIKit

extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        default: return nil
        }
    }
}

