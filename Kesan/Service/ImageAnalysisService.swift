//
//  ImageAnalysisService.swift
//  Machines
//
//  Created by Ikmal Azman on 17/09/2021.
//
//  Real-time image processing, https://anuragajwani.medium.com/how-to-process-images-real-time-from-the-ios-camera-9c416c531749

import UIKit
import Vision


//class ImageAnalysisService {
//    func loadMLModelFrom() -> VNCoreMLModel {
//        // Load ML Model to project
//        guard let model = try? VNCoreMLModel(for: MLModel(contentsOf: Inceptionv3.urlOfModelInThisBundle)) else {
//            fatalError("Unable to load ML model")
//
//        }
//        return model
//    }
    
    //MARK:- TODO : Refactoring In Progress
//    func requestImageAnalysis(from model : VNCoreMLModel, completion : @escaping (()->Void) ) {
//        // Make a image analysis request to process result from image to Vision
//        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
//            // Class handle classification after model been processed
//            guard let results = request.results as? [VNClassificationObservation] else {
//                fatalError("Model failed to proces request")
//            }
//            // Get the first result from array of object classification
//            guard let firstResult = results.first else {
//                fatalError("Could not get the first results")
//            }
//
//            completion()
//
//            let confidence = firstResult.confidence * 100
//
//            if confidence > 65 {
//                print(firstResult.identifier, firstResult.confidence)
//                // Stop camera when get results
//                self?.captureSession.stopRunning()
//
//                DispatchQueue.main.async { [weak self] in
//                    // Send results to bottom sheet
//                    self?.delegate?.didSendImageAnalysisResults(self!, results: firstResult)
//                    self?.view.hideToastActivity()
//                }
//
//            } else {
//                print(firstResult.identifier, firstResult.confidence)
//            }
//        }
//    }
    
//    func processImage(at image: CIImage, with request : VNRequest) {
//
//        // Object process image analysis from request
//        let requestHandler = VNImageRequestHandler(ciImage: image)
//
//        do {
//            // Scheduled vision request to be perform
//            try requestHandler.perform([request])
//
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//    func recognizeImage(from image : CIImage) {
//
//        // Make a image analysis request to process result from image to Vision
//        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
//            // Class handle classification after model been processed
//            guard let results = request.results as? [VNClassificationObservation] else {
//                fatalError("Model failed to proces request")
//            }
//            // Get the first result from array of object classification
//            guard let firstResult = results.first else {
//                fatalError("Could not get the first results")
//            }
//
//            let confidence = firstResult.confidence * 100
//
//            if confidence > 65 {
//                print(firstResult.identifier, firstResult.confidence)
//                // Stop camera when get results
//                self?.captureSession.stopRunning()
//
//                DispatchQueue.main.async { [weak self] in
//                    // Send results to bottom sheet
//                    self?.delegate?.didSendImageAnalysisResults(self!, results: firstResult)
//                    self?.view.hideToastActivity()
//                }
//
//            } else {
//                print(firstResult.identifier, firstResult.confidence)
//            }
//        }
//
//        processImage(at: image, with: request)
//
//    }
//}
