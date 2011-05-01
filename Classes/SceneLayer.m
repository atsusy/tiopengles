//
//  SceneLayer.m
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/04/05.
//  Copyright 2011 Langrise Co.,Ltd. All rights reserved.
//

#import "SceneLayer.h"

@implementation SceneLayer
@synthesize rotation_x;
@synthesize rotation_y;
@synthesize rotation_z;
@synthesize translation_x;
@synthesize translation_y;
@synthesize translation_z;

- (id) initWithLayer:(id)layer 
{
	if((self = [super initWithLayer:layer])) {
		if([layer isKindOfClass:[SceneLayer class]]) {
			SceneLayer *other = (SceneLayer *)layer;
            
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
    NSLog(@"[DEBUG]key:%@",key);
	if ([key hasPrefix:@"rotation"] || [key hasPrefix:@"translation"]){
        return YES;
    }
	else {
        return [super needsDisplayForKey:key];
    }
}

- (void)display
{
    NSLog(@"model rotation x:%f y:%f z:%f", rotation_x, rotation_y, rotation_z);
    [super display];
}

@end
