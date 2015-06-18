//
//  PulseEffect.swift
//  Music Paint
//
//  Created by Anna Dickinson on 6/13/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// Emit particles to the beat!

import UIKit

// Settings for this effect
final class PulseEffectState: SimulationStateType {
    var maxParticleEmissionRate: Scalar = 1000.0
    
    var baseForceFrequency: Scalar = 60.0
    var baseForceMagnitudeScale: Scalar = 3.0
    
    var spectrumDrivenForceMagnitudeScale: Scalar = 0.1
    convenience init(original: PulseEffectState) {
        self.init()
        self.maxParticleEmissionRate = original.maxParticleEmissionRate
        self.baseForceFrequency = original.baseForceFrequency
        self.baseForceMagnitudeScale = original.baseForceMagnitudeScale
    }
    
    // Unused
    var position: Position = VectorZero
    var scale: Scalar = 0
    var lifespan: Time = 0
    var velocity: Vector = VectorZero
}

class PulseEffect<S: SimulationStateType>: SimulationEntity<PulseEffectState, Emitter<EmitterState>> {
    let spriteBuffer: SpriteBuffer
    let bounds: CGRect
    let spectrumArrays: SpectrumArrays

    func start() {
        emitter.currentState.rate = 0.0
    }
    
    func stop() {
        emitter.currentState.rate = 0.0
    }

//    private var running = false
//
//    override func update(currentTime: Time, timestep: Time) {
//        if running {
//            super.update(currentTime, timestep: timestep)
//        }
//    }

    // This effect contains one emitter
    private let emitter: PulsingAreaEmitter<EmitterState>

    init(initialState: PulseEffectState, spriteBuffer: SpriteBuffer, bounds: CGRect, spectrumArrays: SpectrumArrays) {

        self.bounds = bounds
        self.spriteBuffer = spriteBuffer
        self.spectrumArrays = spectrumArrays
        self.emitter = PulsingAreaEmitter<EmitterState>(bounds: Rectangle(cgRect: bounds), spriteBuffer: spriteBuffer, currentTime: GlobalSimTime)

        super.init(initialState: initialState, currentTime: GlobalSimTime)

        createdEntities += [emitter]
        
        // Function used to update the emitter
        addCreatedEntityUpdateFunction(varyEmissionRate)
        
        // Function the emitter uses to update its particles
        emitter.addCreatedEntityUpdateFunction(fade)
    }
}

// Specific type of emitter this effect uses
private class PulsingAreaEmitter<S: SimulationStateType>: Emitter<EmitterState> {

    // Emit particles continuously
    private override func relativeAge(currentTime: Time) -> Time {
        return 0
    }
    
    // Emit to random position in this rectangle
    let bounds: Rectangle
    
    override func emitParticles(count: Int) -> [Particle<ParticleState>] {
        var newParticles: [Particle<ParticleState>] = []
        newParticles.reserveCapacity(count)
        for index in 0..<count {
            let newSprite = initialState.spriteBuffer.newSprite()
            let x = randomRange(bounds.origin.x, bounds.origin.x + bounds.width)
            let y = randomRange(bounds.origin.y, bounds.origin.y + bounds.height)
            let newParticle = particleGenerator(newSprite, Position.new(x, y))
            newParticles.append(newParticle)
        }
        return newParticles
    }
    
    init(bounds: Rectangle, spriteBuffer: SpriteBuffer, currentTime: Time) {
        self.bounds = bounds
        
        let initialState = EmitterState(
            // These aren't applicable for this type of emitter, but still need to set them
            position: VectorZero,
            scale: Scalar(0.0),
            lifespan: Scalar(0.0),
            velocity: VectorZero,

            // These are applicable
            rate: Scalar(0.0),
            spriteBuffer: spriteBuffer
        )
        
        // The function which will update our Particles
        let particleGenerator: Emitter.ParticleGeneratorFunction = {
            (sprite, position) in
            
            var initialParticleState = ParticleState(sprite: sprite)
            
            initialParticleState.position = position
            initialParticleState.velocity = VectorZero.randomizedValueByOffset(-1.0)
            initialParticleState.scale = Scalar(20.0).randomizedValueByProportion(1.0)
            initialParticleState.lifespan = Scalar(5.0).randomizedValueByProportion(0.5)
            initialParticleState.color = Color.new(Scalar(1.0), Scalar(1.0), Scalar(1.0), Scalar(0.75).randomizedValueByProportion(0.5))
            
            return Particle(initialState: initialParticleState, currentTime: GlobalSimTime)
        }

        super.init(initialState: initialState, particleGenerator: particleGenerator, currentTime: currentTime)
    }
}

// Update functions used by the effect
extension PulseEffect {
    func fade(particle: Particle<ParticleState>, currentTime: Time, timestep: Time) -> () {
        let r = particle.currentState.color.r
        let g = particle.currentState.color.g
        let b = particle.currentState.color.b
        
        let newColor = Color.new(r, g, b, 1.0 - particle.normalizedAge(currentTime))
        
        particle.currentState.color = newColor
    }

    func applySinusoidalForce(particle: Particle<ParticleState>, currentTime: Time, timestep: Time) -> () {
        let perParticleFrequency = currentState.baseForceFrequency + Scalar(particle.initialState.ID) % currentState.baseForceFrequency
        let forceVector = Vector.new(sin(currentTime * perParticleFrequency ), cos(currentTime * perParticleFrequency))
        particle.currentState.velocity = particle.currentState.velocity + forceVector * currentState.baseForceMagnitudeScale.randomizedValueByProportion(1.0)
    }
    
    func varyEmissionRate(emitter: Emitter<EmitterState>, currentTime: Time, timestep: Time) -> () {
        emitter.currentState.rate = min(spectrumArrays.maxMagnitude, currentState.maxParticleEmissionRate)
    }
}
