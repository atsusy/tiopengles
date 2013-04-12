//
//  ComTiopenglesParticleEmitterProxy.m
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/05/04.
//  Copyright 2013 MARSHMALLOW MACHINE All rights reserved.
//

#import "TiPoint.h"
#import "ComTiopenglesParticleEmitterProxy.h"


@implementation ComTiopenglesParticleEmitterProxy
@synthesize active;
@synthesize duration;
@synthesize particleCount;
@synthesize sourcePosition;

+ (id)loadpex:(NSString *)path
{
    return [[[ComTiopenglesParticleEmitterProxy alloc] initWithPexPath:path] autorelease];
}

- (id)initWithPexPath:(NSString *)path
{
    self = [super init];
    if(self){
        emitter = [[ParticleEmitter alloc] initParticleEmitterWithFile:path];
    }
    return self;
}

- (id)active
{
    return NUMBOOL([emitter active]);
}

- (void)setActive:(id)value
{
    [emitter setActive:[value boolValue]];
}

- (id)duration
{
    return NUMFLOAT([emitter duration]);
}

- (void)setDuration:(id)value
{
    [emitter setDuration:(GLfloat)[value floatValue]];
}

- (id)particleCount
{
    return NUMINT([emitter particleCount]);
}

- (void)setParticleCount:(id)value
{
    [emitter setParticleCount:(GLint)[value intValue]];
}

- (id)sourcePosition
{
    CGPoint p = CGPointMake(emitter.sourcePosition.x, emitter.sourcePosition.y);
    return [[[TiPoint alloc] initWithPoint:p] autorelease];
}

- (void)setSourcePosition:(id)value
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    float height = bounds.size.height;

    ENSURE_DICT(value);
    Vector2f sp = {
        [[value valueForKey:@"x"] floatValue], 
        height-[[value valueForKey:@"y"] floatValue] };
    emitter.sourcePosition = sp;
}

- (void)renderParticles
{
    [emitter renderParticles];
}

- (void)updateWithDelta:(NSNumber *)aDelta
{
    GLfloat _aDelta = (GLfloat)[aDelta floatValue];
    [emitter updateWithDelta:_aDelta];
}

- (void)stopParticleEmitter
{
    [emitter stopParticleEmitter];
}

@end
