//
//  TestParse.swift
//  TinderClone
//
//  Created by Marcelo Mogrovejo on 4/5/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import Foundation
import Parse

class TestParse {
    
    func addObjectTest() {
        
        let tempObj = PFObject(className: "TestObject")
        tempObj["name"] = "Temporal object test"
        tempObj.saveInBackground { (success, error) in
            
            if error != nil {
                print("there was a problem saving an object")
            } else {
                print("tempObj saved successfully")
            }
        }
        
    }
    
}
