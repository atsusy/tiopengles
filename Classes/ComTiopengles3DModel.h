//
//  ComTiopengles3DModel.h
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/10.
//  Copyright 2011 LANGRISE Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import "TiProxy.h"
#import "ModelDataProtocol.h"


@interface ComTiopengles3DModel : TiProxy {
	float rotation[3];
	float translation[3];
    
    NSString *dataSourcePath;
    id<ModelDataProtocol> dataSource;
}

+ (id)load3ds:(NSString *)name;

- (GLuint)loadTexture:(NSString *)path;
- (id)initWith3dsPath:(NSString *)path;

- (void)rotation:(id)value;
- (void)translation:(id)value;
- (void)draw;
@end
