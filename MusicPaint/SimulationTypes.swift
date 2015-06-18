//
//  SimulationTypes.swift
//  Music Paint
//
//  Created by Anna Dickinson on 5/26/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// Map abstract simulation types to concrete implementation types.

import Foundation
import GLKit

// Alias types used by the simulation to types used in rendering
typealias Scalar = GLfloat
typealias Vector = GLKVector2
typealias Color = GLKVector4

typealias Time = Scalar
typealias Position = Vector
typealias Size = Vector

struct Rectangle {
    let origin: Position
    let width: Scalar
    let height: Scalar
}

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

// Other operators

func +(lhs: Vector, rhs: Scalar) -> Vector {
    let x = lhs.x + rhs
    let y = lhs.y + rhs
    return Vector.new(x, y)
}

// Conform Time to Equable protocol
extension Time: Equatable { }

func <(lhs: Time, rhs: Time) -> Bool {
    return lhs < rhs
}


// Map sim types to UIKit types

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

extension Rectangle {
    init(cgRect: CGRect) {
        origin = Position.new(cgRect.origin)
        width = Scalar(cgRect.height)
        height = Scalar(cgRect.height)
    }
}

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
