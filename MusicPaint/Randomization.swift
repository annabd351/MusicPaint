//
//  Randomization.swift
//  Music Paint
//
//  Created by Anna Dickinson on 5/25/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

import Foundation

protocol Randomizable {
    func randomizedValueByProportion(proportion: Scalar) -> Self
    func randomizedValueByOffset(offset: Scalar) -> Self
}

func fit01(start: Scalar, end: Scalar, value: Scalar) -> Scalar {
    return start + ((end-start) * value)
}

func setRandomSeed(seed: UInt32) {
    srandom(seed)
}

func randomRange(min: Scalar, max: Scalar) -> Scalar {
    let randomVal = Scalar(random())/Scalar(RAND_MAX)
    return fit01(min, max, randomVal)
}

func randomVariationByProportion(base: Scalar, proportion: Scalar) -> Scalar {
    return base + randomRange(-(base * proportion), (base * proportion))
}

func randomVariationByOffset(base: Scalar, offset: Scalar) -> Scalar {
    return base + randomRange(base - offset, base + offset)
}

extension Scalar: Randomizable {
    func randomizedValueByProportion(proportion: Scalar) -> Scalar {
        return randomVariationByProportion(self, proportion)
    }

    func randomizedValueByOffset(offset: Scalar) -> Scalar {
        return randomVariationByOffset(self, offset)
    }
}

extension Vector: Randomizable {
    func randomizedValueByProportion(proportion: Scalar) -> Vector {
        let x = randomVariationByProportion(self.x, proportion)
        let y = randomVariationByProportion(self.y, proportion)
        return Position.new(x, y)
    }

    func randomizedValueByOffset(offset: Scalar) -> Vector {
        let x = randomVariationByOffset(self.x, offset)
        let y = randomVariationByOffset(self.y, offset)
        return Position.new(x, y)
    }
}

extension Color: Randomizable {
    func randomizedValueByProportion(proportion: Scalar) -> Color {
        let r = randomVariationByProportion(self.r, proportion)
        let g = randomVariationByProportion(self.g, proportion)
        let b = randomVariationByProportion(self.g, proportion)
        let a = Scalar(1.0)
        return Color.new(r, g, b, a)
    }
    
    func randomizedValueByOffset(offset: Scalar) -> Color {
        let r = randomVariationByOffset(self.r, offset)
        let g = randomVariationByOffset(self.g, offset)
        let b = randomVariationByOffset(self.g, offset)
        let a = Scalar(1.0)
        return Color.new(r, g, b, a)
    }
}
