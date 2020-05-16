//
//  ViewController.swift
//  MLTestor
//
//  Created by toureek on 5/14/20.
//  Copyright © 2020 com.toureek.ml.test. All rights reserved.
//

import UIKit
import CoreML
import Vision
import ImageIO

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    static let width = UIScreen.main.bounds.size.width - 60
    static let height = UIScreen.main.bounds.size.height/3.0
    
    var classificationLabel: UILabel?
    var galleryButton: UIButton?
    var imageView: UIImageView?
    
    /// - Tag: MLModelSetup
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: MLMuskedTest_1().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        addGalleryButtonOnScreen()
    }

    func addGalleryButtonOnScreen() {
        if galleryButton == nil {
            galleryButton = UIButton.init(type: .custom)
            galleryButton?.setTitle("Open Gallery", for: .normal)
            galleryButton?.setTitleColor(.blue, for: .normal)
            galleryButton?.layer.borderColor = UIColor.blue.cgColor
            galleryButton?.layer.borderWidth = 1.0
            galleryButton?.addTarget(self, action: #selector(didOpenGalleryButtonClicked), for: .touchUpInside)
            self.view.addSubview(galleryButton!)
            
            galleryButton?.frame = CGRect.init(x: 30, y: ViewController.height, width: ViewController.width, height: 30)
        }
    }
    
    func addImageViewOnScreen(_ image: UIImage) {
        if imageView == nil {
            imageView = UIImageView()
            imageView?.contentMode = .scaleAspectFit
            self.view.addSubview(imageView!)
            
            imageView?.isUserInteractionEnabled = true
            let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didImageViewTapped))
            imageView?.addGestureRecognizer(tapGesture)
            imageView?.frame = CGRect.init(x: 30, y: ViewController.height+50, width: ViewController.width, height: ViewController.height)
        }
        imageView?.image = nil
        imageView?.image = image
    }
    
    func updateToTheLatestCheckingResult(_ image: UIImage) {
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))!
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    
    /// Updates the UI with the results of the classification.
    /// - Tag: ProcessClassifications
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.classificationLabel?.text = "KO........"
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
        
            if classifications.isEmpty {
                self.classificationLabel?.text = "Nothing recognized."
            } else {
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(2)
                let descriptions = topClassifications.map { classification in
                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                   return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }
                
                if self.classificationLabel == nil {
                    self.classificationLabel = UILabel()
                    self.classificationLabel?.textColor = .red
                    self.classificationLabel?.lineBreakMode = .byWordWrapping
                    self.classificationLabel?.numberOfLines = 0
                    self.classificationLabel?.font = UIFont.systemFont(ofSize: 18)
                    self.classificationLabel?.sizeToFit()
                    self.view.addSubview(self.classificationLabel!)
                    self.classificationLabel?.frame = CGRect.init(x: 30, y: ViewController.height-80, width: ViewController.width, height: 60)
                }
                self.classificationLabel?.text = "Classification Result:\n" + descriptions.joined(separator: "\n")
            }
        }
    }
    
    @objc func didOpenGalleryButtonClicked() {
        showAlertViewController()
    }
    
    @objc func didImageViewTapped() {
        print("Image Tapped")
    }
    
    func showAlertViewController() {
        let alertViewController = UIAlertController(title: "选取图片", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        alertViewController.addAction(UIAlertAction(title: "从相册选择", style: UIAlertAction.Style.default, handler: { (alert) in
            self.selectImageFromGallery()
        }))
        alertViewController.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: { (alert) in
            
        }))
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    func selectImageFromGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.modalPresentationStyle = .fullScreen
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            UIView.animate(withDuration: 0.35, animations: {
                picker.dismiss(animated: true, completion: nil)
            }) { (flag) in
                if flag {
                    self.addImageViewOnScreen(image)
                    if #available(iOS 12.0, *) {
                        self.updateToTheLatestCheckingResult(image)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        }
    }
    
}

