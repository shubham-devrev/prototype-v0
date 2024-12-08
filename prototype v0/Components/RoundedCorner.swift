//
//  RoundedCorner.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 08/12/24.
//

// Add this shape for custom corner radius
import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var bottomLeadingRadius: CGFloat = .infinity
    var bottomTrailingRadius: CGFloat = .infinity
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let tl = CGPoint(x: rect.minX, y: rect.minY)
        let tr = CGPoint(x: rect.maxX, y: rect.minY)
        let bl = CGPoint(x: rect.minX, y: rect.maxY)
        let br = CGPoint(x: rect.maxX, y: rect.maxY)
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addArc(tangent1End: tl, tangent2End: bl, radius: radius)
        path.addArc(tangent1End: bl, tangent2End: br, radius: bottomLeadingRadius)
        path.addArc(tangent1End: br, tangent2End: tr, radius: bottomTrailingRadius)
        path.addArc(tangent1End: tr, tangent2End: tl, radius: radius)
        
        return path
    }
}
