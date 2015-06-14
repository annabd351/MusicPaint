//
//  Geometry.swift
//  UI
//
//  Copyright (c) 2015 Big Cartel. All rights reserved.
//

// TODO:  Definitely need tests for these...

import UIKit

func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(lhs.x * rhs, lhs.y * rhs)
}

func *(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(lhs.x * rhs.x, lhs.y * rhs.y)
}

func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(lhs.x + rhs.x, lhs.y + rhs.y)
}

func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(lhs.x - rhs.x, lhs.y - rhs.y)
}

func +=(inout lhs: CGPoint, rhs: CGPoint) {
    lhs = lhs + rhs
}


func *(lhs: CGVector, rhs: CGFloat) -> CGVector {
    return CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
}

func *(lhs: CGVector, rhs: CGVector) -> CGVector {
    return CGVector(dx: lhs.dx * rhs.dx, dy: lhs.dy * rhs.dy)
}

func +(lhs: CGVector, rhs: CGVector) -> CGVector {
    return CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
}

func -(lhs: CGVector, rhs: CGVector) -> CGVector {
    return CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
}

func +=(inout lhs: CGVector, rhs: CGVector) {
    lhs = lhs + rhs
}

extension CGRect {
    var aspectRatio: CGFloat? {
        if self.height == 0 {
            return nil
        }
        return self.width/self.height
    }

    var center: CGPoint {
        return CGPoint(x: origin.x + (size.width/2), y: origin.y + (size.height/2))
    }
    
    var farCorner: CGPoint {
        return CGPoint(self.origin.x + self.width, self.origin.y + self.height)
    }
    
    func inset(distance: CGFloat) -> CGRect {
        return CGRectInset(self, distance, distance)
    }

    func normalizedToRect(rect: CGRect) -> CGRect {
        let scaleX = 1/rect.width
        let scaleY = 1/rect.height
        return CGRect(self.origin.x * scaleX, self.origin.y * scaleY, self.width * scaleX, self.height * scaleY)
    }
    
    // Useful function to remember...
    // AVMakeRectWithAspectRatioInsideRect
}

public func ==(lhs: CGRect, rhs: CGRect) -> Bool {
    return (lhs.origin.x == rhs.origin.x) &&
        (lhs.origin.y == rhs.origin.y) &&
        (lhs.size.width == rhs.size.width) &&
        (lhs.size.height == lhs.size.height)
}

extension CGRect: Hashable {
    public var hashValue: Int {
        let sum = Int(origin.x + origin.y + size.width + size.height)
        return sum.hashValue
    }
}

// Syntactic sugar for initializers
extension CGSize {
    init(_ width: CGFloat, _ height: CGFloat) {
        self.width = width;
        self.height = height;
    }
}

extension CGRect {
    init(_ origin: CGPoint, _ size: CGSize) {
        self.origin = origin;
        self.size = size;
    }
    
    init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        self.origin = CGPoint(x: x, y: y)
        self.size = CGSize(width: width, height: height)
    }
}

extension CGPoint {
    init(_ x: CGFloat, _ y: CGFloat) {
        self.x = x
        self.y = y
    }
}

extension CGVector {
    init(_ dx: CGFloat, _ dy: CGFloat) {
        self.dx = dx
        self.dy = dy
    }
}
