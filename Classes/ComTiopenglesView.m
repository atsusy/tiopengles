//
//  ComTiopenglesView.m
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/07.
//  Copyright 2013 MARSHMALLOW MACHINE. All rights reserved.
//

#import "opencv/cv.h"
#import "opencv/cxcore.h"
#import <OpenGLES/ES1/glext.h>
#import "ComTiopenglesView.h"

static const float objectPoint[] = { 0.0, 0.0, -5.0 };
static const float default_diffuse[4] = {1.0f, 1.0f, 1.0f, 1.0f};
static const float default_ambient[4] = {1.0f, 1.0f, 1.0f, 1.0f};
static const float default_specular[4] = {0.0f, 0.0f, 0.0f, 1.0f};

@implementation ComTiopenglesView
@synthesize debug;

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
									[NSNumber numberWithBool:YES],
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
	//NSLog(@"zNear set %f.", zNear);
}

- (void)setZFar_:(id)value
{
	zFar = [value floatValue];
	//NSLog(@"zFar set %f.", zFar);
}

- (void)setFieldOfView_:(id)value
{
	fieldOfView = [value floatValue];
	//NSLog(@"fieldOfView set %f.", fieldOfView);
}

- (void)setCamera_:(id)value
{
    ENSURE_TYPE(value, ComTiopenglesCameraProxy);
    if(camera){
        [((ComTiopenglesCameraProxy *)camera).animationLayer removeFromSuperview];
    }
    camera = value;
    [self.layer addSublayer:((ComTiopenglesCameraProxy *)camera).animationLayer];
}

- (void)setLights_:(id)value
{
	ENSURE_ARRAY(value);

	RELEASE_TO_NIL(lights);
	lights = [value retain];
}

- (NSNumber *)fps
{
    return NUMFLOAT(fps);
}

- (NSNumber *)triangles
{
    return NUMINT(trianglesCount);
}

- (NSNumber *)particles
{
    return NUMINT(particlesCount);
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

- (void)set2DProjection
{
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
	glOrthof(0, bounds.size.width, 0, bounds.size.height, -1, 1);
	
    // Set the viewport
    glViewport(0, 0, bounds.size.width, bounds.size.height);    
}

- (void)set3DProjection
{
	glMatrixMode(GL_PROJECTION); 
    glLoadIdentity();

    CGRect bounds = [[UIScreen mainScreen] bounds];

	if(zNear == 0.0) { zNear = 0.01; }
	if(zFar == 0.0) { zFar = 1000.0; }
	if(fieldOfView == 0.0) { fieldOfView = 45.0; }
	    
	CGFloat size = zNear * tanf(fieldOfView * M_PI / 180.0 / 2.0); 
	glFrustumf(-size, 
			   size, 
			   -size / (bounds.size.width / bounds.size.height), 
			   size / (bounds.size.width / bounds.size.height), 
			   zNear, 
			   zFar); 
	
	glViewport(0, 0, bounds.size.width, bounds.size.height);      
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
    
    glGenRenderbuffersOES(1, &depthRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) 
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
	
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glEnable(GL_CULL_FACE);
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_ALPHA);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	// setup lights.
    [self setupLights];

    // start refresh frame buffer
    if(displayLink){
        [displayLink invalidate];
        RELEASE_TO_NIL(displayLink);
    }    
    displayLink = [[UIScreen mainScreen] displayLinkWithTarget:self 
                                                      selector:@selector(drawFrame)];
    fpsCalculated = [[NSDate date] retain];
    frameCount = 0;
    trianglesCount = 0;
    [displayLink setFrameInterval:1];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] 
                      forMode:NSDefaultRunLoopMode];

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
    
    [displayLink invalidate];    
}

- (void)drawGrid
{ 
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    glLineWidth(0.5);

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
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
}

- (void)drawFrame
{
    double delta = 0.0;
    if(frameDrawn){
        delta = [frameDrawn timeIntervalSinceNow] * -1;   
    }
    RELEASE_TO_NIL(frameDrawn);
    frameDrawn = [[NSDate date] retain];
    
    // ------------------------------------
    //  INITIALIZE
    // ------------------------------------
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, default_diffuse);
    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, default_ambient);
    glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, default_specular);
    
    // ------------------------------------
    //  2D LAYER
    // ------------------------------------
    [self set2DProjection];
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity(); 
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_LIGHTING);

    // draw particles.
    int particles = 0;
    for(ComTiopenglesParticleEmitterProxy *particleEmitter in particleEmitters)
    {
        [particleEmitter updateWithDelta:[NSNumber numberWithFloat:(1.0f/60.0f)/*delta*/]];
        [particleEmitter renderParticles];
        
        particles += [[particleEmitter particleCount] intValue];
    }
    particlesCount = particles;    

    // ------------------------------------
    // 3D LAYER
    // ------------------------------------
    [self set3DProjection];    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity(); 
    glEnable(GL_DEPTH_TEST);       
    glEnable(GL_LIGHTING);

    // load world-view matrix
    if(camera){
        [camera loadMatrix];
    }
        
    // draw grid.
    if(debug){
        [self drawGrid];
    }
    
    // draw models.
    int triangles = 0;
    for(id model in models)
    {
        glPushMatrix();
        triangles += [model draw];
        glPopMatrix();
    }
    trianglesCount = triangles;

    // ------------------------------------
    // RENDERING TO VIEWBUFFER
    // ------------------------------------    
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
    // ------------------------------------
    // COUNT UP FRAME AND CALCULATE
    // ------------------------------------    
    frameCount++;
    double elapsed = [fpsCalculated timeIntervalSinceNow];
    if(elapsed < -2.0f){ // value of -2.0 has no basis.
        fps = (float)(frameCount / elapsed) * -1;
        frameCount = 0;
        RELEASE_TO_NIL(fpsCalculated);
        fpsCalculated = [[NSDate date] retain]; 
    }
}

- (void)addModel:(ComTiopengles3DModelProxy *)model
{
    if(!models)
	{
		models = [[NSMutableArray alloc] init];
	}
    
    [self.layer addSublayer:[model animationLayer]];
	[models addObject:model];
}

- (void)addParticleEmitter:(ComTiopenglesParticleEmitterProxy *)particleEmitter
{
    if(!particleEmitters){
        particleEmitters = [[NSMutableArray alloc] init];
    }
    
    [particleEmitters addObject:particleEmitter];
}

- (void)layoutSubviews 
{
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
}

- (id)toImage
{
    [EAGLContext setCurrentContext:context];

    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);

    size_t w = backingWidth, h = backingHeight;
	int bytesCount = 4 * w * h;
    
	GLubyte *data = malloc(bytesCount * sizeof(GLubyte));
	
    glReadPixels(0, 0, w, h, GL_RGBA, GL_UNSIGNED_BYTE, data);
	
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, data, bytesCount, NULL);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
    CGImageRef cgImage = CGImageCreate(w,
                                       h,
                                       8,
                                       32,
                                       w * 4,
                                       colorSpace,
                                       kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                       dataProvider,
                                       NULL,
                                       true,
                                       kCGRenderingIntentDefault);
 	
    NSInteger widthInPoints, heightInPoints;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
    {
        CGFloat scale = self.contentScaleFactor;
        widthInPoints = w / scale; heightInPoints = h / scale;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
    }
    else
    {
        widthInPoints = w; heightInPoints = h;
        UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
    }
    
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
    CGContextDrawImage(UIGraphicsGetCurrentContext(),
                       CGRectMake(0, 0, widthInPoints, heightInPoints),
                       cgImage);
    
    UIImage *uiImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
    
    free(data);
    CFRelease(dataProvider);
	CGColorSpaceRelease(colorSpace);
	CGImageRelease(cgImage);
    
	return uiImage;
}

- (void)dealloc
{
    camera = nil;
	RELEASE_TO_NIL(lights);
	RELEASE_TO_NIL(models);
    RELEASE_TO_NIL(fpsCalculated);
    RELEASE_TO_NIL(frameDrawn);
	[self destroyFramebuffer];	
	[super dealloc];
}
@end
