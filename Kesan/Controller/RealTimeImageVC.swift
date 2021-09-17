//
//  ViewController.swift
//  SmartCamera
//
//  Created by Ikmal Azman on 15/09/2021.
//


import UIKit
import AVKit
import Vision
import FloatingPanel
import Toast

protocol RealTimeImageDelegate : AnyObject {
    func didSendImageAnalysisResults(_ view : RealTimeImageVC, results : VNClassificationObservation)
}

final class RealTimeImageVC: UIViewController {
    
    //MARK:- Variable
    // Allow to manage capture activity and coordinate flow data from input device to capture outputs
    private let captureSession = AVCaptureSession()
    // Capture output that record video, provide access to video frames, get feed images fro processing
    private let videoOutput = AVCaptureVideoDataOutput()
    // Display camera preview, that display video as it capture, CALayer datatype
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private let surfaceAppearance = SurfaceAppearance()
    
    weak var delegate : RealTimeImageDelegate?
    
    private var bottomSheet : RealTimeImageSheetVC {
        get {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let bottomSheet = storyBoard.instantiateViewController(identifier: "bottomSheet") as! RealTimeImageSheetVC
            // Current vc delegate
            self.delegate = bottomSheet
            // Bottom sheet delegate
            bottomSheet.delegate = self
            return bottomSheet
        }
    }
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // configureBottomCard()
        configureCameraInput()
        configureCameraLayer(for : captureSession)
        configureVideoOutput()
        // Start the flow data from input to output
        captureSession.startRunning()
        
        renderView()
    }
    //MARK:- ML Methods
    func recognizeImage(from image : CIImage) {
        // Load ML Model to project
        guard let model = try? VNCoreMLModel(for: MLModel(contentsOf: Inceptionv3.urlOfModelInThisBundle)) else {
            fatalError("Unable to load ML model")
        }
        // Make a image analysis request to process result from image to Vision
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            // Class handle classification after model been processed
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to proces request")
            }
            // Get the first result from array of object classification
            guard let firstResult = results.first else {
                fatalError("Could not get the first results")
            }

            let confidence = firstResult.confidence * 100

            if confidence > 65 {
                print(firstResult.identifier, firstResult.confidence)
                // Stop camera when get results
                self?.captureSession.stopRunning()

                DispatchQueue.main.async { [weak self] in
                    // Send results to bottom sheet
                    self?.delegate?.didSendImageAnalysisResults(self!, results: firstResult)
                    self?.view.hideToastActivity()
                }

            } else {
                print(firstResult.identifier, firstResult.confidence)
            }
        }

        processImage(at: image, with: request)

    }

    func processImage(at image: CIImage, with request : VNRequest) {

        // Object process image analysis from request
        let requestHandler = VNImageRequestHandler(ciImage: image)

        do {
            // Scheduled vision request to be perform
            try requestHandler.perform([request])

        } catch {
            print(error.localizedDescription)
        }
    }
}

//MARK:- Video Output Delegate

// Method receive sample buffer and monitor status of video data
extension RealTimeImageVC : AVCaptureVideoDataOutputSampleBufferDelegate {
    // Notifies delegate new video frame receive
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // Make sure the sample contains image
        guard let cvImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            fatalError("Unable to get image from sample buffer")
        }
        // Convert buffer output to CIImage
        let ciImage = CIImage(cvImageBuffer: cvImageBuffer)
        recognizeImage(from: ciImage)
     
        
        //print("New image received")
    }
}

//MARK:- Floating Panet Delegate & Layout
extension RealTimeImageVC : FloatingPanelControllerDelegate, FloatingPanelLayout {

    var position: FloatingPanelPosition {
        .bottom
    }

    var initialState: FloatingPanelState {
        .half
    }

    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
        return   [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.5, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 20.0, edge: .bottom, referenceGuide: .safeArea)
        ]
    }
    
}

//MARK:- Sheet Delegate
extension RealTimeImageVC : RealTimeSheetDelegate {
    func didRefreshRealTimeCapture(_ view: RealTimeImageSheetVC) {
        // Start run the capture session once refresh button selected
        captureSession.startRunning()
        self.view.makeToastActivity(.center)
    }
}

//MARK:- Private Methods
extension RealTimeImageVC {
    
    private func configureCameraInput() {
        // Configure capture device for real-time capture, find default video device
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            fatalError("Can't find video as default in a device")
        }
        // Allow to provides media from capture input to capture device
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            fatalError("Could not find specify video input")
        }
        // Add input to current session
        captureSession.addInput(videoInput)
    }
    
    private func configureCameraLayer(for captureSession : AVCaptureSession) {
        // Connect preview layer with capture session
        previewLayer.session = captureSession
        // Allow to indicate how layer display video content, as default is size aspectFit which is not full screen
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // Allow to set the sizr frame of the preview layer
        previewLayer.frame = view.frame
        // Add preview layer to current view
        view.layer.addSublayer(previewLayer)
    }
    
    private func configureVideoOutput() {
        // Send camera feed to  handler
        // Set sample buffer delegate and queue to be invoked on background thread, and  send the camera feed image to current vc
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Image processing"))
        // Add output to capture session, to receive camera feed
        captureSession.addOutput(videoOutput)
    }
    
    private func renderView() {
        let fpc = FloatingPanelController()
        fpc.set(contentViewController: bottomSheet)
        fpc.addPanel(toParent: self)
        fpc.delegate = self
        fpc.layout = self
        
        surfaceAppearance.cornerRadius = 15
        fpc.surfaceView.appearance = surfaceAppearance
        fpc.surfaceView.containerMargins  = .init(top: 0, left: 0, bottom: 0, right: 0)
        
        self.view.makeToastActivity(.center)
    }
}
