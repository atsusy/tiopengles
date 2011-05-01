//
//  ComTiopenglesCameraProxy.m
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/28.
//  Copyright 2011 Langrise Co.,Ltd. All rights reserved.
//

#import "ComTiopenglesCameraProxy.h"
#import <OpenGLES/ES1/gl.h>

@implementation ComTiopenglesCameraProxy
@synthesize animationLayer;

- (NSNumber *)rotation_x
{
    return [NSNumber numberWithFloat:rotation_x];
}

- (void)setRotation_x:(NSNumber *)value
{
    rotation_x = [value floatValue];
    [animationLayer setRotation_x:value];
}

- (NSNumber *)rotation_y
{
    return [NSNumber numberWithFloat:rotation_y];
}

- (void)setRotation_y:(NSNumber *)value
{   
    rotation_y = [value floatValue];
    [animationLayer setRotation_y:value];
}

- (NSNumber *)rotation_z
{
    return [NSNumber numberWithFloat:rotation_z];
}

- (void)setRotation_z:(NSNumber *)value
{
    rotation_z = [value floatValue];
    [animationLayer setRotation_z:value];
}

- (NSNumber *)translation_x
{
    return [NSNumber numberWithFloat:translation_x];
}

- (void)setTranslation_x:(NSNumber *)value
{
   translation_x = [value floatValue];
   [animationLayer setTranslation_x:value];
}

- (NSNumber *)translation_y
{
    return [NSNumber numberWithFloat:translation_y];
}

- (void)setTranslation_y:(NSNumber *)value
{
    translation_y = [value floatValue];
    [animationLayer setTranslation_y:value];
}

- (NSNumber *)translation_z
{
    return [NSNumber numberWithFloat:translation_z];
}

- (void)setTranslation_z:(NSNumber *)value
{
    translation_z = [value floatValue];
    [animationLayer setTranslation_z:value];
}

- (id)position
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            self.translation_x,@"x",
            self.translation_y,@"y",
            self.translation_z,@"z",
            nil];
}

- (void)setPosition:(id)value
{
    ENSURE_DICT(value);
    self.translation_x = [value objectForKey:@"x"];
    self.translation_y = [value objectForKey:@"y"];
    self.translation_z = [value objectForKey:@"z"];
}

- (id)angle
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            self.rotation_x,@"x",
            self.rotation_y,@"y",
            self.rotation_z,@"z",
            nil];
}

- (void)setAngle:(id)value
{
    ENSURE_DICT(value);
    self.rotation_x = [value objectForKey:@"x"];
    self.rotation_y = [value objectForKey:@"y"];
    self.rotation_z = [value objectForKey:@"z"];
}

- (AnimationLayer *)animationLayer
{
    if(animationLayer == nil){
        animationLayer = [[AnimationLayer alloc] initWithTarget:self];
    }
    return animationLayer;
}

- (void)loadMatrix
{
    glRotatef(-rotation_x, 1.0f, 0.0f, 0.0f);
    glRotatef(-rotation_y, 0.0f, 1.0f, 0.0f);
    glRotatef(-rotation_z, 0.0f, 0.0f, 1.0f);
    glTranslatef(-translation_x, -translation_y, -translation_z);
    
    /*
    glGetFloatv(GL_MODELVIEW_MATRIX, camera_matrix);
    // transpose rotation
    float tmp;
    for(int i = 0; i < 3; i++){
        for(int j = 0; j < 3; j++){
            tmp = camera_matrix[i * 4 + j];
            camera_matrix[i * 4 + j] = camera_matrix[j * 4 + i];
            camera_matrix[j * 4 + i] = tmp;
        }
    }
    // inverse translation
    camera_matrix[12] = -camera_matrix[12];
    camera_matrix[13] = -camera_matrix[13];
    camera_matrix[14] = -camera_matrix[14];
    glLoadMatrixf(camera_matrix);
     */
}

- (void)multifv:(float *)pVec matrix:(float *)pMat
{
    float x = pMat[0]*pVec[0] + pMat[4]*pVec[1] + pMat[ 8]*pVec[2] + pMat[12]*pVec[3];
    float y = pMat[1]*pVec[0] + pMat[5]*pVec[1] + pMat[ 9]*pVec[2] + pMat[13]*pVec[3];
    float z = pMat[2]*pVec[0] + pMat[6]*pVec[1] + pMat[10]*pVec[2] + pMat[14]*pVec[3];
    float w = pMat[3]*pVec[0] + pMat[7]*pVec[1] + pMat[11]*pVec[2] + pMat[15]*pVec[3];
    
    pVec[0] = x;
    pVec[1] = y;
    pVec[2] = z;
    pVec[3] = w;
}

- (void)pitch:(id)args
{
    ENSURE_SINGLE_ARG(args, NSNumber);    
    
    rotation_x += [args floatValue];
    if(rotation_x > 180.0f){ rotation_x -= 360.0f; }
    if(rotation_x < -180.0f){ rotation_x += 360.0f; }
    [animationLayer setRotation_x:NUMFLOAT(rotation_x)];
}

- (void)yaw:(id)args
{
    ENSURE_SINGLE_ARG(args, NSNumber);
    
    rotation_y += [args floatValue];    
    if(rotation_y > 180.0f){ rotation_y -= 360.0f; }
    if(rotation_y < -180.0f){ rotation_y += 360.0f; }
    [animationLayer setRotation_y:NUMFLOAT(rotation_y)];
}

- (void)roll:(id)args
{
    ENSURE_SINGLE_ARG(args, NSNumber);
    
    rotation_z += [args floatValue];    
    if(rotation_z > 180.0f){ rotation_z -= 360.0f; }
    if(rotation_z < -180.0f){ rotation_z += 360.0f; }
    [animationLayer setRotation_z:NUMFLOAT(rotation_z)];
}

- (void)move:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    ENSURE_DICT(args);
    
    float vector[4];
    float matrix[16];
    
    glPushMatrix();
    
    glLoadIdentity();   
    
    vector[0] = [[args objectForKey:@"x"] floatValue];
    vector[1] = [[args objectForKey:@"y"] floatValue];
    vector[2] = [[args objectForKey:@"z"] floatValue];
    vector[3] = 0.0f;

    glRotatef(rotation_z, 0.0f, 0.0f, 1.0f);
    glRotatef(rotation_y, 0.0f, 1.0f, 0.0f);
    glRotatef(rotation_x, 1.0f, 0.0f, 0.0f);
    
    glGetFloatv(GL_MODELVIEW_MATRIX, matrix);

    [self multifv:vector matrix:matrix];
    /*
    NSLog(@"angle:(%f,%f,%f) src:(%f,%f,%f) vec:(%f,%f,%f)", 
          rotation_x, rotation_y, rotation_z,
          [[args objectForKey:@"x"] floatValue],[[args objectForKey:@"y"] floatValue],[[args objectForKey:@"z"] floatValue],
          vector[0],vector[1],vector[2]);
    */
    NSDictionary *translation = [NSDictionary dictionaryWithObjectsAndKeys:
                                 NUMFLOAT(translation_x+vector[0]),@"x",
                                 NUMFLOAT(translation_y+vector[1]),@"y",
                                 NUMFLOAT(translation_z+vector[2]),@"z",
                                 nil];
    NSDictionary *animateArgs = [NSDictionary dictionaryWithObjectsAndKeys:
                                 translation, @"translation", 
                                 NUMFLOAT(300), @"duration",
                                 nil];
    [self animate:[NSArray arrayWithObject:animateArgs]];
    
    
    glPopMatrix();
}

- (void)animate:(id)args
{
    ENSURE_UI_THREAD_1_ARG(args);
    
    ENSURE_ARRAY(args);
    
    id params = [args objectAtIndex:0];
    ENSURE_DICT(params);
    
    if([args count] > 1){
        id callback = [args objectAtIndex:1];
        ENSURE_TYPE(callback, KrollCallback);
        if(callback){
            animationCallback = callback;
        }
    }    
    
    float duration = [[params objectForKey:@"duration"] floatValue] / 1000.0f;
    
    NSArray *xyz = [NSArray arrayWithObjects:@"x",@"y",@"z", nil]; 
    SEL get, set;
    NSString *keyPath;
    
    for(NSString *axis in xyz){
        get = NSSelectorFromString([NSString stringWithFormat:@"rotation_%@", axis]);            
        set = NSSelectorFromString([NSString stringWithFormat:@"setRotation_%@:", axis]);            
        keyPath = [NSString stringWithFormat:@"rotation_%@",axis];

        if([params objectForKey:@"rotation"]){
            id rotation = [params objectForKey:@"rotation"];
            ENSURE_DICT(rotation);
            
            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:keyPath];
            anim.duration = duration;
            anim.fromValue = [self performSelector:get];
            anim.toValue = [rotation objectForKey:axis];
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            anim.delegate = self;
            
            [animationLayer addAnimation:anim forKey:keyPath];
            [animationLayer performSelector:set withObject:anim.toValue];
        }else{
            [animationLayer performSelector:set withObject:[self performSelector:get]];
        }
    }        
    
    for(NSString *axis in xyz){
        get = NSSelectorFromString([NSString stringWithFormat:@"translation_%@", axis]);            
        set = NSSelectorFromString([NSString stringWithFormat:@"setTranslation_%@:", axis]);            
        keyPath = [NSString stringWithFormat:@"translation_%@",axis];

        if([params objectForKey:@"translation"]){
            id translation = [params objectForKey:@"translation"];
            ENSURE_DICT(translation);
            
            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:keyPath];
            anim.duration = duration;
            anim.fromValue = [self performSelector:get];
            anim.toValue = [translation objectForKey:axis];
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            anim.delegate = self;
            
            [animationLayer addAnimation:anim forKey:keyPath];
            [animationLayer performSelector:set withObject:anim.toValue];
        }else{
            [animationLayer performSelector:set withObject:[self performSelector:get]];
        }
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{   
    if([[animationLayer animationKeys] count] == 0){
        [animationCallback call:nil thisObject:self];
        NSLog(@"animationDidStop.");
    }
}

- (void)dealloc
{
    RELEASE_TO_NIL(animationLayer);
    
    self.rotation_x = nil;
    self.rotation_y = nil;
    self.rotation_z = nil;
    
    self.translation_x = nil;
    self.translation_y = nil;
    self.translation_z = nil;
    
    [super dealloc];
}
@end
