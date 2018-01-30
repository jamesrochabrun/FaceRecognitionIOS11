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
    
    lazy var detectRectangleButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Detect Faces", for: .normal)
        b.backgroundColor = #colorLiteral(red: 0, green: 0.9269914031, blue: 0.6802368164, alpha: 1)
        b.addTarget(self, action: #selector(showRectangles), for: .touchUpInside)
        b.setTitleColor(.black, for: .normal)
        return b
    }()
    
    lazy var detectFaceDetailButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Detect Face Details", for: .normal)
        b.backgroundColor = #colorLiteral(red: 0, green: 0.9269914031, blue: 0.6802368164, alpha: 1)
        b.setTitleColor(.black, for: .normal)
        b.addTarget(self, action: #selector(showFaceDetails), for: .touchUpInside)
        return b
    }()
    
    let countLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()
    
    // MARK: - Use this method to display rectangles on top of faces
    @objc func showRectangles() {
        if detectedFaces?.count ?? 0 > 0 {
            detectedFaces?.forEach({$0.removeFromSuperview()})
            detectedFaces?.removeAll()
        } else {
            activityIndicatorView.startAnimating()
            detectFaces()
        }
    }
    
    // MARK: - Use this method to display details on faces
    
    @objc func showFaceDetails() {
        activityIndicatorView.startAnimating()
        let faceDetector = FaceDetector()
        faceDetector.delegate = self
        guard let image = self.photoImageView.image else { return }
        faceDetector.highlightFaces(for: image) { (resultImage) in
            self.photoImageView.image = resultImage
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    override func setUpViews() {
        
        addSubview(photoImageView)
        addSubview(detectRectangleButton)
        addSubview(detectFaceDetailButton)
        addSubview(activityIndicatorView)
        addSubview(countLabel)
        
        NSLayoutConstraint.activate([
            
            photoImageView.leftAnchor.constraint(equalTo: leftAnchor),
            photoImageView.topAnchor.constraint(equalTo: topAnchor),
            photoImageView.rightAnchor.constraint(equalTo: rightAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            detectRectangleButton.widthAnchor.constraint(equalToConstant: self.frame.width),
            detectRectangleButton.heightAnchor.constraint(equalToConstant: 44),
            detectRectangleButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            detectRectangleButton.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            
            detectFaceDetailButton.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            detectFaceDetailButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            detectFaceDetailButton.widthAnchor.constraint(equalToConstant: self.frame.width),
            detectFaceDetailButton.heightAnchor.constraint(equalToConstant: 44),
            
            countLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            countLabel.bottomAnchor.constraint(equalTo: detectFaceDetailButton.topAnchor, constant: -40),
            countLabel.widthAnchor.constraint(equalToConstant: self.frame.width)
            ])

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        countLabel.text = nil
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
                self.handleUIFor(faceObservation: faceObservation)
            })
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
    func handleUIFor(faceObservation: VNFaceObservation) {
        
        DispatchQueue.main.async {
            /*!
             @brief The bounding box of the detected object. The coordinates are normalized to the dimensions of the processed image, with the origin at the image's lower-left corner.
             */
            let boundingBox = faceObservation.boundingBox
            let faceBox = self.createAnimatedBoxForFace(with: self.viewModel!.photoImage(), and: boundingBox)
            self.addSubview(faceBox)
            self.detectedFaces?.append(faceBox)
        }
    }
}

extension PageCell: FaceDetectorDelegate {
    func facesDetected(_ faces: Int) {
        self.countLabel.text = "Detailed Faces detected = \(faces)"
    }
}










