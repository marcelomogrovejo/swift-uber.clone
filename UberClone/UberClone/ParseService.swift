//
//  ParseService.swift
//  TinderClone
//
//  Created by Marcelo Mogrovejo on 4/5/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import Foundation
import Parse

class ParseService {
    
    func initParse() {
        
        let parseConfig = ParseClientConfiguration { (ParseMutableClientConfiguration) -> Void in
            
            ParseMutableClientConfiguration.applicationId = "6a74b5c6458d2a8f67006f10e39ec5a46ea36a5f"
            ParseMutableClientConfiguration.clientKey = "c9b8b52e4fb204797b20b55730c31af6224a64a8"
            ParseMutableClientConfiguration.server = "http://ec2-52-39-149-158.us-west-2.compute.amazonaws.com:80/parse"
        
        }

        Parse.initialize(with: parseConfig)
        
    }
    
    func signUp(user: PFUser) -> () {
        
//      var onSuccess: Bool = false
//      var onError: NSError = NSError(domain: "", code: 1000, userInfo: nil)
        
        user.signUpInBackground(block: { (success, error) in

//            if error != nil {
//                //TODO: create alert or red message
//                //TODO: error handler
//                
//                onError = error! as NSError
//                
//            } else {
//                
//                // User added
//                onSuccess = success
//                
//            }
//            
//            return (onSuccess, onError)
            
        })

        
        
    }
    
}
