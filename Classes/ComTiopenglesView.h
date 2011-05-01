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
#import "SceneLayer.h"

#define LIGHTS_MAX	8

@interface ComTiopenglesView : TiUIView {
    EAGLContext *context;    
    
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
    
    id camera;
	NSArray *lights;
	NSMutableArray *models;
    
    CADisplayLink *displayLink;
    int frameCount;
    int verticesCount;
    NSDate *fpsCounted;
    BOOL drawingFrame;
    float fps;
    NSDate *fpsCalculated;
}
@property (nonatomic, readonly) NSNumber *fps;
@property (nonatomic, readonly) NSNumber *vertices;

- (void)setZNear_:(id)value;
- (void)setZFar_:(id)value;
- (void)setFieldOfView_:(id)value;
- (void)setLights_:(id)value;
- (void)setCamera_:(id)value;

- (void)addModel:(id)args;

- (void)setupLights;
- (void)openContext;
- (void)closeContext;
- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;
@end
