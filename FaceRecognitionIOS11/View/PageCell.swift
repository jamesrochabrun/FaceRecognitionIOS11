//
//  PageCell.swift
//  FaceRecognitionIOS11
//
//  Created by James Rochabrun on 8/26/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
import UIKit
import Vision

class PageCell: BaseCell, FaceBoxable {
    
    //MARK: properties
    var detectedFaces: [UIView]?
    var boundingBoxes: [CGRect] = []
    
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

//MARK: Detection method Core

extension PageCell {
    
    private func detectFaces() {
        let request = self.createFaceRectangleRequest()
        self.performImageRequestHandler(from: request)
    }
    
    /* VNDetectFaceRectanglesRequest :
     @brief A request that will detect faces in an image.
     @details This request will generate VNFaceObservation objects with defined a boundingBox.
     */
    func createFaceRectangleRequest() -> VNDetectFaceRectanglesRequest {
        
        boundingBoxes.removeAll()
        //Asynchronous request
        return VNDetectFaceRectanglesRequest { (req, err) in
            
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
            }
            self.detectedFaces = []
            //MARK: handles VNFaceObservation
            //MARK: the request.results returns an array of ANY that need to be Downcasted to a VNFaceObservation
            req.results?.forEach({ (res) in
                
                guard let faceObservation = res as? VNFaceObservation else { return }
                self.handleUIFor(faceObservation: faceObservation, completion: { rect in
                    self.boundingBoxes.append(rect)
                })
            })
            
            /// MARK: - do the overall calcs
            DispatchQueue.main.async {
                let rect = CGRect.overAllBoundingBoxFrom(boundingBoxes: self.boundingBoxes, tolerance: 0.1)
                
                print("KMTEST first \(rect)")
                let faceBox = self.createAnimatedBoxForFace(with: self.viewModel!.photoImage(), and: rect!)
                
                let totalrRect = rect?.denormalizeBoundingBoxFor(image: self.viewModel!.photoImage(), in: self)
                
                print("KMTEST second faceBox\(faceBox.frame)")
                print("KMTEST third totalrRect\(totalrRect)")

                
                self.addSubview(faceBox)
            }
        }
    }
    
    //MARK: handles VNImageRequestHandler
    func performImageRequestHandler(from request: VNDetectFaceRectanglesRequest) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let cgImage = self.viewModel!.cgImage() else { return }
            /*!
             @brief initWithCVPixelBuffer:options creates a VNImageRequestHandler to be used for performing requests against the image passed in as buffer.
             
             @param pixelBuffer A CVPixelBuffer containing the image to be used for performing the requests. The content of the buffer cannot be modified for the lifetime of the VNImageRequestHandler.
             
             */
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([request])
            } catch let err {
                print("Failed to perform request", err)
            }
        }
    }
    
    //MARK: HelperMethod handles VNFaceObservation results boundingBox
    /*!
     @class VNFaceObservation
     @superclass VNObservation
     @brief VNFaceObservation is the result of a face detection request or derivatives like a face landmark request.
     @discussion The properties filled in this obervation depend on the request being performed. For instance if just a VNDetectFaceRectanglesRequest was performed the landmarks will not be populated. VNFaceObservation are also used as inputs to other request as defined by the VNFaceObservationAccepting protocol. An example would be the VNDetectFaceLandmarksRequest. This can be helpful for instance if the face rectangles in an image are not derived from a VNDetectFaceRectanglesRequest but instead come from other sources like EXIF or other face detectors. In that case the client of the API creates a VNFaceObservation with the boundingBox (in normalized coordinates) that were based on those detected faces.
     
     */
    func handleUIFor(faceObservation: VNFaceObservation, completion: @escaping (CGRect) ->())  {
        
        
        DispatchQueue.main.async {
            /*!
             @brief The bounding box of the detected object. The coordinates are normalized to the dimensions of the processed image, with the origin at the image's lower-left corner.
             */
            let boundingBox = faceObservation.boundingBox
            completion(boundingBox)
            
            let faceBox = self.createAnimatedBoxForFace(with: self.viewModel!.photoImage(), and: boundingBox)
            self.addSubview(faceBox)
            self.detectedFaces?.append(faceBox)
            
        }
    }
}

extension CGRect {
    
    static func overAllBoundingBoxFrom(boundingBoxes: [CGRect], tolerance: CGFloat) -> CGRect? {
        
        /// Sort Max X coordinates
        let originXCoordinates = boundingBoxes.map { $0.minX }
        /// Sort Max Y coordinates
        let originYCoordinates = boundingBoxes.map { $0.minY }
        /// Find overall minX
        guard let minOverallX = originXCoordinates.min() else { return nil }
        /// Find overall minY
        guard let minOveralY = originYCoordinates.min() else { return nil }
        /// Find overall maxX
        
        ///Find originY + height = rect.maxY
        let maxYFromRects = boundingBoxes.map { $0.maxY }
        
        ///Find originX + width = rect.maxX
        let maxXFromRects = boundingBoxes.map { $0.maxX }
        
        /// Find overall maxX
        guard let maxOverallX = maxXFromRects.max() else { return nil }
        /// Find overall maxY
        guard let maxOverallY = maxYFromRects.max() else { return nil }
        
        let finalWidth = maxOverallX - minOverallX + tolerance * 2
        let finalHeight = maxOverallY - minOveralY + tolerance * 2
        let overallOriginY = minOveralY - tolerance
        let overallOriginX = minOverallX - tolerance
        
        return CGRect(x: overallOriginX, y: overallOriginY, width: finalWidth, height: finalHeight)
    }
    
    func denormalizeBoundingBoxFor(image: UIImage, in view: UIView) -> CGRect {
        
        let scaledHeight = scaledHeightFor(image: image, in: view)
        /// understanding denormalization
        let x = view.frame.width * origin.x
        let h = scaledHeight * height
        let y = scaledHeight * (1 - origin.y) - h
        let w = view.frame.width * width
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    /// helper method
    func scaledHeightFor(image: UIImage, in view: UIView) -> CGFloat {
        return view.frame.width / image.size.width * image.size.height
    }
}

//
//private func transformBoundingBox(_ boundingBox: CGRect) -> CGRect {
//
//    var size: CGSize
//    var origin: CGPoint
//    switch UIDevice.current.orientation {
//    case .landscapeLeft, .landscapeRight:
//        size = CGSize(width: boundingBox.width * bounds.height,
//                      height: boundingBox.height * bounds.width)
//    default:
//        size = CGSize(width: boundingBox.width * bounds.width,
//                      height: boundingBox.height * bounds.height)
//    }
//
//    switch UIDevice.current.orientation {
//    case .landscapeLeft:
//        origin = CGPoint(x: boundingBox.minY * bounds.width,
//                         y: boundingBox.minX * bounds.height)
//    case .landscapeRight:
//        origin = CGPoint(x: (1 - boundingBox.maxY) * bounds.width,
//                         y: (1 - boundingBox.maxX) * bounds.height)
//    case .portraitUpsideDown:
//        origin = CGPoint(x: (1 - boundingBox.maxX) * bounds.width,
//                         y: boundingBox.minY * bounds.height)
//    default:
//        origin = CGPoint(x: boundingBox.minX * bounds.width,
//                         y: (1 - boundingBox.maxY) * bounds.height)
//    }
//
//    return CGRect(origin: origin, size: size)
//}









