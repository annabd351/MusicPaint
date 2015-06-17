//
//  Effect.swift
//  SwiftDataStructures
//
//  Created by Anna Dickinson on 5/25/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

import UIKit

class Effect<S: SimulationStateType>: SimulationEntity<AnySimulationState, Emitter<EmitterState>> {
    var spriteRenderingView: SpriteRenderingView!
    let particleTexture: UIImage
    
    func addEmitterAtPosition(position: Position) {
        let initialEmitterState = EmitterState(
            position: position,
            scale: 0.0,
            lifespan: 10.0,
            velocity: VectorZero,
            
            rate: 10.0,
            
            spriteBuffer: spriteRenderingView.spriteBuffer
        )

        let particleGenerator: Emitter.ParticleGeneratorFunction = {
                (sprite, position) in
                
                var initialParticleState = ParticleState(sprite: sprite)
                initialParticleState.position = position
                initialParticleState.scale = Scalar(100.0).randomizedValueByProportion(0.5)
                initialParticleState.lifespan = Scalar(3.0).randomizedValueByProportion(0.5)
                initialParticleState.velocity = VectorZero.randomizedValueByOffset(10.0)
                initialParticleState.color = UIColor.whiteColor().simColor
                
                return Particle(initialState: initialParticleState, currentTime: GlobalSimTime)
            }
        
        createdEntities += [Emitter<EmitterState>(initialState: initialEmitterState, particleGenerator: particleGenerator, currentTime: GlobalSimTime)]
    }
    
    init(spriteRenderingView: SpriteRenderingView) {
        particleTexture = UIImage(named: "ParticleTexture")!

        super.init(initialState: AnySimulationState(), currentTime: GlobalSimTime)
        self.spriteRenderingView = spriteRenderingView;
    }
}

