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


- (id)position
{
    return [NSDictionary dictionaryWithObjectsAndKeys:NUMFLOAT(position[0]),@"x",NUMFLOAT(position[1]),@"y",NUMFLOAT(position[2]),@"z",nil];
}

- (void)setPosition:(id)value
{
    ENSURE_DICT(value);
    position[0] = [[value objectForKey:@"x"] floatValue];
    position[1] = [[value objectForKey:@"y"] floatValue];
    position[2] = [[value objectForKey:@"z"] floatValue];
}

- (id)angle
{
    return [NSDictionary dictionaryWithObjectsAndKeys:NUMFLOAT(angle[0]),@"x",NUMFLOAT(angle[1]),@"y",NUMFLOAT(angle[2]),@"z",nil];
}

- (void)setAngle:(id)value
{
    ENSURE_DICT(value);
    angle[0] = [[value objectForKey:@"x"] floatValue];
    angle[1] = [[value objectForKey:@"y"] floatValue];
    angle[2] = [[value objectForKey:@"z"] floatValue];
}

- (void)loadMatrix
{
    glRotatef(-angle[0], 1.0f, 0.0f, 0.0f);
    glRotatef(-angle[1], 0.0f, 1.0f, 0.0f);
    glRotatef(-angle[2], 0.0f, 0.0f, 1.0f);
    glTranslatef(-position[0], -position[1], -position[2]);
    
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
    
    angle[0] += [args floatValue];
    if(angle[0] > 180.0f){ angle[0] -= 360.0f; }
    if(angle[0] < -180.0f){ angle[0] += 360.0f; }
}

- (void)yaw:(id)args
{
    ENSURE_SINGLE_ARG(args, NSNumber);
    
    angle[1] += [args floatValue];    
    if(angle[1] > 180.0f){ angle[1] -= 360.0f; }
    if(angle[1] < -180.0f){ angle[1] += 360.0f; }
}

- (void)roll:(id)args
{
    ENSURE_SINGLE_ARG(args, NSNumber);
    
    angle[2] += [args floatValue];    
    if(angle[2] > 180.0f){ angle[2] -= 360.0f; }
    if(angle[2] < -180.0f){ angle[2] += 360.0f; }
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

    glRotatef(angle[2], 0.0f, 0.0f, 1.0f);
    glRotatef(angle[1], 0.0f, 1.0f, 0.0f);
    glRotatef(angle[0], 1.0f, 0.0f, 0.0f);
    
    glGetFloatv(GL_MODELVIEW_MATRIX, matrix);

    [self multifv:vector matrix:matrix];
    /*
    NSLog(@"angle:(%f,%f,%f) src:(%f,%f,%f) vec:(%f,%f,%f)", 
          angle[0], angle[1], angle[2],
          [[args objectForKey:@"x"] floatValue],[[args objectForKey:@"y"] floatValue],[[args objectForKey:@"z"] floatValue],
          vector[0],vector[1],vector[2]);
     */
    position[0] += vector[0];
    position[1] += vector[1];
    position[2] += vector[2];
    
    glPopMatrix();
}

- (void)dealloc
{
    self.position = nil;
    self.angle = nil;
    [super dealloc];
}
@end
