//
//  ComTiopenglesCameraProxy.h
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/28.
//  Copyright 2011 Langrise Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TiProxy.h"

@interface ComTiopenglesCameraProxy : TiProxy {
    float position[3];
    float angle[3];

    float camera_matrix[16];
}
@property (nonatomic, assign) id position;
@property (nonatomic, assign) id angle;

- (void)loadMatrix;

- (void)pitch:(id)args;
- (void)yaw:(id)args;
- (void)roll:(id)args;
- (void)move:(id)args;

@end
