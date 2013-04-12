//
//  ComTiopenglesAnimationLayer.h
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/04/07.
//  Copyright 2013 MARSHMALLOW MACHINE All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "ComTiopengles3DModelProxy.h"

@interface ComTiopenglesAnimationLayer : CALayer {
    id target;
}

- (id)initWithTarget:(id)value;

@property (nonatomic, assign) id target;

@property (nonatomic, retain) NSNumber *rotation_x;
@property (nonatomic, retain) NSNumber *rotation_y;
@property (nonatomic, retain) NSNumber *rotation_z;

@property (nonatomic, retain) NSNumber *translation_x;
@property (nonatomic, retain) NSNumber *translation_y;
@property (nonatomic, retain) NSNumber *translation_z;

@end
