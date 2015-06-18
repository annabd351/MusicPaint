//
//  SwirlEffect.swift
//  Music Paint
//
//  Created by Anna Dickinson on 6/13/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// Emit swirly particles which dance to the beat!

import UIKit

// Settings for this effect
final class SwirlEffectState: SimulationStateType {
    // (determined via trial and error)

    var maxEmissionRate: Scalar = 500
    
    var swirlForceFrequency: Scalar = 12
    var swirlForceScale: Scalar = 2

    var eraseColor: Color = UIColor.whiteColor().simColor
    var eraseProbability = 0.01
    
    convenience init(original: SwirlEffectState) {
        self.init()
        self.maxEmissionRate = original.maxEmissionRate
        self.swirlForceFrequency = original.swirlForceFrequency
        self.swirlForceScale = original.swirlForceScale
        self.eraseColor = original.eraseColor
        self.eraseProbability = original.eraseProbability
    }
    
    // Unused
    var position: Position = VectorZero
    var scale: Scalar = 0
    var lifespan: Time = 0
    var velocity: Vector = VectorZero
}

// The function which creates each particle
private func createParticle(sprite: UnsafeMutablePointer<Sprite>, position: Position) -> Particle<ParticleState> {
    var initialParticleState = ParticleState(sprite: sprite)
    
    initialParticleState.position = position
    initialParticleState.velocity = VectorZero.randomizedValueByOffset(-1.0)
    initialParticleState.scale = Scalar(15.0).randomizedValueByProportion(1.0)
    initialParticleState.lifespan = Scalar(15.0).randomizedValueByProportion(0.5)
    initialParticleState.color = Color.new(Scalar(1.0), Scalar(1.0), Scalar(1.0), Scalar(0.15).randomizedValueByProportion(0.5))
    
    return Particle(initialState: initialParticleState, currentTime: GlobalSimTime)
}

// Specific type of emitter this effect uses
private class AreaEmitter<S: SimulationStateType>: Emitter<EmitterState> {
    
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
        
        super.init(initialState: initialState, particleGenerator: createParticle, currentTime: currentTime)
    }
}

class SwirlEffect<S: SimulationStateType>: SimulationEntity<SwirlEffectState, Emitter<EmitterState>> {
    let spriteBuffer: SpriteBuffer
    let bounds: CGRect
    let spectrumArrays: SpectrumArrays

    func start() {
        currentState.maxEmissionRate = initialState.maxEmissionRate
    }
    
    func stop() {
        currentState.maxEmissionRate = 0
    }

    // This effect contains one emitter
    private let emitter: AreaEmitter<EmitterState>

    init(initialState: SwirlEffectState, spriteBuffer: SpriteBuffer, bounds: CGRect, spectrumArrays: SpectrumArrays) {

        self.bounds = bounds
        self.spriteBuffer = spriteBuffer
        self.spectrumArrays = spectrumArrays
        self.emitter = AreaEmitter<EmitterState>(bounds: Rectangle(cgRect: bounds), spriteBuffer: spriteBuffer, currentTime: GlobalSimTime)

        super.init(initialState: initialState, currentTime: GlobalSimTime)

        createdEntities += [emitter]
        
        // Function used to update the emitter
        addCreatedEntityUpdateFunction(varyEmissionRate)
        
        // Functions the emitter uses to update its particles
        emitter.addCreatedEntityUpdateFunction(fade)
        emitter.addCreatedEntityUpdateFunction(shrink)
        emitter.addCreatedEntityUpdateFunction(erase)
        emitter.addCreatedEntityUpdateFunction(applyForce)
    }
}

// Update functions used by the effect
extension SwirlEffect {
    func fade(particle: Particle<ParticleState>, currentTime: Time, timestep: Time) -> () {
        let r = particle.currentState.color.r
        let g = particle.currentState.color.g
        let b = particle.currentState.color.b
        
        let newColor = Color.new(r, g, b, (1.0 - particle.normalizedAge(currentTime)) * particle.initialState.color.a)
        
        particle.currentState.color = newColor
    }

    func applyForce(particle: Particle<ParticleState>, currentTime: Time, timestep: Time) -> () {
        let rotatingForce = Vector.new(sin(currentState.swirlForceFrequency * currentTime), cos(currentState.swirlForceFrequency * currentTime))
        
        let forceVector = rotatingForce
        particle.currentState.velocity = particle.currentState.velocity + forceVector * Scalar(log(spectrumArrays.maxMagnitude)) * currentState.swirlForceScale
    }
    
    func erase(particle: Particle<ParticleState>, currentTime: Time, timestep: Time) -> () {
        let randomVal = Double(random())/Double(RAND_MAX)
        if randomVal < currentState.eraseProbability {
            particle.currentState.color = currentState.eraseColor
            particle.currentState.scale = particle.initialState.scale.randomizedValueByProportion(0.5)
        }
    }
    
    func shrink(particle: Particle<ParticleState>, currentTime: Time, timestep: Time) -> () {
        particle.currentState.scale = particle.initialState.scale * (1.0 - particle.normalizedAge(currentTime))
    }

    func varyEmissionRate(emitter: Emitter<EmitterState>, currentTime: Time, timestep: Time) -> () {
        let emissionRate = Scalar(pow(spectrumArrays.avgMagnitude, 3))
        emitter.currentState.rate = max(min(emissionRate, currentState.maxEmissionRate), 0)
    }
}

