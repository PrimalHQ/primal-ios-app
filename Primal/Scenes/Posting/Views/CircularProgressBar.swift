//
//  CircularProgressBar.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.2.24..
//

import UIKit
import QuartzCore

class CircularProgressView: UIView {
    private var progressLayer = CAShapeLayer()
    private var tracklayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureProgressViewToBeCircular()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    var progressColor: UIColor = .accent2 {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var trackColor: UIColor = .black.withAlphaComponent(0.7) {
        didSet {
            tracklayer.strokeColor = trackColor.cgColor
        }
    }
    
    var progress: CGFloat {
        get { progressLayer.strokeEnd }
        set { progressLayer.strokeEnd = newValue }
    }
    
    /**
     A path that consists of straight and curved line segments that you can render in your custom views.
     Meaning our CAShapeLayer will now be drawn on the screen with the path we have specified here
     */
    private var trackPath: CGPath? {
        UIBezierPath(
            arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0),
            radius: (frame.size.width - 4) / 2,
            startAngle: -0.5 * .pi,
            endAngle: 1.5 * .pi,
            clockwise: true
        ).cgPath
    }
    private var progressPath: CGPath? {
        return UIBezierPath(
            arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0),
            radius: (frame.size.width - 4) / 2,
            startAngle: -0.5 * .pi,
            endAngle: 1.5 * .pi,
            clockwise: true
        ).cgPath
    }
    
    private func configureProgressViewToBeCircular() {
        backgroundColor = UIColor.clear
//        layer.cornerRadius = frame.size.width / 2.0
        
        tracklayer.path = trackPath
        progressLayer.path = progressPath
        
        tracklayer.strokeColor = trackColor.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        
        tracklayer.lineWidth = 4
        progressLayer.lineWidth = 2
        
        tracklayer.strokeEnd = 1
        progressLayer.strokeEnd = 1
        
        tracklayer.fillColor = UIColor.clear.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        
        progressLayer.lineCap = .round
        
        layer.addSublayer(tracklayer)
        layer.addSublayer(progressLayer)
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        
        animation.fromValue = progressLayer.strokeEnd //start animation at old point
        animation.toValue = value //end animation at point specified
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLayer.strokeEnd = value
        progressLayer.add(animation, forKey: "animateCircle")
    }
}
