//
//  Emitter.swift
//
//  Created by Anna Dickinson on 5/25/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// An emitter is a SimulationEntity which contains Particles and methods for modifying and creating them.

import UIKit

class Emitter<T: SimulationStateType>: SimulationEntity<EmitterState, Particle<ParticleState>> {
    
    // The calls this function to create a new Particle
    typealias ParticleGeneratorFunction = (UnsafeMutablePointer<Sprite>, Position) -> Particle<ParticleState>
    let particleGenerator: ParticleGeneratorFunction
    
    override func update(currentTime: Time, timestep: Time) {
        // Update existing particles
        super.update(currentTime, timestep: timestep)
        
        // Emit new particles until this Emitter's lifepsan has expired
        if self.relativeAge(currentTime) <= self.initialState.lifespan {
            createdEntities += emitParticles(neededParticles(currentTime, timestep: timestep))
        }
    }
    
    func emitParticles(count: Int) -> [Particle<ParticleState>] {
        var newParticles: [Particle<ParticleState>] = []
        newParticles.reserveCapacity(count)
        for index in 0..<count {
            let newSprite = initialState.spriteBuffer.newSprite()
            let newParticle = particleGenerator(newSprite, currentState.position)
            newParticles.append(newParticle)
        }
        return newParticles
    }
    
    func neededParticles(currentTime: Time, timestep: Time) -> Int {
        return Int(self.currentState.rate * timestep)
    }

    // An Emitter is alive as long as it contains Particles.  Note that it
    // only creates *new* particles during its lifespan;  in other words, even
    // after it stops creating Particles, it still needs to update them until
    // they die.
    override func isAliveAtTime(currentTime: Time) -> Bool {
        if createdEntities.count > 0 {
            return true
        }
        else {
            return super.isAliveAtTime(currentTime)
        }
    }
    
    init(initialState: EmitterState, particleGenerator: ParticleGeneratorFunction, currentTime: Time) {
        self.particleGenerator = particleGenerator
        super.init(initialState: initialState, currentTime: currentTime)
    }
}

struct EmitterState: SimulationStateType {
    var position: Position
    var scale: Scalar
    var lifespan: Scalar
    var velocity: Vector

    // Rate at which new particles are created
    var rate: Scalar

    // Sprites used to render particles
    let spriteBuffer: SpriteBuffer
    
    init(position: Position, scale: Scalar, lifespan: Scalar, velocity: Vector, rate: Scalar, spriteBuffer: SpriteBuffer) {
        self.position = position
        self.scale = scale
        self.lifespan = lifespan
        self.velocity = velocity
        self.rate = rate
        self.spriteBuffer = spriteBuffer
    }
    
    init(original: EmitterState) {
        self.position = original.position
        self.scale = original.scale
        self.lifespan = original.lifespan
        self.velocity = original.velocity
        self.rate = original.rate
        self.spriteBuffer = original.spriteBuffer
    }
}

