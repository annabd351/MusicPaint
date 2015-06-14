//
//  Advectors.swift
//  Music Paint
//
//  Created by Anna Dickinson on 6/1/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

import Foundation

// Functions which can be attached to an Emitter to move and/or modify particles

extension Emitter {

    // Move the particle along its velocity vector
    class func advect(particle: Particle, timestep: Time) -> Particle {
        particle.position = particle.position + particle.velocity * timestep
        return particle
    }

    // Linearly shrink the particle as it ages
    class func scaleDownByAge(particle: Particle, timestep: Time) -> Particle {
        var currentParticle = advect(particle, timestep: timestep)
        
        let normalizedLifespan = particle.age/particle.lifespan
        particle.scale = particle.initialScale * (1.0 - normalizedLifespan)
        
        return currentParticle
    }
}