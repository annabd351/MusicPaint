//
//  WiggleEffect.swift
//  Music Paint
//
//  Created by Anna Dickinson on 6/3/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

import UIKit

class WiggleEffect<S: SimulationStateType>:  SimulationEntity<AnySimulationState, Emitter<EmitterState>> {
    var spriteRenderingView: SpriteRenderingView!
    let particleTexture: UIImage
    
    var frequency: Scalar = 2.0
    
    func addEmitterAtPosition(position: Position) {
        let initialEmitterState = EmitterState(
            position: position,
            scale: 0.0,
            lifespan: 0.25,
            velocity: VectorZero.randomizedValueByOffset(50.0),
            
            rate: 1.0,
            
            particleTexture: particleTexture,
            spriteBuffer: spriteRenderingView.spriteBuffer
        )
        
        let particleGenerator: Emitter.ParticleGeneratorFunction = {
            (sprite, position) in
            
            let direction = Vector.new(sin(GlobalSimTime * self.frequency), cos(GlobalSimTime * self.frequency))
            
            var initialParticleState = ParticleState(sprite: sprite)
            initialParticleState.position = position
            initialParticleState.scale = Scalar(50.0).randomizedValueByProportion(0.5)
            initialParticleState.lifespan = Scalar(10.0).randomizedValueByProportion(0.5)
            initialParticleState.velocity = direction * Scalar(20.0).randomizedValueByProportion(0.5)
            initialParticleState.color = UIColor.whiteColor().simColor
            
            return Particle(initialState: initialParticleState, currentTime: GlobalSimTime)
        }
        
        var newEmitter = Emitter<EmitterState>(initialState: initialEmitterState, particleGenerator: particleGenerator, currentTime: GlobalSimTime)
        
        newEmitter.addCreatedEntityUpdateFunction(applySinusoidalForce)
        newEmitter.addCreatedEntityUpdateFunction(shrink)
        newEmitter.addCreatedEntityUpdateFunction(fade)
        
        createdEntities += [newEmitter]
    }
    
    init(spriteRenderingView: SpriteRenderingView) {
        particleTexture = UIImage(named: "ParticleTexture")!
    
        super.init(initialState: AnySimulationState(), currentTime: GlobalSimTime)
        self.spriteRenderingView = spriteRenderingView
    }
}

extension WiggleEffect {
    func applySinusoidalForce(particle: Particle<ParticleState>, currentTime: Time, timestep: Time) -> () {
        let forceVector = Vector.new(sin(currentTime * frequency * 3), cos(currentTime * frequency * 3))
        
        particle.currentState.velocity = particle.currentState.velocity + forceVector * 3
    }
    
    func fade(particle: Particle<ParticleState>, currentTime: Time, timestep: Time) -> () {
        let r = particle.currentState.color.r
        let g = particle.currentState.color.g
        let b = particle.currentState.color.b
        
        let newColor = Color.new(r, g, b, 1.0 - particle.normalizedAge(currentTime))
        
        particle.currentState.color = newColor
        
    }
    
    func shrink(particle: Particle<ParticleState>, currentTime: Time, timestep: Time) -> () {
        particle.currentState.scale = particle.currentState.scale * (1.0 - particle.normalizedAge(currentTime)/2.0)
    }
}
