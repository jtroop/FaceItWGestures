//
//  ViewController.swift
//  FaceIt
//
//  Created by DevStuff on 2016-09-20.
//  Copyright © 2016 DevStuff. All rights reserved.
//

import UIKit

class FaceViewController: UIViewController {
    
    // Create a link to the FacialExpression model
    // This is the model for this particular MVC
    // If the model changes we need to update our view
    // How do we do that ?
    // Remember back to the didSet stuff, this will come in very handy
    // Since this is a struct this will be called, if FaceExpression was a class
    // this wouldn't be called
    
    // There is an issue here durring the initialization of FacialExpression didSet will NOT be called
    // Only called if you set it after initializaton
    // Remember in swift to use something it has to be fully initialized
    // FacialExpression was called but it was called durring the initialization phase so 
    // didSet -> updateUI wan't called 
    // The way we deal with this is, have a look at our IBOutlet faceView
    // When the faceView outlet is set by the system we will then call didSet()
    var expression = FacialExpression(eyes: .Closed, eyeBrows: .Relaxed, mouth: .Smirk) {
        didSet {
            updateUI()
        }
    }
    
    //  These dictionaries are essentially creating a mapping between the model and the view
    private var mouthCurvatures = [FacialExpression.Mouth.Frown: -1.0,
                           .Grin: 0.5,
                           .Smile: 1.0,
                           .Smirk: -0.5,
                           .Neutral: 0.0]
    
    private var eyeBrowTilts = [FacialExpression.EyeBrows.Relaxed: 0.5,
                                .Furrowed: -0.5,
                                .Normal: 0.0]
                                
    
    // We now need a pointer to our faceview
    // How do we make a pointer to something in our view?
    // Remember back to the earliest parts of the course 
    // We just use the good ole control drag from the storyboard into this class
    
    // With this we now have a pointer to this view so we can now changes aspects of it
    // updateUI is called when the system  is wiring up this IBOutlet 
    // this only happen on initialization all of the other times didSet() will be called 
    // when FacialExpression is set, and thereby activating the didSet -> updateUI() method
    // We are updating the UI when our model is hooked up, i.e here and when then model 
    // changes ie view FacialExpression -> didSet -> updateUI()
    //
    // Regarding recognizing gestures 
    // We need to start with adding a Recognizer, so we put it here
    //
    // NOTE: We added the recognizers in code but there is a way to add them va the story board
    // Have both story board and the view contoller on screen 
    // In the object library scroll all the way to the bottom and 
    // you should see recognizers
    // Drag the recognizer to the desired view, you should see the recognizer in the top toolbar 
    // in the story board
    // If you select the Tap Gesture Recognizer in the top toolbar you can view and configure it 
    // in the attributes inspector
    // You can then control drag it into the code as seen below, see toggleEyes
    
    
    
    @IBOutlet weak var faceView: FaceView! {
        didSet{
            // Explanation of what is going on here
            // Since we are not changing the model at all we can deal with this in the faceview , ie gesture handler
            // We are going to need a new public method called changeScale that takes a parameter so it will handle
            // a pinch gesture
            //
            
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: faceView,
                action: #selector(FaceView.changeScale(_:))
                ))
            
            // Because this swipe is going to change the model we use ourself as the target
            // The controller has to handle this
            // We don't need any arguments because the gesture is going to be recognized or not
            let happierSwipeGestureRecognizer = UISwipeGestureRecognizer(
                target: self,
                action: #selector(FaceViewController.increaseHappiness)
            )
            
            // To configure the swipe recognizer
            happierSwipeGestureRecognizer.direction = .Up
            faceView.addGestureRecognizer(happierSwipeGestureRecognizer)
            
            let sadderSwipeGestureRecognizer = UISwipeGestureRecognizer(
                target: self,
                action: #selector(FaceViewController.decreaseHappiness)
            )
            
            // To configure the swipe recognizer
            sadderSwipeGestureRecognizer.direction = .Down
            faceView.addGestureRecognizer(sadderSwipeGestureRecognizer)
            
            
            updateUI()
        }
    }
    
    // This gesture recognizer was implemented via the storyboard and control drag 
    // and all that fun stuff
    @IBAction func toggleEyes(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .Ended {
            switch expression.eyes{
            case .Open: expression.eyes = .Closed
            case .Closed: expression.eyes = .Open
            case .Squinting: break
            }
        }
    
    }
    
    
    
    func increaseHappiness(){
        // Notice that when we change the expression we are changing the UI
        // ie the var expression at the top of the file dummy
        expression.mouth = expression.mouth.happierMouth()
    }
    
    func decreaseHappiness(){
        // Same idea as increaseHappiness
        expression.mouth = expression.mouth.sadderMouth()
    }
    
    private func updateUI(){
        switch expression.eyes{
        case .Open: faceView.eyesOpen = true
        case .Closed: faceView.eyesOpen = false
        case .Squinting: faceView.eyesOpen = false
        }
        // We have now matched up our model with our view
        faceView.mouthCurvature = mouthCurvatures[expression.mouth] ?? 0.0
        faceView.eyeBrowTilt = eyeBrowTilts[expression.eyeBrows] ?? 0.0
    }
    
    
}

