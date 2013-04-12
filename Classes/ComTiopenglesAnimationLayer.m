//
//  ComTiopenglesAnimationLayer.m
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/04/07.
//  Copyright 2013 MARSHMALLOW MACHINE All rights reserved.
//

#import "ComTiopenglesAnimationLayer.h"

@implementation ComTiopenglesAnimationLayer
@synthesize target;

@synthesize rotation_x;
@synthesize rotation_y;
@synthesize rotation_z;

@synthesize translation_x;
@synthesize translation_y;
@synthesize translation_z;

- (id) initWithTarget:(id)value
{
    if((self = [super init])){
        target = value;
    }
    return self;
}

- (id) initWithLayer:(id)layer 
{
	if((self = [super initWithLayer:layer])) {
		if([layer isKindOfClass:[ComTiopenglesAnimationLayer class]]) {
			ComTiopenglesAnimationLayer *other = (ComTiopenglesAnimationLayer *)layer;
            
            self.target = other.target;
            
            self.rotation_x = other.rotation_x;
            self.rotation_y = other.rotation_y;
            self.rotation_z = other.rotation_z;
            
            self.translation_x = other.translation_x;
            self.translation_y = other.translation_y;
            self.translation_z = other.translation_z;
        }
	}
	return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key 
{
	if ([key hasPrefix:@"rotation"] || [key hasPrefix:@"translation"]){
        return YES;
    }
	else {
        return [super needsDisplayForKey:key];
    }
}

- (void)display
{
    ComTiopenglesAnimationLayer *pl = [self presentationLayer];

    [target setRotation_x:pl.rotation_x];
    [target setRotation_y:pl.rotation_y];
    [target setRotation_z:pl.rotation_z];
    
    [target setTranslation_x:pl.translation_x];
    [target setTranslation_y:pl.translation_y];
    [target setTranslation_z:pl.translation_z];
}

- (void)dealloc
{
    self.target = nil;
    
    self.rotation_x = nil;
    self.rotation_y = nil;
    self.rotation_z = nil;
    
    self.translation_x = nil;
    self.translation_y = nil;
    self.translation_z = nil;
    
    [super dealloc];
}

@end
