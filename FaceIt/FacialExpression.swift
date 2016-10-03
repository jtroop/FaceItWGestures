//
//  FacialExpression.swift
//  FaceIt
//
//  Created by DevStuff on 2016-09-28.
//  Copyright © 2016 DevStuff. All rights reserved.
//

import Foundation

// This is the model class of our FaceViewController
// In a sense this is the UI - independent representation of our face
// this class keeps track of the state of all variable components on our face
// Also think of this as the data store of our FaceViewController and via that controller
// we will be chaning our FaceView

// This model has to be interpreted by the controller for the view
// For example the controller has to determine what a Furrowed eye brow 
// means and then how to tell the view do draw that 



struct FacialExpression
{
    enum Eyes: Int {
        case Open
        case Closed
        case Squinting
    }
    
    enum EyeBrows: Int {
        case Relaxed
        case Normal
        case Furrowed
        
        func moreRelaxedBrow() -> EyeBrows {
            return EyeBrows(rawValue: rawValue - 1) ?? .Relaxed
        }
        
        func moreFurrowedBrow() -> EyeBrows {
            return EyeBrows(rawValue: rawValue + 1) ?? .Furrowed
        }
    }
    
    enum Mouth: Int {
        case Frown
        case Smirk
        case Neutral
        case Grin
        case Smile
        
        func sadderMouth() -> Mouth{
            return Mouth(rawValue: rawValue - 1) ?? .Frown
        }
        
        func happierMouth() -> Mouth {
            return Mouth(rawValue: rawValue + 1) ?? .Smile
        }
    }
    
    var eyes: Eyes
    var eyeBrows: EyeBrows
    var mouth : Mouth
}
