//
//  ComTiopengles3DModelProxy.h
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/10.
//  Copyright 2011 LANGRISE Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <OpenGLES/ES1/gl.h>
#import "TiProxy.h"
#import "ModelDataProtocol.h"
#import "AnimationLayer.h"

@interface ComTiopengles3DModelProxy : TiProxy {
    id animationLayer;
    
    float rotation_x;
    float rotation_y;
    float rotation_z;
    
    float translation_x;
    float translation_y;
    float translation_z;
    
    NSString *dataSourcePath;
    id<ModelDataProtocol> dataSource;
    
    NSMutableDictionary *animationCallbacks;
    NSMutableDictionary *animationKeys;
}
@property (nonatomic, readonly) id animationLayer;

@property (nonatomic, retain) NSNumber *rotation_x;
@property (nonatomic, retain) NSNumber *rotation_y;
@property (nonatomic, retain) NSNumber *rotation_z;

@property (nonatomic, retain) NSNumber *translation_x;
@property (nonatomic, retain) NSNumber *translation_y;
@property (nonatomic, retain) NSNumber *translation_z;

+ (id)load3ds:(NSString *)name;

- (GLuint)loadTexture:(NSString *)path;
- (id)initWith3dsPath:(NSString *)path;

- (void)rotation:(id)value;
- (void)translation:(id)value;

- (int)draw;
@end
