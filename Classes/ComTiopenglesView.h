//
//  ComTiopenglesView.h
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/07.
//  Copyright 2011 LANGRISE Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import "TiUIView.h"

#define LIGHTS_MAX	8

@interface ComTiopenglesView : TiUIView {
    EAGLContext *context;    

	BOOL useDepthBuffer;
	float zNear;
	float zFar;
	float fieldOfView;
	
	float l_ambient[LIGHTS_MAX][4];
	float l_diffuse[LIGHTS_MAX][4];
	float l_specular[LIGHTS_MAX][4];
	float l_position[LIGHTS_MAX][4];
	float l_direction[LIGHTS_MAX][3];
	
    GLint backingWidth;
    GLint backingHeight;
    
	GLuint viewRenderbuffer, viewFramebuffer;
    GLuint depthRenderbuffer;
    
	NSArray *lights;
	NSMutableArray *models;
    
    NSTimer *sceneTimer;
    BOOL sceneDrawing;
}
@property (nonatomic, assign) id camera;

- (void)setZNear_:(id)value;
- (void)setZFar_:(id)value;
- (void)setFieldOfView_:(id)value;
- (void)setLights_:(id)value;

- (void)addModel:(id)args;
- (void)setupLights;
- (void)openContext;
- (void)closeContext;
- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;
@end
