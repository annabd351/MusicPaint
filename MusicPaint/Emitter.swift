//
//  Emitter.swift
//
//  Created by Anna Dickinson on 5/25/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

import UIKit

// An emitter is a SimulationEntity which contains Particles and methods for modifying and creating them
class Emitter<T: SimulationStateType>: SimulationEntity<EmitterState, Particle<ParticleState>> {
    
    // Particle creation
    typealias ParticleGeneratorFunction = (UnsafeMutablePointer<Sprite>, Position) -> Particle<ParticleState>
    let particleGenerator: ParticleGeneratorFunction

    override func update(currentTime: Time, timestep: Time) {
        super.update(currentTime, timestep: timestep)

        // Stop emitting new particles if this emitter is past its lifespan
        if self.isAliveAtTime(currentTime) {
            
//            let neededParticles = Int(max(self.currentState.rate * timestep, 1.0))
            let neededParticles = Int(self.currentState.rate * timestep)
            
            var newParticles: [Particle<ParticleState>] = []
            newParticles.reserveCapacity(neededParticles)
            for index in 0..<neededParticles {
                let newSprite = initialState.spriteBuffer.newSprite()
                let newParticle = particleGenerator(newSprite, currentState.position)
                newParticles.append(newParticle)
            }
            
            // Merge results
            createdEntities += newParticles
        }
        
    }
    
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

    // All particles will be rendered with this texture
    let particleTexture: UIImage
    
    // Associated renderable sprites
    let spriteBuffer: SpriteBuffer
    
}

