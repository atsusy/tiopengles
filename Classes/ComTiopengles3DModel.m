//
//  ComTiopengles3DModel.m
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/10.
//  Copyright 2011 LANGRISE Co.,Ltd. All rights reserved.
//

#import "ComTiopengles3DModel.h"
#import "TiUtils.h"
#import "ModelData3ds.h"

@implementation ComTiopengles3DModel

+ (id)load3ds:(NSString *)path
{
    // load model
    return [[[ComTiopengles3DModel alloc] initWith3dsPath:path] autorelease];
}

- (GLuint)loadTexture:(NSString *)path
{
    GLuint genId;

    NSString *type = [path pathExtension];
    NSString *name = [[path stringByDeletingPathExtension] lastPathComponent];
    NSString *directory = [path stringByDeletingLastPathComponent]; 

    // 画像を読み込み、32bit RGBA フォーマットのデータを取得
	NSString *filePath = [[NSBundle mainBundle] pathForResource:name 
                                                         ofType:type 
                                                    inDirectory:directory]; 
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSLog(@"[DEBUG] texture file not exists:%@", filePath);
        return 0;
    }

    UIImage *uiimage = [[UIImage alloc] initWithContentsOfFile:filePath];
    if(!uiimage){
        NSLog(@"[ERROR] cannot create UIImage.");
        return 0;
    }
    
    CGImageRef image = uiimage.CGImage;
    NSInteger width = CGImageGetWidth(image);
    NSInteger height = CGImageGetHeight(image);
    
    // texture must be 2^n pix, square, and max. size is 1024pix
    width = (NSInteger)pow(2, ceil(log2f((float)width)));
    height = (NSInteger)pow(2, ceil(log2f((float)height)));
    NSInteger size = (width > height) ? width : height;
    if(size > 1024){
        size = 1024;
    }
    GLubyte *bits = (GLubyte *)malloc(size * size * 4);
    CGContextRef textureContext = CGBitmapContextCreate(bits, 
                                                        size, 
                                                        size, 
                                                        8, 
                                                        size * 4,
                                                        CGImageGetColorSpace(image), 
                                                        kCGImageAlphaPremultipliedLast);
    //CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, size, size), image);
    UIGraphicsPushContext(textureContext);
    [uiimage drawInRect:CGRectMake(0, 0, size, size)];
    UIGraphicsPopContext();
    CGContextRelease(textureContext);
    
    // テクスチャを作成し、データを転送
    glGenTextures(1, &genId);
    glBindTexture(GL_TEXTURE_2D, genId);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size, size, 0, GL_RGBA, GL_UNSIGNED_BYTE, bits);
    GLenum error = glGetError();
    if(error){
        NSLog(@"[ERROR] glTextImage2D:%d", error);
    }
    glBindTexture(GL_TEXTURE_2D, 0);

    free(bits);
    [uiimage release];
    
    return genId;
}

- (id)initWith3dsPath:(NSString *)path
{    
    NSString *type = [path pathExtension];
    NSString *name = [[path stringByDeletingPathExtension] lastPathComponent];
    NSString *directory = [path stringByDeletingLastPathComponent]; 
    
	NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:type inDirectory:directory]; 
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if(fileExists){
        dataSourcePath = [path retain];
        dataSource = [[ModelData3ds alloc] initWithData:[NSData dataWithContentsOfFile:filePath]];
    }else{
        NSLog(@"[ERROR] 3ds file not exists:%@", path);
    }
    return self;
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
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    
    static float default_ambient[4] = {0.2, 0.2, 0.2, 1.0};
    static float default_diffuse[4] = {0.8, 0.8, 0.8, 1.0};
    static float default_specular[4] = {1.0, 1.0, 1.0, 1.0};
    static float default_shineness = 25.0;
    
    glTranslatef(translation[0], translation[1], translation[2]);      
    glRotatef(rotation[2], 0.0, 0.0, 1.0);
    glRotatef(rotation[1], 0.0, 1.0, 0.0);
    glRotatef(rotation[0], 1.0, 0.0, 0.0);
    
    for(id model_chunk in [dataSource model_chunks]){
        MODEL_CHUNK *model_chunkp = (MODEL_CHUNK *)[model_chunk unsignedIntValue];

        // local coordinate system
        if(model_chunkp->local_coordinate){
            glPushMatrix();
            /*
            float *p = model_chunkp->local_coordinate;
            float matrix[16] = {
                p[0], p[3],  p[6], 0.0f,
                p[1], p[4],  p[7], 0.0f,
                p[2], p[5],  p[8], 0.0f,
               -p[9],-p[10],-p[11],1.0f
            };
            glMultMatrixf(matrix);
             */
        }
        
        glVertexPointer(3, GL_FLOAT, 0, model_chunkp->vertices);
        glNormalPointer(GL_FLOAT, 0, model_chunkp->normals);
        
        FACE *face = model_chunkp->faces;
        while (face != NULL) {
            if(face->material && 
               face->material->texture_name && 
               face->material->texture_id == 0)
            {
                NSString *texture_path = [NSString stringWithFormat:@"%@/%@",  
                                          [dataSourcePath stringByDeletingLastPathComponent], 
                                          [NSString stringWithUTF8String:face->material->texture_name]];
                GLuint texture_id = [self loadTexture:texture_path];
                if(texture_id > 0){
                    face->material->texture_id = texture_id;
                    NSLog(@"[DEBUG] texture loaded id:%d path:%@", face->material->texture_id, texture_path);
                }else{
                    NSLog(@"[ERROR] texture not loaded path:%@", face->material->texture_id, texture_path);
                }
            }
            
            if(face->material){
                glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, face->material->ambient);
                glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, face->material->diffuse);
                glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, face->material->specular);
                glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, face->material->shineness);
            }else{
                NSLog(@"[DEBUG] material is NULL.");
                glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, default_ambient);
                glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, default_diffuse);
                glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, default_specular);
                glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, default_shineness);
            }
            
            if(face->material &&
               face->material->texture_id > 0)
            {            
                glEnableClientState(GL_TEXTURE_COORD_ARRAY);
                glTexCoordPointer(2, GL_FLOAT, 0, model_chunkp->coords);        
                
                glEnable(GL_TEXTURE_2D);
                glBindTexture(GL_TEXTURE_2D, face->material->texture_id);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            }else{
                glDisableClientState(GL_TEXTURE_COORD_ARRAY);            
                glBindTexture(GL_TEXTURE_2D, 0);   
            }
            glDrawElements(GL_TRIANGLES, face->num_triangles*3, GL_UNSIGNED_SHORT, face->triangles);
            
            //glPopMatrix();
            face = face->next;
        }
        
        if(model_chunkp->local_coordinate){
            glPopMatrix();
        }
        //NSLog(@"[DEBUG] model chunk faces:%d", model_chunkp->num_faces);
    }
    
    glBindTexture(GL_TEXTURE_2D, 0);   
}

- (void)dealloc
{
    RELEASE_TO_NIL(dataSourcePath);
    RELEASE_TO_NIL(dataSource);
    [super dealloc];
}
@end
