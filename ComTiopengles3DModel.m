//
//  ComTiopengles3DModel.m
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/10.
//  Copyright 2011 LANGRISE Co.,Ltd. All rights reserved.
//

#import "ComTiopengles3DModel.h"
#import "cube.h"
#import <OpenGLES/ES1/gl.h>

@implementation ComTiopengles3DModel

+ (id)load:(NSString *)name
{
	NSLog(@"load model %@", name);
	return [[[ComTiopengles3DModel alloc] init] autorelease];
}

- (void)rotation:(id)value
{
    ENSURE_ARRAY(value);
    id rotationDic = [value objectAtIndex:0];
    ENSURE_DICT(rotationDic);
	rotation[0] = [[rotationDic objectForKey:@"x"] floatValue];
	rotation[1] = [[rotationDic objectForKey:@"y"] floatValue];
	rotation[2] = [[rotationDic objectForKey:@"z"] floatValue];
}

- (void)translation:(id)value
{    
	ENSURE_ARRAY(value);
    id translationDic = [value objectAtIndex:0];
    ENSURE_DICT(translationDic);
	translation[0] = [[translationDic objectForKey:@"x"] floatValue];
	translation[1] = [[translationDic objectForKey:@"y"] floatValue];
	translation[2] = [[translationDic objectForKey:@"z"] floatValue];
}

- (void)draw
{
	glLoadIdentity();
	glTranslatef(translation[0], translation[1], translation[2]);
	glRotatef(rotation[0], 1.0, 0.0, 0.0);
	glRotatef(rotation[1], 0.0, 1.0, 0.0);
	glRotatef(rotation[2], 0.0, 0.0, 1.0);
	glVertexPointer(3, GL_FLOAT, 0, CubeVertices);
	glNormalPointer(GL_FLOAT, 0, CubeNormals);
	glDrawArrays(GL_TRIANGLES, 0, kCubeNumberOfVertices);
}
@end
