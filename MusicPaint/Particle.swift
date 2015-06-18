//
//  Particle.swift
//
//  Created by Anna Dickinson on 5/26/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// A particle is a SimulationEntity which can be rendered as a Sprite.  It has no child entities.

import UIKit
import GLKit

class Particle<S: SimulationStateType>: SimulationEntity<ParticleState, AnySimulationEntity>  {
    override init(initialState: ParticleState, currentTime: Time) {
        super.init(initialState: initialState, currentTime: currentTime)
    }    
}

struct ParticleState: SimulationStateType {

    // Each particle has a unique ID
    var ID: Int {
        return ParticleState.TotalCount++
    }

    // Total number of particles (with this type of state) created by the system
    static var TotalCount = 0

    // Direct reference to the Sprite used to render this Particle
    let sprite: UnsafeMutablePointer<Sprite>

    // Particle properties are stored in the Sprite so they
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

    init(sprite: UnsafeMutablePointer<Sprite>) {
        self.sprite = sprite
    }
    
    init(original: ParticleState) {
        self.sprite = original.sprite
        self.velocity = original.velocity
    }
}
