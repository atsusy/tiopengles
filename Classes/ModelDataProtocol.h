//
//  ModelDataProtocol.h
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/21.
//  Copyright 2011 Langrise Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>

typedef struct tagMaterial {
    char *name;
    float ambient[4]; // RGBA
    float diffuse[4]; // RGBA
    float specular[4];// RGBA
    int shineness; // 0 - 100
    char *texture_name;
    GLuint texture_id;// 0:not loaded >0:loaded
} MATERIAL;

typedef struct tagFace {
    // material
    char *material_name;
    MATERIAL *material; // NULL:not binded NOT NULL:binded
    // triangles
    int num_triangles;
    unsigned short *triangles;
    // link pointer
    struct tagFace *next;
} FACE;

typedef struct tagModelChunk
{
    // vertices
    float *vertices;
    int num_vertices;
    // normals
    int num_normals;
    float *normals;
    // texture coords
    int num_coords;
    float *coords; 
    // faces
    FACE *faces;
    // local coordinate system
    float *local_coordinate;
} MODEL_CHUNK;

@protocol ModelDataProtocol <NSObject>
// 
// array of model chunks
//
- (NSArray *)model_chunks;
@end

