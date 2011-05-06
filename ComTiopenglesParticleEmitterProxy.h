//
//  ComTiopenglesParticleEmitterProxy.h
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/05/04.
//  Copyright 2011 Langrise Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TiProxy.h"
#import "ParticleEmitter.h"


@interface ComTiopenglesParticleEmitterProxy : TiProxy {
    ParticleEmitter *emitter;
}

@property(nonatomic, assign) id sourcePosition;
@property(nonatomic, assign) id particleCount;
@property(nonatomic, assign) id active;
@property(nonatomic, assign) id duration;

+ (id)loadpex:(NSString *)path;
- (id)initWithPexPath:(NSString *)path;
- (void)renderParticles;
- (void)updateWithDelta:(NSNumber *)aDelta;
- (void)stopParticleEmitter;

@end
