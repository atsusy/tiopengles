//
//  ComTiopenglesCameraProxy.h
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/28.
//  Copyright 2013 MARSHMALLOW MACHINE All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TiProxy.h"
#import "ComTiopenglesAnimationLayer.h"

@interface ComTiopenglesCameraProxy : TiProxy {
    id animationLayer;
    
    float rotation_x;
    float rotation_y;
    float rotation_z;
    
    float translation_x;
    float translation_y;
    float translation_z;

    float camera_matrix[16];
    
    id animationCallback;
}
@property (nonatomic, readonly) id animationLayer;

@property (nonatomic, retain) NSNumber *rotation_x;
@property (nonatomic, retain) NSNumber *rotation_y;
@property (nonatomic, retain) NSNumber *rotation_z;

@property (nonatomic, retain) NSNumber *translation_x;
@property (nonatomic, retain) NSNumber *translation_y;
@property (nonatomic, retain) NSNumber *translation_z;

- (void)loadMatrix;

- (void)pitch:(id)args;
- (void)yaw:(id)args;
- (void)roll:(id)args;
- (void)move:(id)args;

- (void)animate:(id)args;

@end
