//
//  ComTiopenglesView.m
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/07.
//  Copyright 2011 LANGRISE Co.,Ltd. All rights reserved.
//

#import "ComTiopenglesView.h"
#import "ComTiopengles3DModel.h"
#import "ComTiopenglesCameraProxy.h"
#import "opencv/cv.h"
#import "opencv/cxcore.h"
#import <OpenGLES/ES1/glext.h>

static const float objectPoint[] = { 0.0, 0.0, -5.0 };
static const float grid_diffuse[4] = {1.0f, 1.0f, 1.0f, 1.0f};
static const float grid_ambient[4] = {0.2f, 0.2f, 0.2f, 1.0f};
static const float grid_specular[4] = {0.0f, 0.0f, 0.0f, 1.0f};

@implementation ComTiopenglesView
@synthesize camera;

+ (Class)layerClass 
{
    return [CAEAGLLayer class];
}

- (void)openContext
{
	// Get the layer
	CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
	
	eaglLayer.opaque = NO;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:NO], 
									kEAGLDrawablePropertyRetainedBacking, 
									kEAGLColorFormatRGBA8, 
									kEAGLDrawablePropertyColorFormat, nil];
	
	context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
	
	if (!context || ![EAGLContext setCurrentContext:context]) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Cannot allocate EAGLContext."
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil] autorelease];	
		[alert show];
	}
}

- (void)closeContext
{    
	if ([EAGLContext currentContext] == context) {
		[EAGLContext setCurrentContext:nil];
	}
	RELEASE_TO_NIL(context);
}

- (void)setZNear_:(id)value
{
	zNear = [value floatValue];
	NSLog(@"zNear set %f.", zNear);
}

- (void)setZFar_:(id)value
{
	zFar = [value floatValue];
	NSLog(@"zFar set %f.", zFar);
}

- (void)setFieldOfView_:(id)value
{
	fieldOfView = [value floatValue];
	NSLog(@"fieldOfView set %f.", fieldOfView);
}

- (void)setLights_:(id)value
{
	ENSURE_ARRAY(value);

	RELEASE_TO_NIL(lights);
	lights = [value retain];
}

- (id)camera_
{
    return self.camera;
}

- (void)setCamera_:(id)value
{
    ENSURE_TYPE(value, ComTiopenglesCameraProxy);
    self.camera = value;
}

- (void)setDepthBuffer_:(id)value
{
	useDepthBuffer = [value intValue];
	NSLog(@"userDepthBuffer set %d", useDepthBuffer);
}

- (void)setupLights
{
	if(!lights)
	{
        glDisable(GL_LIGHTING);
		return;
	}

	// Enable lighting
	glEnable(GL_LIGHTING);
	
	if([lights count] <= LIGHTS_MAX)
	{
		for(int i = 0; i < [lights count]; i++)
		{
			glEnable(GL_LIGHT0+i);
			id light = [lights objectAtIndex:i];
			ENSURE_DICT(light);
			
			id ambientDic = [light objectForKey:@"ambient"];
			ENSURE_DICT(ambientDic);
			l_ambient[i][0] = [[ambientDic objectForKey:@"r"] floatValue];
			l_ambient[i][1] = [[ambientDic objectForKey:@"g"] floatValue];
			l_ambient[i][2] = [[ambientDic objectForKey:@"b"] floatValue];
			l_ambient[i][3] = 1.0;
			//NSLog(@"light amb %f,%f,%f", l_ambient[i][0], l_ambient[i][1], l_ambient[i][2]);
			glLightfv(GL_LIGHT0+i, GL_AMBIENT, l_ambient[i]);
			
			id diffuseDic = [light objectForKey:@"diffuse"];
			ENSURE_DICT(diffuseDic);
			l_diffuse[i][0] = [[diffuseDic objectForKey:@"r"] floatValue];
			l_diffuse[i][1] = [[diffuseDic objectForKey:@"g"] floatValue];
			l_diffuse[i][2] = [[diffuseDic objectForKey:@"b"] floatValue];
			l_diffuse[i][3] = 1.0;
			glLightfv(GL_LIGHT0+i, GL_DIFFUSE, l_diffuse[i]);
			//NSLog(@"light dif %f,%f,%f", l_diffuse[i][0], l_diffuse[i][1], l_diffuse[i][2]);
			
			id specularDic = [light objectForKey:@"specular"];
			ENSURE_DICT(specularDic);
			l_specular[i][0] = [[specularDic objectForKey:@"r"] floatValue];
			l_specular[i][1] = [[specularDic objectForKey:@"g"] floatValue];
			l_specular[i][2] = [[specularDic objectForKey:@"b"] floatValue];
			l_specular[i][3] = 1.0;
			glLightfv(GL_LIGHT0+i, GL_SPECULAR, l_specular[i]);
			//NSLog(@"light spc %f,%f,%f", l_specular[i][0], l_specular[i][1], l_specular[i][2]);
			
			id positionDic = [light objectForKey:@"position"];
			ENSURE_DICT(positionDic);
			l_position[i][0] = [[positionDic objectForKey:@"x"] floatValue];
			l_position[i][1] = [[positionDic objectForKey:@"y"] floatValue];
			l_position[i][2] = [[positionDic objectForKey:@"z"] floatValue];	
            //[self multifv:light_position Matrix:camera_matrix];
			glLightfv(GL_LIGHT0+i, GL_POSITION, l_position[i]); 
			//NSLog(@"light pos %f,%f,%f", l_position[i][0], l_position[i][1], l_position[i][2]);

			// Calculate light vector so it points at the object
			l_direction[i][0] = l_position[i][0];
			l_direction[i][1] = l_position[i][1];
			l_direction[i][2] = l_position[i][2];
			CvMat objectVec = cvMat(1, 3, CV_32F, (void *)objectPoint);
			CvMat lightVec = cvMat(1, 3, CV_32F, l_direction);
			cvSub(&objectVec, &lightVec, &lightVec, NULL);
			cvNormalize(&lightVec, &lightVec, 1.0, 0, CV_L2, NULL);
			glLightfv(GL_LIGHT0+i, GL_SPOT_DIRECTION, l_direction[i]);
			//NSLog(@"light vec %f,%f,%f", l_direction[i][0], l_direction[i][1], l_direction[i][2]);
		}
	}
}

-(void)setupView
{
	if(zNear == 0.0) { zNear = 0.01; }
	if(zFar == 0.0) { zFar = 1000.0; }
	if(fieldOfView == 0.0) { fieldOfView = 45.0; }
	
	glMatrixMode(GL_PROJECTION); 
	CGFloat size = zNear * tanf(fieldOfView * M_PI / 180.0 / 2.0); 
	glFrustumf(-size, 
			   size, 
			   -size / (self.bounds.size.width / self.bounds.size.height), 
			   size / (self.bounds.size.width / self.bounds.size.height), 
			   zNear, 
			   zFar); 
	
	glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);  
	
	glMatrixMode(GL_MODELVIEW);	
	
    [self setupLights];
	
    glLoadIdentity(); 	
}

- (BOOL)createFramebuffer 
{
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (useDepthBuffer) 
    {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
        glEnable(GL_DEPTH_TEST);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) 
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
	
	// setup view.
	[self setupView];
    
    if(sceneTimer){
        [sceneTimer invalidate];
        RELEASE_TO_NIL(sceneTimer);
    }
    sceneTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 
                                                  target:self
                                                selector:@selector(drawView:) 
                                                userInfo:nil 
                                                 repeats:YES];

    return YES;
}

- (void)destroyFramebuffer 
{
	if(viewFramebuffer)
	{
		glDeleteFramebuffersOES(1, &viewFramebuffer);
		viewFramebuffer = 0;
	}
	if(viewRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &viewRenderbuffer);
		viewRenderbuffer = 0;
	}
    if(depthRenderbuffer) 
    {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}

- (void)drawGrid
{ 
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    glLineWidth(0.5);

    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, grid_diffuse);
    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, grid_ambient);
    glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, grid_specular);

    float vertices[100 * 3 * 2];
    float normals[100 * 3 * 2];
    
    for(int i = 0; i < 100; i++){
        normals[i * 6 + 0] = 0.0f;
        normals[i * 6 + 1] = 1.0f;
        normals[i * 6 + 2] = 0.0f;
        normals[i * 6 + 3] = 0.0f;
        normals[i * 6 + 4] = 1.0f;
        normals[i * 6 + 5] = 0.0f;
    }
    glNormalPointer(GL_FLOAT, 0, normals);
    
    for(int i = 0; i < 100; i++){
        vertices[i * 6 + 0] = -500.0f;
        vertices[i * 6 + 1] = 0.0f;
        vertices[i * 6 + 2] = (i - 100/2) * 10.0f;
        vertices[i * 6 + 3] = 500.0f;
        vertices[i * 6 + 4] = 0.0f;
        vertices[i * 6 + 5] = (i - 100/2) * 10.0f;
    }
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glDrawArrays(GL_LINES, 0, 200);
    
    for(int i = 0; i < 100; i++){
        vertices[i * 6 + 0] = (i - 100/2) * 10.0f;
        vertices[i * 6 + 1] = 0.0f;
        vertices[i * 6 + 2] = -500.0f;
        vertices[i * 6 + 3] = (i - 100/2) * 10.0f;
        vertices[i * 6 + 4] = 0.0f;
        vertices[i * 6 + 5] = 500.0f;
    }
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glDrawArrays(GL_LINES, 0, 200);
    
    vertices[0] = 0.0f;
    vertices[1] = 10000.0f;
    vertices[2] = 0.0f;
    vertices[3] = 0.0f;
    vertices[4] = -10000.0f;
    vertices[5] = 0.0f;
    glLineWidth(2.0);
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glDrawArrays(GL_LINES, 0, 2);
}

- (void)drawView:(NSTimer *)timer
{
    @synchronized(self){
        if(sceneDrawing){
            return;
        }
        sceneDrawing = YES;
    }
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	glEnable(GL_BLEND);
    glEnable(GL_CULL_FACE);
    glEnable(GL_TEXTURE_2D);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    if(self.camera){
        [self.camera loadMatrix];
    }
    
    [self setupLights];
    [self drawGrid];
    
	for(id model in models)
	{
        glPushMatrix();
		[model draw];
        glPopMatrix();
	}
		
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
    @synchronized(self)
    {
        sceneDrawing = NO;
    }
}

- (void)addModel:(id)args
{
    ENSURE_ARRAY(args)
    id model = [args objectAtIndex:0];
	ENSURE_TYPE(model, ComTiopengles3DModel);
	if(!models)
	{
		models = [[NSMutableArray alloc] init];
	}
	[models addObject:model];
}

- (void)layoutSubviews 
{
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView:nil];
}

- (void)dealloc
{
    self.camera = nil;
	RELEASE_TO_NIL(lights);
	RELEASE_TO_NIL(models);
	[self destroyFramebuffer];	
	[super dealloc];
}

@end
