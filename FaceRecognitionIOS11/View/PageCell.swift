//
//  PageCell.swift
//  FaceRecognitionIOS11
//
//  Created by James Rochabrun on 8/26/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
import UIKit
import Vision


class PageCell: BaseCell {
    
    //MARK: properties
    var detectedFaces: [UIView]?
    var viewModel: PageCellViewModel? {
        didSet {
            guard let vm = viewModel else { return }
            detectedFaces?.forEach { (v) in
                v.removeFromSuperview()
            }
            detectedFaces = nil
            photoImageView.image = vm.photoImage()
        }
    }
    
    //MARK: UI components
    fileprivate let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        return aiv
    }()
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override func setUpViews() {
        
        addSubview(photoImageView)
        photoImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        photoImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        photoImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        photoImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        addSubview(activityIndicatorView)
        activityIndicatorView.topAnchor.constraint(equalTo: topAnchor, constant: 50).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    //MARK: Tap Event
    @objc fileprivate func handleTap() {
        if detectedFaces?.count ?? 0 > 0 {
            detectedFaces?.forEach({$0.removeFromSuperview()})
            detectedFaces?.removeAll()
        } else {
            activityIndicatorView.startAnimating()
            detectFaces()
        }
    }
}

//MARK: Detection methods
extension PageCell {
    
    private func detectFaces() {
        
        guard let image = photoImageView.image else { return }
        
        let imageScaledHeight = frame.size.width / image.size.width * image.size.height
        
        let request = VNDetectFaceRectanglesRequest { (req, err) in
            
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
            }
            
            self.detectedFaces = []
            req.results?.forEach({ (res) in
                
                guard let faceObservation = res as? VNFaceObservation else { return }
                DispatchQueue.main.async {
                    let rect = faceObservation.boundingBox
                    let transformFlip = CGAffineTransform.init(scaleX: 1, y: -1).translatedBy(x: 0, y: -imageScaledHeight - self.frame.height / 2 + imageScaledHeight / 2)
                    let transformScale = CGAffineTransform.identity.scaledBy(x: self.frame.width, y: imageScaledHeight)
                    let converted_rect = rect.applying(transformScale).applying(transformFlip)
                    
                    let redView = UIView()
                    redView.layer.borderColor = UIColor.red.cgColor
                    redView.layer.borderWidth = 2
                    redView.layer.cornerRadius = 8
                    redView.frame = converted_rect
                    redView.backgroundColor = UIColor(white: 1, alpha: 0.5)
                    self.addSubview(redView)
                    
                    redView.layer.transform = CATransform3DMakeScale(0, 0, 0)
                    
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        redView.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    }, completion: nil)
                    
                    self.detectedFaces?.append(redView)
                }
            })
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let cgImage = image.cgImage else { return }
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([request])
            } catch let err {
                print("Failed to perform request", err)
            }
        }
    }
}

struct PageCellViewModel {
    
    private let image: UIImage
    //Helper method
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










