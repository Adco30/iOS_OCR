//
//  ViewController.swift
//  OCR
//
//  Created by Adco30 on 1/7/23.
//

import UIKit
import Vision
 
 
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = true
        textView.layer.borderWidth = 2
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolBar.setItems([flexSpace, doneButton], animated: false)
        textView.inputAccessoryView = toolBar
        
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create perspective cropper button and add it to the view
        let perspectiveCropperButton = UIButton()
        perspectiveCropperButton.setTitle("Perspective Cropper", for: .normal)
        view.addSubview(perspectiveCropperButton)
        
        // Create normal cropper button and add it to the view
        let normalCropperButton = UIButton()
        normalCropperButton.setTitle("Normal Cropper", for: .normal)
        view.addSubview(normalCropperButton)
        
        // Add image view to scroll view and set scroll view properties
        scrollView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.delegate = self
        
        // Add scroll view, buttons, and text view to the main view
        view.addSubview(scrollView)
        view.addSubview(selectImageButton)
        view.addSubview(resetButton)
        view.addSubview(textView)
        
        // Recognize text in the image and configure the buttons
        recognizeText(image: imageView.image)
        configureBlueButton(button: selectImageButton)
        configureRedButton(button: resetButton)
        
        // Set target actions for the buttons
        selectImageButton.addTarget(self, action: #selector(selectImageButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
        // Set frames and appearance for the buttons
        let buttonWidth = selectImageButton.frame.size.width
        let buttonHeight = selectImageButton.frame.size.height
        selectImageButton.frame = CGRect(x: 10, y: textView.frame.maxY, width: buttonWidth, height: buttonHeight)
        resetButton.frame = CGRect(x: selectImageButton.frame.maxX + 10, y: textView.frame.maxY, width: buttonWidth, height: buttonHeight)
        selectImageButton.layer.cornerRadius = 5
        resetButton.layer.cornerRadius = 5
        selectImageButton.clipsToBounds = true
        resetButton.clipsToBounds = true

    }
 
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
 
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func resetButtonTapped() {
        // Reset the root view controller of the key window to a new instance of ViewController
        if #available(iOS 13.0, *) {
            let windows = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .map { $0 as? UIWindowScene }
                .compactMap { $0 }
                .first?.windows
                .filter { $0.isKeyWindow }
                .first
            windows?.rootViewController = ViewController()
        } else {
            UIApplication.shared.keyWindow?.rootViewController = ViewController()
        }
    }
    
    @objc func selectImageButtonTapped() {
        // Display an action sheet to allow the user to take a photo or choose an image from the photo library
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
 
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage (named: "sample")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
 
    private let scrollView = UIScrollView()
 
    private let selectImageButton: UIButton = {
        let selectImageButton = UIButton()
        selectImageButton.setTitle("SELECT IMAGE", for: .normal)
        return selectImageButton
    }()
    
    private let resetButton: UIButton = {
        let resetButton = UIButton()
        resetButton.setTitle("RESET", for: .normal)
        return resetButton
    }()
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // This function is called when the user selects an image from the photo library or takes a photo
        
        // Get the selected image
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Update the image view with the selected image
            imageView.image = selectedImage
            // Call the recognizeText function to update the recognized text
            recognizeText(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let screenWidth = view.frame.size.width
        let screenHeight = view.frame.size.height
 
        let scrollViewWidth = screenWidth
        let scrollViewHeight = screenHeight * 0.35
        scrollView.frame = CGRect(x: 0, y: 0, width: scrollViewWidth, height: scrollViewHeight)
        scrollView.contentSize = imageView.image?.size ?? .zero
        
        imageView.frame = CGRect (x: 20, y: view.safeAreaInsets.top,
                                  width: view.frame.size.width-40, height: view.frame.size.height/3)
        imageView.layer.masksToBounds = true
        
        textView.frame = CGRect(x: 20, y: imageView.frame.maxY,
                                width: view.frame.size.width-40, height: view.frame.size.height/3)
        textView.layer.borderColor = UIColor.label.cgColor
        textView.layer.borderWidth = 0.2
        textView.layer.cornerRadius = 10
        textView.clipsToBounds = true
        selectImageButton.sizeToFit()
        
        let buttonWidth = selectImageButton.frame.size.width + 20
        let buttonHeight = selectImageButton.frame.size.height + 20
        let buttonsX = (screenWidth - buttonWidth*2 - 20) / 2
        let buttonsY = screenHeight - buttonHeight - 20
        
        selectImageButton.frame = CGRect(x: buttonsX, y: buttonsY, width: buttonWidth, height: buttonHeight)
        resetButton.frame = CGRect(x: selectImageButton.frame.maxX + 20, y: buttonsY, width: buttonWidth, height: buttonHeight)
    }
    
    func recognizeText(image: UIImage?) {
        // This function uses the Apple Vision framework to recognize text in the given image and updates the text view with the recognized text
        
        guard let cgImage = image?.cgImage else { return }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                return
            }
            let text = observations.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: "\n")
            DispatchQueue.main.async {
                self.textView.text = text
            }
        }
        
        do { try handler.perform([request]) } catch { print(error) }
    }
    
    func configureBlueButton(button: UIButton){
        button.setTitleColor(.white, for: .normal)
        button.isHidden = false
        button.alpha = 1
        button.backgroundColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        button.titleLabel?.font = UIFont(name: "San Francisco", size: 14)
        button.sizeToFit()
    }
    
    func configureRedButton(button: UIButton) {
        button.setTitleColor(.white, for: .normal)
        button.isHidden = false
        button.alpha = 1
        button.backgroundColor = UIColor(red: 0.5, green: 0, blue: 0, alpha: 1)
        button.titleLabel?.font = UIFont(name: "San Francisco", size: 14)
        button.sizeToFit()
    }
    
}
