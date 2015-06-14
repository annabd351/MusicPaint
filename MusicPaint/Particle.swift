//
//  Particle.swift
//
//  Created by Anna Dickinson on 5/26/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

import UIKit
import GLKit

// A particle is a SimulationEntity with a Color
class Particle<S: SimulationStateType>: SimulationEntity<ParticleState, AnySimulationEntity>  {
    override init(initialState: ParticleState, currentTime: Time) {
        super.init(initialState: initialState, currentTime: currentTime)
    }    
}

// Particle state references memory in a Sprite
struct ParticleState: SimulationStateType {
    let sprite: UnsafeMutablePointer<Sprite>
    
    // Particle properties are stored in the sprite so they
    // don't have to be copied on each render cycle
    var position: Position {
        get { return sprite.memory.position }
        set { sprite.memory.position = newValue }
    }
    
    var scale: Scalar {
        get { return sprite.memory.scale }
        set { sprite.memory.scale = newValue }
    }
    
    var lifespan: Time {
        get { return sprite.memory.lifespan }
        set { sprite.memory.lifespan = newValue }
    }
    
    private (set) var age: Time {
        get { return sprite.memory.age }
        set { sprite.memory.age = newValue }
    }
    
    var color: Color {
        get { return sprite.memory.color }
        set { sprite.memory.color = newValue }
    }

    var velocity: Vector = Vector.new(Scalar(0), Scalar(0))

    static var TotalCount = 0
    
    var ID: Int {
        return ParticleState.TotalCount++
    }
    
    init(sprite: UnsafeMutablePointer<Sprite>) {
        self.sprite = sprite
    }
}
