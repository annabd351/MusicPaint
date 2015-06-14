//
//  ParameterTypes.swift
//  SwiftDataStructures
//
//  Created by Anna Dickinson on 5/26/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

import Foundation
import GLKit

// Alias types used by the simulation to types used in rendering
typealias Scalar = GLfloat
typealias Vector = GLKVector2
typealias Color = GLKVector4

typealias Time = Scalar
typealias Position = Vector
typealias Size = Vector

// "Constructors" for bridged, immutable GLK types
extension Vector {
    static func new(x: GLfloat, _ y: GLfloat) -> Vector {
        return GLKVector2Make(x, y)
    }
}

extension Color {
    static func new(r: GLfloat, _ g: GLfloat, _ b: GLfloat, _ a: GLfloat) -> Color {
        return GLKVector4Make(r, g, b, a)
    }
}

// Map operators to GLK functions
func *(lhs: Vector, rhs: Scalar) -> Vector {
    return GLKVector2MultiplyScalar(lhs, rhs)
}

func +(lhs: Vector, rhs: Vector) -> Vector {
    return GLKVector2Add(lhs, rhs)
}

func +(lhs: Vector, rhs: Scalar) -> Vector {
    let x = lhs.x + rhs
    let y = lhs.y + rhs
    return Vector.new(x, y)
}

func <(lhs: Time, rhs: Time) -> Bool {
    return lhs < rhs
}


extension Time: Equatable {
    
}
    
// Map sim types to CG types
extension Vector {
    static func new(x: CGFloat, y: CGFloat) -> Vector {
        return GLKVector2Make(GLfloat(x), GLfloat(y))
    }
}

extension Color {
    static func new(r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> Color {
        return GLKVector4Make(GLfloat(r), GLfloat(g), GLfloat(b), GLfloat(a))
    }
}

extension Position {
    static func new(point: CGPoint) -> Position {
        return GLKVector2Make(GLfloat(point.x), GLfloat(point.y));
    }
}

extension CGPoint {
    func normalizedToRect(rect: CGRect) -> CGPoint {
        let x = (self.x - rect.origin.x)/rect.width
        let y = (self.y - rect.origin.y)/rect.height
        
        return CGPoint(x, y)
    }
}

// UIKit convenience methods
extension UIColor {
    var simColor: Color {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0.0, 0.0, 0.0, 0.0)
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return Color.new(r, g, b, a)
    }
}

// Constants
let VectorZero = Vector.new(GLfloat(0.0), GLfloat(0.0))

