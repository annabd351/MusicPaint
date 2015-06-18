//
//  SimulationEntity.swift
//  Music Paint
//
//  Created by Anna Dickinson on 6/3/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

import UIKit

protocol SimulationEntityType {
    func update(currentTime: Time, timestep: Time)
    
    typealias StateType: SimulationStateType
    var currentState: StateType { get set }
    var initialState: StateType { get }
    
    func relativeAge(currentTime: Time) -> Time
    func isAliveAtTime(currentTime: Time) -> Bool
    
    typealias CreatedEntityType: SimulationEntityType
    var createdEntities: [CreatedEntityType] { get }
    
    typealias UpdateFunctionType = (Self, Time, Time) -> ()
    func addCreatedEntityUpdateFunction(function: UpdateFunctionType)
}

protocol SimulationStateType {
    var position: Position { get set }
    var scale: Scalar { get set }
    var lifespan: Time { get set }
    var velocity: Vector { get set }
}

class SimulationEntity<S: SimulationStateType, E: SimulationEntityType>: SimulationEntityType {
    
    var currentState: S
    let initialState: S

    private let birthTime: Time
    
    var createdEntities: [E] = []
    
    typealias UpdateFunctionType = (E, Time, Time) -> ()
    private var createdEntityUpdateFunctions: [UpdateFunctionType] = [SimulationEntity<S, E>.callCreatedEntityUpdate]
    
    init(initialState: S, currentTime: Time) {
        self.initialState = initialState
        self.currentState = initialState
        
        birthTime = currentTime
    }
    
    func relativeAge(currentTime: Time) -> Time {
        return currentTime - birthTime
    }

    func isAliveAtTime(currentTime: Time) -> Bool {
        return currentTime - birthTime <= currentState.lifespan
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

// Truncate times to this window -- we have limited precision
let GlobalTimePrecision = 60.0 * 10

var GlobalSimTime: Time {
    return Time(CACurrentMediaTime() % GlobalTimePrecision)
}


// Dummy classes for use in resolving generics
// (Ideally, shouldn't need these -- there's one more level of type erasure here I haven't quite figured out...)
struct AnySimulationState: SimulationStateType {
    var position: Position = VectorZero
    var scale: Scalar = 0
    var lifespan: Time = 0
    var velocity: Vector = VectorZero
}

class AnySimulationEntity: SimulationEntityType {
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
