//
//  BottomSheet.swift
//  SmartCamera
//
//  Created by Ikmal Azman on 16/09/2021.
//

import UIKit
import Vision
import SafariServices
import FloatingPanel

protocol RealTimeSheetDelegate : AnyObject {
    func didRefreshRealTimeCapture(_ view : RealTimeImageSheetVC)
}

final class RealTimeImageSheetVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak private var objectPlaceholder: UILabel!
    @IBOutlet weak private var confidencePlacholder: UILabel!
    @IBOutlet weak private var objectLabel: UILabel!
    @IBOutlet weak private var confidenceLevelLabel: UILabel!
    @IBOutlet weak private var learnButton: UIButton!
    @IBOutlet weak private var refreshButton: UIButton!
    
    //MARK:- Variables
    weak var delegate : RealTimeSheetDelegate?
    
    private let webService = WebService()

    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDefaultLabel()
        renderView()
        toggleLabelState(isEnable: false, isHidden: true)
    }

    //MARK:- Action
    @IBAction func learnButtonPressed(_ sender: UIButton) {
        configureWebService()
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        toggleLabelState(isEnable: false, isHidden: true)
        configureDefaultLabel()
        delegate?.didRefreshRealTimeCapture(self)
    }
}

//MARK:- Real Time Delegate
extension RealTimeImageSheetVC : RealTimeImageDelegate {
    func didSendImageAnalysisResults(_ view: RealTimeImageVC, results: VNClassificationObservation) {
        
        DispatchQueue.main.async { [weak self] in
            self?.toggleLabelState(isEnable: true, isHidden: false)
            self?.objectLabel.text = results.identifier
            self?.confidenceLevelLabel.text = "\(ceil(results.confidence * 100))%"
        }
    }
}

//MARK:- Private Methods
extension RealTimeImageSheetVC {
    
    private func configureDefaultLabel() {
        confidenceLevelLabel.text = "Analysing Image"
        objectLabel.text = ""
    }
    private func configureWebService() {
        let urlForWebService = webService.openSafari(for: objectLabel.text?.filter({ !$0.isWhitespace}) ?? "")
        let safariVC = SFSafariViewController(url: urlForWebService)
        present(safariVC, animated: true, completion: nil)
    }
    private func renderView() {
        view.backgroundColor = .lightOrange
        refreshButton.setImage(UIImage(systemName: "arrow.clockwise.circle")!, for: .normal)
        
        refreshButton.tintColor = .primaryOrange
        objectPlaceholder.textColor = .secondaryOrange
        confidencePlacholder.textColor = .secondaryOrange
        objectLabel.textColor = .primaryOrange
        confidenceLevelLabel.textColor = .primaryOrange
        
    }
    private func toggleLabelState(isEnable : Bool, isHidden : Bool){
        
        objectPlaceholder.isHidden = isHidden
        confidencePlacholder.isHidden = isHidden
        
        learnButton.isHidden = isHidden
        
        refreshButton.isEnabled = isEnable
        learnButton.isEnabled = isEnable
        refreshButton.isEnabled = isEnable
    }
}



