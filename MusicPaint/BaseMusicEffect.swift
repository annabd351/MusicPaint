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
    let particleTexture: UIImage

    func fillRect(rect: CGRect) {
        println(__FUNCTION__, "rect: \(rect)")
        let initialEmitterState = EmitterState(
            position: Position.new(rect.origin),
            scale: 0.0,
            lifespan: 0.0,
            velocity: VectorZero,
            
            rate: 0.0,
            
            particleTexture: particleTexture,
            spriteBuffer: spriteRenderingView.spriteBuffer
        )

        var offset = (x: Scalar(0), y: Scalar(0))

        let particleGenerator: Emitter.ParticleGeneratorFunction = {
            (sprite, position) in
            
//            offset.x = offset.x + 5.0
//            if offset.x > Scalar(rect.width) {
//                offset.x = offset.x % Scalar(rect.width)
//                offset.y = offset.y + 5.0
//                if offset.y > Scalar(rect.height) {
//                    offset.y = offset.y % Scalar(rect.height)
//                }
//            }

            var initialParticleState = ParticleState(sprite: sprite)
            
            let x = randomRange(Scalar(rect.origin.x), Scalar(rect.width))
            let y = randomRange(Scalar(rect.origin.y), Scalar(rect.height))

            initialParticleState.position = Position.new(x, y)
            initialParticleState.velocity = VectorZero.randomizedValueByOffset(-1.0)
            initialParticleState.scale = Scalar(20.0)
            initialParticleState.lifespan = Scalar(0.5).randomizedValueByProportion(0.5)
            initialParticleState.color = UIColor.whiteColor().simColor

            return Particle(initialState: initialParticleState, currentTime: GlobalSimTime)
        }
        
        var newEmitter = EternalEmitter<EmitterState>(initialState: initialEmitterState, particleGenerator: particleGenerator, currentTime: GlobalSimTime)

 //       newEmitter.addCreatedEntityUpdateFunction(applySpectrum)
        newEmitter.addCreatedEntityUpdateFunction(fade)
        
        createdEntities += [newEmitter]
        
        self.addCreatedEntityUpdateFunction(varyEmissionRate)
    }
    
    var spectrumArrays: SpectrumArrays?
    
    init(spriteRenderingView: SpriteRenderingView) {
        particleTexture = UIImage(named: "ParticleTexture")!
        
        super.init(initialState: AnySimulationState(), currentTime: GlobalSimTime)
        self.spriteRenderingView = spriteRenderingView
    }
}

private class EternalEmitter<S: SimulationStateType>: Emitter<EmitterState> {
    override func isAliveAtTime(currentTime: Time) -> Bool {
        return true
    }
    
    override init(initialState: EmitterState, particleGenerator: ParticleGeneratorFunction, currentTime: Time) {
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
//            let delay = currentTime - currentSpectrumArrays.timestamp
//            println("Delay: \(delay)")
            let newRate = Scalar(currentSpectrumArrays.maxMagnitude)
            emitter.currentState.rate = newRate
        }
    }
}
