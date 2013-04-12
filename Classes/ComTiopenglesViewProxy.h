//
//  ComTiopenglesViewProxy.h
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/07.
//  Copyright 2013 MARSHMALLOW MACHINE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TiViewProxy.h"
#import "ComTiopenglesView.h"

@interface ComTiopenglesViewProxy : TiViewProxy {
}
@property (nonatomic, assign) id debug;
@property (nonatomic, readonly) id fps;
@property (nonatomic, readonly) id triangles;
@property (nonatomic, readonly) id particles;

- (void)addModel:(id)args;
- (void)addParticleEmitter:(id)args;
@end
