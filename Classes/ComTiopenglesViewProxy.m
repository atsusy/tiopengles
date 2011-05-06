//
//  ComTiopenglesViewProxy.m
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/07.
//  Copyright 2011 LANGRISE Co.,Ltd. All rights reserved.
//

#import "ComTiopenglesViewProxy.h"

@implementation ComTiopenglesViewProxy

- (id)init
{
    self = [super init];
    if(self){
        [self view]; // force instantiate
    }
    return self;
}

- (id)debug
{
    return NUMBOOL([(ComTiopenglesView *)[self view] debug]);
}

- (void)setDebug:(id)value
{
    ENSURE_SINGLE_ARG(value, NSNumber);
    [(ComTiopenglesView *)[self view] setDebug:[value boolValue]];
}
    
- (id)fps
{
    return [(ComTiopenglesView *)[self view] fps];
}

- (id)triangles
{
    return [(ComTiopenglesView *)[self view] triangles];
}

- (id)particles
{
    return [(ComTiopenglesView *)[self view] particles];
}

- (void)addModel:(id)args
{
    ENSURE_SINGLE_ARG(args, ComTiopengles3DModelProxy);
    [(ComTiopenglesView *)[self view] addModel:args];
}

- (void)addParticleEmitter:(id)args
{
    ENSURE_SINGLE_ARG(args, ComTiopenglesParticleEmitterProxy);
    [(ComTiopenglesView *)[self view] addParticleEmitter:args];
}

- (void)viewDidAttach
{
	[(ComTiopenglesView *)[self view] openContext];	
}

- (void)viewDidDetach
{
	[(ComTiopenglesView *)[self view] closeContext];	
}

@end
