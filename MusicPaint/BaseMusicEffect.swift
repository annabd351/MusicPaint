//
//  BaseMusicEffect.swift
//  Music Paint
//
//  Created by Anna Dickinson on 6/13/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

import UIKit

class BaseMusicEffect<S: SimulationStateType>: SimulationEntity<AnySimulationState, Emitter<EmitterState>> {
 
    var spriteRenderingView: SpriteRenderingView!
    
    func fillRect(rect: CGRect) {
       
        let initialEmitterState = EmitterState(
            position: Position.new(rect.origin),
            scale: 0.0,
            lifespan: 0.0,
            velocity: VectorZero,
            rate: 0.0,
            spriteBuffer: spriteRenderingView.spriteBuffer
        )

        let emitter: PulsingAreaEmitter<EmitterState>
        let particleGenerator: Emitter.ParticleGeneratorFunction = {
            (sprite, position) in

            var initialParticleState = ParticleState(sprite: sprite)

            initialParticleState.position = position
            initialParticleState.velocity = VectorZero.randomizedValueByOffset(-1.0)
            initialParticleState.scale = Scalar(20.0)
            initialParticleState.lifespan = 1.0
            initialParticleState.color = UIColor.whiteColor().simColor

            return Particle(initialState: initialParticleState, currentTime: GlobalSimTime)
        }
        
        var newEmitter = PulsingAreaEmitter<EmitterState>(initialState: initialEmitterState, particleGenerator: particleGenerator, currentTime: GlobalSimTime, area: Rectangle(cgRect: rect))

        newEmitter.addCreatedEntityUpdateFunction(fade)
        
        createdEntities += [newEmitter]
        
        self.addCreatedEntityUpdateFunction(varyEmissionRate)
    }
    
    var spectrumArrays: SpectrumArrays?
    
    init(spriteRenderingView: SpriteRenderingView) {
        super.init(initialState: AnySimulationState(), currentTime: GlobalSimTime)
        self.spriteRenderingView = spriteRenderingView
    }
}

private class PulsingAreaEmitter<S: SimulationStateType>: Emitter<EmitterState> {
    // Emit particles continuously
    override func isAliveAtTime(currentTime: Time) -> Bool {
        return true
    }

    // Emit to random position with this rectangle
    let area: Rectangle
    
    override func emitParticles(count: Int) -> [Particle<ParticleState>] {
        var newParticles: [Particle<ParticleState>] = []
        newParticles.reserveCapacity(count)
        for index in 0..<count {
            let newSprite = initialState.spriteBuffer.newSprite()
            let x = randomRange(area.origin.x, area.origin.x + area.width)
            let y = randomRange(area.origin.y, area.origin.y + area.height)
            let newParticle = particleGenerator(newSprite, Position.new(x, y))
            newParticles.append(newParticle)
        }
        return newParticles
    }
    
    init(initialState: EmitterState, particleGenerator: ParticleGeneratorFunction, currentTime: Time, area: Rectangle) {
        self.area = area
        super.init(initialState: initialState, particleGenerator: particleGenerator, currentTime: currentTime)
    }
}

extension BaseMusicEffect {
    func fade(particle: Particle<ParticleState>, currentTime: Time, timestep: Time) -> () {
        let r = particle.currentState.color.r
        let g = particle.currentState.color.g
        let b = particle.currentState.color.b
        
        let newColor = Color.new(r, g, b, 1.0 - particle.normalizedAge(currentTime))
        
        particle.currentState.color = newColor
        
    }
    
    func applySpectrum(particle: Particle<ParticleState>, currentTime: Time, timestep: Time) -> () {
        if let currentSpectrumArrays = spectrumArrays where currentSpectrumArrays.maxMagnitude > 0 {
            let frequency: Scalar
            if particle.initialState.ID % 2 == 0 {
                frequency = currentSpectrumArrays.left[particle.initialState.ID % currentSpectrumArrays.left.count]
            }
            else {
                frequency = currentSpectrumArrays.right[particle.initialState.ID % currentSpectrumArrays.right.count]
            }
            
            let normalizedFrequency = frequency/Scalar(currentSpectrumArrays.maxMagnitude)
            if normalizedFrequency > 0.5 {
                particle.currentState.scale = particle.initialState.scale * (1.0 + normalizedFrequency)
            }
        }
    }
    
    func varyEmissionRate(emitter: Emitter<EmitterState>, currentTime: Time, timestep: Time) -> () {
        if let currentSpectrumArrays = spectrumArrays {
            let delay = CACurrentMediaTime() - currentSpectrumArrays.timestamp
            let newRate = Scalar(currentSpectrumArrays.maxMagnitude)
            emitter.currentState.rate = newRate
        }
    }
}
