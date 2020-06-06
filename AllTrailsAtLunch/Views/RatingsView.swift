//
//  RatingsView.swift
//  AllTrailsAtLunch
//
//  Created by Evelyn C Cordner on 6/3/20.
//  Copyright © 2020 EvelynCordner. All rights reserved.
//

import UIKit

class RatingsView: UIView {
    
    let imgFilledStar = #imageLiteral(resourceName: "Filled Star")
    let imgHalfStar = #imageLiteral(resourceName: "Half Star")
    let imgEmptyStar = #imageLiteral(resourceName: "Empty Star")
    var rating:CGFloat = 0.0
    var totalStars = 5

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(UIColor.systemBackground.cgColor)
        context!.fill(rect)
        
        let availWidth = rect.size.width
        let cellWidth = availWidth / CGFloat(totalStars)
        let starSize = (cellWidth <= rect.size.height) ? cellWidth : rect.size.height
        
        for index in 0...totalStars {
            let value = cellWidth * CGFloat(index) + cellWidth / 2
            let center = CGPoint(x: value+1, y: rect.size.height/2)
            let frame = CGRect(x: center.x - starSize / 2, y: center.y - starSize / 2, width: starSize, height: starSize)
            
            let highlighted = (Float(index + 1) <= ceilf(Float(self.rating)))
            
            if highlighted && (CGFloat(index+1) > CGFloat(self.rating)) {
                drawHalfStar(with: frame)
            } else {
                drawStar(with: frame, highlighted: highlighted)
            }
        }
    }
}

private extension RatingsView {
    
    func drawStar(with frame:CGRect, highlighted: Bool) {
        let image = highlighted ? imgFilledStar : imgEmptyStar
        draw(with: image, and: frame)
    }
    
    func drawHalfStar(with frame:CGRect) {
        draw(with: imgHalfStar, and: frame)
    }
    
    func draw(with image:UIImage, and frame:CGRect) {
        image.draw(in: frame)
    }
}
