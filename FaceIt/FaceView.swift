//
//  FaceView.swift
//  FaceIt
//
//  Created by DevStuff on 2016-09-20.
//  Copyright © 2016 DevStuff. All rights reserved.
//

import UIKit

// @IBDesignable allows what is on the view to be shown in the main storyboard
@IBDesignable
class FaceView: UIView {

    // @IBInspectable allows the variable below it to be seen in the attributed inspector 
    // while in main.storyboard
    // With one caveat you have to explicitly type them, it won't work by relying on Swift's
    // Type inference
    @IBInspectable
    var scale : CGFloat = 0.90 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var mouthCurvature: Double = 1.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var eyesOpen: Bool = true { didSet { setNeedsDisplay() } }
    @IBInspectable
    var eyeBrowTilt: Double = 0.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var color: UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() } }
    @IBInspectable
    var lineWidth:CGFloat = 5.0 { didSet { setNeedsDisplay() } }

    
    // This is the pinch handler we are using in FaceViewController 
    func changeScale(recognizer: UIPinchGestureRecognizer){
        switch recognizer.state{
        case .Changed, .Ended:
            scale *= recognizer.scale
            // The reason for this next line of code is if we don't do this 
            // we will keep getting the cumulative scale
            // This way get get the incremental scale 
            
            recognizer.scale = 1.0
            
            
        default:
            break
        }
    }
    
    
    // Computed property
    // Since we are just returning the value, i.e no set 
    // We can just return without the get structure
    private var skullRadius: CGFloat{
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    private var skullCenter: CGPoint{
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private struct Ratios {
        static let SkullRadiusToEyeOffset: CGFloat  = 3
        static let SkullRadiusToEyeRadius: CGFloat = 10
        static let SkullRadiusToMouthWidth: CGFloat = 1
        static let SkullRadiusToMouthHeight: CGFloat = 3
        static let SkullRadiusToMouthOffset: CGFloat = 3
        static let SkullRadiusToBrowOffset: CGFloat = 5
    }
    
    private enum Eye{
        case Left
        case Right
    }
    
    private func pathForCircleCenteredAtPoint(midPoint: CGPoint, withRadius: CGFloat) -> UIBezierPath{
        let path = UIBezierPath(arcCenter: midPoint,
                                radius: withRadius,
                                startAngle: 0,
                                endAngle: CGFloat(2 * M_PI),
                                clockwise: false
        )
        path.lineWidth = lineWidth
        return path
    }
    
    
    private func getEyeCenter(eye: Eye) -> CGPoint{
        let eyeOffset = skullRadius / Ratios.SkullRadiusToEyeOffset
        var eyeCenter = skullCenter
        eyeCenter.y -= eyeOffset
        switch eye{
        case .Left: eyeCenter.x -= eyeOffset
        case .Right: eyeCenter.x += eyeOffset
        }
        return eyeCenter
    }
    
    private func pathForEye(eye: Eye) -> UIBezierPath{
        let eyeRadius = skullRadius / Ratios.SkullRadiusToEyeRadius
        let eyeCenter = getEyeCenter(eye)
        if eyesOpen  {
            return pathForCircleCenteredAtPoint(eyeCenter, withRadius: eyeRadius)
        } else {
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: eyeCenter.x - eyeRadius, y: eyeCenter.y))
            path.addLineToPoint(CGPoint(x: eyeCenter.x + eyeRadius, y: eyeCenter.y))
            path.lineWidth = lineWidth
            return path
        }
    }
    
    private func pathForMouth() -> UIBezierPath{
        let mouthWidth = skullRadius / Ratios.SkullRadiusToMouthWidth
        let mouthHeight = skullRadius / Ratios.SkullRadiusToMouthHeight
        let mouthOffset = skullRadius / Ratios.SkullRadiusToMouthOffset
        
        // Start point of mouth is top left, end pointi s top right
        let mouthRect = CGRect(x: skullCenter.x - mouthWidth/2, y: skullCenter.y + mouthOffset, width: mouthWidth, height: mouthHeight)
        
        let smileOffset = CGFloat(max(-1, min(mouthCurvature, 1))) * mouthRect.height
        let start = CGPoint(x: mouthRect.minX, y: mouthRect.minY)
        let end = CGPoint(x: mouthRect.maxX, y: mouthRect.minY)
        let cp1 = CGPoint(x: mouthRect.minX + mouthRect.width / 3, y: mouthRect.minY + smileOffset)
        let cp2 = CGPoint(x: mouthRect.maxX - mouthRect.width / 3, y: mouthRect.minY + smileOffset)
        
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addCurveToPoint(end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        return path
    }
    
    
    private func pathForBrow(eye: Eye) -> UIBezierPath
    {
        var tilt = eyeBrowTilt
        switch  eye {
        case .Left: tilt *= -1.0
        case .Right: break
        }
        
        var browCenter = getEyeCenter(eye)
        browCenter.y -= skullRadius / Ratios.SkullRadiusToBrowOffset
        let eyeRadius = skullRadius / Ratios.SkullRadiusToEyeRadius
        let tiltOffset = CGFloat(max(-1, min(tilt,1))) * eyeRadius / 2
        let browStart = CGPoint(x: browCenter.x - eyeRadius, y: browCenter.y - tiltOffset)
        let browEnd = CGPoint(x: browCenter.x + eyeRadius, y: browCenter.y + tiltOffset)
        let path = UIBezierPath()
        path.moveToPoint(browStart)
        path.addLineToPoint(browEnd)
        path.lineWidth = lineWidth
        return path
    }
    
    
    // If all you have are subviews then don't use this function 
    // as it is fairly resourse intensive
    // Only use this function when needed
    override func drawRect(rect: CGRect)
    {
        // We need some numbers for the width and heigh of our face 
        // But we need to determine which view / window we are using 
        // We could looks at the parameter rect, this would not work because 
        // rect is just an optimization just sawing what part 
        // of the view to draw, covered earlier in Lect 4
        // Would frame.size.width work ? 
        // Nope because the frame describles the view's location in the superview
        // So if we used this we would be using an incorrect coordinate system
        // we need to draw in our own coordinate system not the superview's coordinate system
        // So we use bounds.size.width this is the rectange that we will be drawing in 
        // and therefore this is the correct coordinate system to draw in
        // Initially skullRadius and SkullCenter were here but because they will be used a lot 
        // they were moved outside of this function.
        // But this created a problem, because after these were moved outside this function
        // they were in the initialization phase so we can't get the bounds value.
        // The solution is to make them computed properties
        // var skullRadius = min(bounds.size.width, bounds.size.height)/2
        
        // We can get the center of the superview via the 'center' variable but to convert 
        // that to the center in our coordinate sytem, we have two ways
        // 1) var bla = convertPoint(center, fromView: superview) this converts the 
        // center of the superview to our local coordinate system
        // 2) use CGPoint(x: bounds.midX, y: bounds.midY)
        //var skullCenter = CGPoint(x: bounds.midX, y: bounds.midY)
 
        // Later in the lecture this was all changed so it's commented out
        // let skull = UIBezierPath(arcCenter: skullCenter, radius: skullRadius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: false)
        // skull.lineWidth = 5.0
        // UIColor.blueColor().set()
        // skull.stroke()

        color.set()
        pathForCircleCenteredAtPoint(skullCenter, withRadius: skullRadius).stroke()
        pathForEye(.Left).stroke()
        pathForEye(.Right).stroke()
        pathForMouth().stroke()
        pathForBrow(.Left).stroke()
        pathForBrow(.Right).stroke()
        
        // If we run this right now we won't see anthing on screen
        // In Main.storyboard select the FaceViewController right click
        // the top left button to see all the outlets, the only there should be Outlets -> view. 
        // This is the way to add our view in code. But this will be done via storyboard
        // search for View in the object library
        // drag the view onto the FaceViewController to the top left corner then drag lower right 
        // corner to the bottom right of the FaceViewController, this will use the blue guiding lines
        // This is not enough. we need to have constraints go to the lower right, ie beside wAny hAny 
        // and select the right most icon, it looks like a tie fighter with a triange body called 
        // Resolve Auto Layout Issues and select Reset To Suggested Constraints
        // We can see all the constraints by selecting the view then  the size inspector will have a 
        // Constraints section it does this by following the blue suggestion lines
        // This allows the view to be resized when we go from Portrait to Landscape modes
        // But there is an issue this is just a normal view we need to set it to our FaceView 
        // How do we do this ?
        // Select the view
        // Goto the identity inspector 
        // Custom Class -> Class -> <Select FaceView> 
        // So here is an example of the class controlling the view
        // But there is an issue, we can draw the circle in portrait mode
        // but when we switch to landscape it will stretch it to look like an oval
        // To fix this we choose the Face View in FaceViewController, select the Attributes Inspector -> View -> Mode -> <Select Redraw>
    }
 

}
