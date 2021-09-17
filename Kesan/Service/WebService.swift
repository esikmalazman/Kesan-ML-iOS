//
//  WebService.swift
//  SmartCamera
//
//  Created by Ikmal Azman on 16/09/2021.
//

import Foundation
import SafariServices

class WebService : UIViewController {

    let baseURL = "https://www.google.com/search?"
    
    func openSafari(for query : String) -> URL {
        
        let urlString = "\(baseURL)q=\(query)"
        print("URL : \(urlString)")
        guard let url = URL(string: urlString) else {
            fatalError("urlString given is not valid")
        }
        return url
    }
}
