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
        // Update existing particles
        super.update(currentTime, timestep: timestep)
        
        // Emit new particles
        if self.isAliveAtTime(currentTime) {
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
}

