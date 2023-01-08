# iOS_OCR
OCR App

This is an iOS app that uses the Vision framework to perform optical character recognition (OCR) on images. The recognized text is displayed in a text view and can be edited by the user.


Features

Select an image from the camera or photo library
Crop the image using either a normal cropper or a perspective cropper
Recognize text in the image using the Vision framework
Edit the recognized text in a text view
Reset the app to its initial state

Requirements

Xcode 12 or later
iOS 13 or later


Implementation

To use the Vision framework to recognize text in an image, follow these steps:

Add the Vision framework to your project.
Create a VNImageRequestHandler with the image you want to recognize text in.
Create a VNRecognizeTextRequest and implement the completion handler.
In the completion handler, get the recognized text observations and extract the top candidates for each observation.
Join the strings of the top candidates and display the recognized text.


Open Source
This app is open source and available on GitHub. You can clone or download the repository to build and run the app on your own device.
