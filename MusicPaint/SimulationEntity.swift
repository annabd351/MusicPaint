//
//  SimulationEntity.swift
//  Music Paint
//
//  Created by Anna Dickinson on 6/3/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// Base class for the dynamic simulation system.

// This is a generalization of the concept of a particle system.  At a basic level, a particle system is simply a collection of
// stateful points which move around in response to simulated forces.  Emitters create particles.  Particles are associated with
// renderable graphics elements.  At each time step, the system updates the particle and emitter state, and renders the particles.
//
// On a generalized level, though, Emitters and Particles have similar types of state and are processed in similar ways. For example, both have
// a position in space.  Both can move, so they both have a velocity.  Both are updated on each time step.
//
// Also, it's useful to think of collections of Emitters and Particles as being stateful.  For example, a set of Emitters could
// orbit a point, each emitting different types of Particles at different rates.  The collection, then, is also a stateful, simulatable entity.
//
// This class generalizes the idea of a simulation data structure.  Using generics, you can define specific types of entities, collections of entities,
// and hierarchical relationships between them.

import UIKit

protocol SimulationEntityType {

    // Ask an entity to update its state based on the current (global) simulation time and
    // the time since it was last processed.
    func update(currentTime: Time, timestep: Time)

    // The specific type of state this entity needs
    typealias StateType: SimulationStateType
    var currentState: StateType { get set }
    var initialState: StateType { get }

    // Entities age over time.  Dead entities are ignored and
    // potentially deleted.
    func relativeAge(currentTime: Time) -> Time
    func isAliveAtTime(currentTime: Time) -> Bool
    
    // An entity can own and manage a collection of child entities.
    // createdEntities holds these entities.
    typealias CreatedEntityType: SimulationEntityType
    var createdEntities: [CreatedEntityType] { get }
    
    // On each update, the entity invokes a series of update functions
    // on its children.  For example, say an Emitter held a collection of Particles.
    // Each time the Emitter itself is updated (via the update() function), it iterates
    // through its children and updates them, in turn, using these functions.

    // Update functions are called sequentially based on the order in which they were added.
    typealias UpdateFunctionType = (Self, Time, Time) -> ()
    func addCreatedEntityUpdateFunction(function: UpdateFunctionType)
}

// All simulation entities have -- at a minimum -- this type of state
protocol SimulationStateType {
    var position: Position { get set }
    var scale: Scalar { get set }
    var lifespan: Time { get set }
    var velocity: Vector { get set }
    
    // Copy constructor
    init(original: Self)
}

// A class whose state is given by S whose child entities are of type E.
class SimulationEntity<S: SimulationStateType, E: SimulationEntityType>: SimulationEntityType {
    
    var currentState: S
    let initialState: S

    private let birthTime: Time
    
    var createdEntities: [E] = []
    var createdEntitiesCount: Int {
        return createdEntities.count
    }
    
    typealias UpdateFunctionType = (E, Time, Time) -> ()
    private var createdEntityUpdateFunctions: [UpdateFunctionType] = [SimulationEntity<S, E>.callCreatedEntityUpdate]
    
    init(initialState: S, currentTime: Time) {
        self.initialState = S(original: initialState)
        self.currentState = initialState
        
        birthTime = currentTime
    }
    
    func relativeAge(currentTime: Time) -> Time {
        return currentTime - birthTime
    }

    func isAliveAtTime(currentTime: Time) -> Bool {
        return relativeAge(currentTime) <= currentState.lifespan
    }
    
    func normalizedAge(currentTime: Time) -> Time {
        return relativeAge(currentTime)/currentState.lifespan
    }

    func update(currentTime: Time, timestep: Time) {
        currentState.position = currentState.position + currentState.velocity * timestep
     
        // Remove dead entities
        createdEntities = createdEntities.filter { $0.isAliveAtTime(currentTime) }
        
        // Update remaining entities
        for entity in createdEntities {
            for updateFunction in createdEntityUpdateFunctions {
                updateFunction(entity, currentTime, timestep)
            }
        }
    }

    func addCreatedEntityUpdateFunction(function: UpdateFunctionType) {
        createdEntityUpdateFunctions.append(function)
    }
    
    class func callCreatedEntityUpdate(createdEntity: E, currentTime: Time, timestep: Time) -> () {
        createdEntity.update(currentTime, timestep: timestep)
    }
}

// System time
var GlobalSimTime: Time {
    // TODO: This truncates the time value.  Might need to retain precision.
    return Time(CACurrentMediaTime())
}

// "Base" generics
final class AnySimulationState: SimulationStateType {
    var position: Position = VectorZero
    var scale: Scalar = 0
    var lifespan: Time = 0
    var velocity: Vector = VectorZero
    
    convenience init(original: AnySimulationState) {
        self.init()
        self.position = original.position
        self.scale = original.scale
        self.lifespan = original.lifespan
        self.velocity = original.velocity
    }
}

final class AnySimulationEntity: SimulationEntityType {
    var currentState = AnySimulationState()
    let initialState = AnySimulationState()
    
    let createdEntities: [AnySimulationEntity] = []
    
    typealias UpdateFunctionType = (AnySimulationEntity, Time, Time) -> ()
    func addCreatedEntityUpdateFunction(function: UpdateFunctionType) { }

    func relativeAge(currentTime: Time) -> Time {
        return 0
    }
    
    func isAliveAtTime(currentTime: Time) -> Bool {
        return false;
    }
    
    func update(currentTime: Time, timestep: Time) {
    }
}
