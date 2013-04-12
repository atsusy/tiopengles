//
//  ComTiopengles3DModelProxy.m
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/10.
//  Copyright 2013 MARSHMALLOW MACHINE. All rights reserved.
//

#import "TiUtils.h"
#import "ComTiopengles3DModelProxy.h"
#import "ComTiopenglesModelData3ds.h"
#import "ComTiopenglesView.h"

#define BUFFER_OFFSET(bytes) ((GLubyte *)NULL + (bytes))

@implementation ComTiopengles3DModelProxy
@synthesize animationLayer;

+ (id)load3ds:(NSString *)path
{
    // load model
    return [[[ComTiopengles3DModelProxy alloc] initWith3dsPath:path] autorelease];
}

- (GLuint)loadTexture:(NSString *)path
{
    GLuint genId;

    NSString *type = [[path pathExtension] lowercaseString];
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
    self = [super init];
    if(self){
        NSString *type = [path pathExtension];
        NSString *name = [[path stringByDeletingPathExtension] lastPathComponent];
        NSString *directory = [path stringByDeletingLastPathComponent]; 
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:type inDirectory:directory]; 
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if(fileExists){
            dataSourcePath = [path retain];
            dataSource = [[ComTiopenglesModelData3ds alloc] initWithData:[NSData dataWithContentsOfFile:filePath]];
            animationLayer = [[ComTiopenglesAnimationLayer alloc] initWithTarget:self];
            animationCallbacks = [[NSMutableDictionary alloc] init];
            animationKeys = [[NSMutableDictionary alloc] init];
        }else{
            NSLog(@"[ERROR] 3ds file not exists:%@", path);
        }        
    }
    return self;
}

- (NSNumber *)rotation_x
{
    return [NSNumber numberWithFloat:rotation_x];
}

- (void)setRotation_x:(NSNumber *)value
{
    rotation_x = [value floatValue];
    [animationLayer setRotation_x:NUMFLOAT(rotation_x)];
}

- (NSNumber *)rotation_y
{
    return [NSNumber numberWithFloat:rotation_y];
}

- (void)setRotation_y:(NSNumber *)value
{
    rotation_y = [value floatValue];
    [animationLayer setRotation_y:NUMFLOAT(rotation_y)];
}

- (NSNumber *)rotation_z
{
    return [NSNumber numberWithFloat:rotation_z];
}

- (void)setRotation_z:(NSNumber *)value
{
    rotation_z = [value floatValue];
    [animationLayer setRotation_z:NUMFLOAT(rotation_z)];
}

- (NSNumber *)translation_x
{
    return [NSNumber numberWithFloat:translation_x];
}

- (void)setTranslation_x:(NSNumber *)value
{
    translation_x = [value floatValue];
    [animationLayer setTranslation_x:NUMFLOAT(translation_x)];
}

- (NSNumber *)translation_y
{
    return [NSNumber numberWithFloat:translation_y];
}

- (void)setTranslation_y:(NSNumber *)value
{
    translation_y = [value floatValue];
    [animationLayer setTranslation_y:NUMFLOAT(translation_y)];
}

- (NSNumber *)translation_z
{
    return [NSNumber numberWithFloat:translation_z];
}

- (void)setTranslation_z:(NSNumber *)value
{
    translation_z = [value floatValue];
    [animationLayer setTranslation_z:NUMFLOAT(translation_z)];
}

- (void)rotation:(id)value
{
    ENSURE_ARRAY(value);
    id rotationDic = [value objectAtIndex:0];
    ENSURE_DICT(rotationDic);
    
    [self setRotation_x:[rotationDic objectForKey:@"x"]];
    [self setRotation_y:[rotationDic objectForKey:@"y"]];
    [self setRotation_z:[rotationDic objectForKey:@"z"]];
}

- (void)translation:(id)value
{    
	ENSURE_ARRAY(value);
    id translationDic = [value objectAtIndex:0];
    ENSURE_DICT(translationDic);
    
    [self setTranslation_x:[translationDic objectForKey:@"x"]];
    [self setTranslation_y:[translationDic objectForKey:@"y"]];
    [self setTranslation_z:[translationDic objectForKey:@"z"]];
}

- (int)draw
{    
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    static float default_ambient[4] = {0.2, 0.2, 0.2, 1.0};
    static float default_diffuse[4] = {0.8, 0.8, 0.8, 1.0};
    static float default_specular[4] = {1.0, 1.0, 1.0, 1.0};
    static float default_shineness = 25.0;
    
    glTranslatef(translation_x, translation_y, translation_z);      
    glRotatef(rotation_z, 0.0, 0.0, 1.0);
    glRotatef(rotation_y, 0.0, 1.0, 0.0);
    glRotatef(rotation_x, 1.0, 0.0, 0.0);
    
    int trianglesCount = 0;
    MODEL_CHUNK *model_chunkp = [dataSource root];
    while(model_chunkp){
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
        
        unsigned int vsize, nsize, tsize;
        vsize = model_chunkp->num_vertices*3*sizeof(float);
        nsize = model_chunkp->num_normals *3*sizeof(float);
        tsize = model_chunkp->num_coords  *2*sizeof(float);
        
        if(!model_chunkp->vbo){
            glGenBuffers(1, &model_chunkp->vbo);
            glBindBuffer(GL_ARRAY_BUFFER, model_chunkp->vbo);
            glBufferData(GL_ARRAY_BUFFER, 
                         vsize+nsize+tsize,
                         NULL,
                         GL_STATIC_DRAW);
            glBufferSubData(GL_ARRAY_BUFFER, 
                            (GLintptr)BUFFER_OFFSET(0), 
                            (GLsizeiptr)vsize, 
                            (const GLvoid *)model_chunkp->vertices);
            glBufferSubData(GL_ARRAY_BUFFER, 
                            (GLintptr)BUFFER_OFFSET(vsize), 
                            (GLsizeiptr)nsize, 
                            (const GLvoid *)model_chunkp->normals);
            glBufferSubData(GL_ARRAY_BUFFER, 
                            (GLintptr)BUFFER_OFFSET(vsize+nsize), 
                            (GLsizeiptr)tsize, 
                            (const GLvoid *)model_chunkp->coords);
        }else{
            glBindBuffer(GL_ARRAY_BUFFER, model_chunkp->vbo);
        }
        
        glVertexPointer(3, GL_FLOAT, 0, 0);
        glNormalPointer(GL_FLOAT, 0, (GLvoid *)BUFFER_OFFSET(vsize));

        FACE *face = model_chunkp->faces;
        while (face != NULL) {
            if(!face->ibo){
                glGenBuffers(1, &face->ibo);
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, face->ibo);
                glBufferData(GL_ELEMENT_ARRAY_BUFFER, 
                             face->num_triangles*3*sizeof(unsigned short),
                             face->triangles,
                             GL_STATIC_DRAW);
            }else{
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, face->ibo);
            }
            
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
                    NSLog(@"[ERROR] texture not loaded path:%@", texture_path);
                }
            }
            
            if(face->material){
                glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, face->material->ambient);
                glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, face->material->diffuse);
                glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, face->material->specular);
                glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, face->material->shineness);
            }else{
                //NSLog(@"[DEBUG] material is NULL.");
                glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, default_ambient);
                glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, default_diffuse);
                glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, default_specular);
                glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, default_shineness);
            }

            if(face->material &&
               face->material->texture_id > 0){         
                glEnableClientState(GL_TEXTURE_COORD_ARRAY);
                glTexCoordPointer(2, GL_FLOAT, 0, BUFFER_OFFSET(vsize+nsize));        
                
                glBindTexture(GL_TEXTURE_2D, face->material->texture_id);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            }else{
                glDisableClientState(GL_TEXTURE_COORD_ARRAY);            
                glBindTexture(GL_TEXTURE_2D, 0);   
            }

            glDrawElements(GL_TRIANGLES, face->num_triangles*3, GL_UNSIGNED_SHORT, 0);
            trianglesCount += face->num_triangles;
            
            face = face->next;
        }
        
        if(model_chunkp->local_coordinate){
            glPopMatrix();
        }
        //NSLog(@"[DEBUG] model chunk faces:%d", model_chunkp->num_faces);
        model_chunkp = model_chunkp->next;
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);   
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);

    return trianglesCount;
}

- (NSString *)generateUuidString { 
    // create a new UUID which you own 
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault); 
    // create a new CFStringRef (toll-free bridged to NSString) 
    // that you own 
    NSString *uuidString = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid); 
    // transfer ownership of the string 
    // to the autorelease pool 
    [uuidString autorelease];
    // release the UUID 
    CFRelease(uuid);
    
    return uuidString; 
}

- (void)animate:(id)args
{
    ENSURE_UI_THREAD_1_ARG(args);

    ENSURE_ARRAY(args);
    
    id params = [args objectAtIndex:0];
    ENSURE_DICT(params);
    
    NSString *animationKey = [self generateUuidString];
    [animationKeys setObject:[[NSMutableArray alloc] init] forKey:animationKey];

    id callback;
    if([args count] > 1){
        callback = [args objectAtIndex:1];
        ENSURE_TYPE(callback, KrollCallback);
        
        [animationCallbacks setObject:callback forKey:animationKey];
    }    
    
    float duration = [[params objectForKey:@"duration"] floatValue] / 1000.0f;

    NSArray *xyz = [NSArray arrayWithObjects:@"x",@"y",@"z", nil]; 
    SEL get, set;
    NSString *key;
    NSString *keyPath;

    if([params objectForKey:@"rotation"]){
        id rotation = [params objectForKey:@"rotation"];
        ENSURE_DICT(rotation);
        
        for(NSString *axis in xyz){
            get = NSSelectorFromString([NSString stringWithFormat:@"rotation_%@", axis]);            
            set = NSSelectorFromString([NSString stringWithFormat:@"setRotation_%@:", axis]);            
            key = [NSString stringWithFormat:@"%@_rotation_%@", animationKey, axis];
            keyPath = [NSString stringWithFormat:@"rotation_%@",axis];
            
            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:keyPath];
            anim.duration = duration;
            anim.fromValue = [self performSelector:get];
            anim.toValue = [rotation objectForKey:axis];
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            anim.delegate = self;
            anim.removedOnCompletion = NO;

            [animationLayer addAnimation:anim forKey:key];
            [animationLayer performSelector:set withObject:anim.toValue];
            
            [[animationKeys valueForKey:animationKey] addObject:key];
        }        
    }
    
    if([params objectForKey:@"translation"]){
        id translation = [params objectForKey:@"translation"];
        ENSURE_DICT(translation);
        
        for(NSString *axis in xyz){
            get = NSSelectorFromString([NSString stringWithFormat:@"translation_%@", axis]);            
            set = NSSelectorFromString([NSString stringWithFormat:@"setTranslation_%@:", axis]);            
            key = [NSString stringWithFormat:@"%@_translation_%@", animationKey, axis];
            keyPath = [NSString stringWithFormat:@"translation_%@",axis];
            
            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:keyPath];
            anim.duration = duration;
            anim.fromValue = [self performSelector:get];
            anim.toValue = [translation objectForKey:axis];
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            anim.delegate = self;
            anim.removedOnCompletion = NO;
            
            [animationLayer addAnimation:anim forKey:key];
            [animationLayer performSelector:set withObject:anim.toValue];

            [[animationKeys valueForKey:animationKey] addObject:key];
        }        
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    NSMutableArray *stopped = [[NSMutableArray alloc] init];
    
    for(NSString *animationKey in animationKeys){
        NSMutableArray *keys = [animationKeys objectForKey:animationKey];
        for(NSString *key in keys){
            if([theAnimation isEqual:[animationLayer animationForKey:key]]){
                [animationLayer removeAnimationForKey:key];
                [keys removeObject:key];
                break;
            }
        }
    
        if([keys count] == 0){
            [stopped addObject:animationKey];
        }
    }
    
    for(NSString *key in stopped){
        KrollCallback *callback = [animationCallbacks objectForKey:key];
        [callback call:nil thisObject:self];

        [animationKeys removeObjectForKey:key];
        [animationCallbacks removeObjectForKey:key];
    }

    [stopped release];
}

- (void)dealloc
{
    RELEASE_TO_NIL(dataSourcePath);
    RELEASE_TO_NIL(dataSource);
    RELEASE_TO_NIL(animationLayer);
    RELEASE_TO_NIL(animationCallbacks);
    RELEASE_TO_NIL(animationKeys);
    
    self.rotation_x = nil;
    self.rotation_y = nil;
    self.rotation_z = nil;
    
    self.translation_x = nil;
    self.translation_y = nil;
    self.translation_z = nil;
    [super dealloc];
}
@end
