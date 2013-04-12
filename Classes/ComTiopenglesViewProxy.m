//
//  ComTiopenglesViewProxy.m
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/07.
//  Copyright 2013 MARSHMALLOW MACHINE. All rights reserved.
//

#import "ComTiopenglesViewProxy.h"
#import "TiBlob.h"

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

- (TiBlob *)toImage:(id)args
{
    KrollCallback *callback = nil;
    BOOL honorScale = NO;
    
    NSObject *obj = nil;
    if( [args count] > 0) {
        obj = [args objectAtIndex:0];
        
        if (obj == [NSNull null]) {
            obj = nil;
        }
        
        if( [args count] > 1) {
            honorScale = [TiUtils boolValue:[args objectAtIndex:1] def:NO];
        }
    }
    callback = (KrollCallback*)obj;
    TiBlob *blob = [[[TiBlob alloc] init] autorelease];
    
    TiThreadPerformOnMainThread(^{
        id image = [(ComTiopenglesView *)[self view] toImage];
		[blob setImage:image];
        [blob setMimeType:@"image/png" type:TiBlobTypeImage];
		if (callback != nil)
		{
			NSDictionary *event = [NSDictionary dictionaryWithObject:blob forKey:@"blob"];
			[self _fireEventToListener:@"blob" withObject:event listener:callback thisObject:nil];
		}
    }, (callback==nil));
    
    return blob;
}
@end
