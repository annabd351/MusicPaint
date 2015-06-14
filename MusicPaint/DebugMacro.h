//
//  DebugMacro.h
//  Particle Paintbox
//
//  Created by Anna Dickinson on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Particle_Paintbox_DebugMacro_h
#define Particle_Paintbox_DebugMacro_h

#ifdef DEBUG
#define DebugMsg( _str, _val...) NSLog(@"%@:%@ " _str,self,NSStringFromSelector(_cmd),_val)
#define DebugTrace NSLog(@"%@:%@", self, NSStringFromSelector(_cmd))
#else
#define DebugMsg( _str, _val...) ;
#define DebugTrace ;
#endif

#endif
