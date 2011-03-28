//
//  ModelData3ds.m
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/21.
//  Copyright 2011 Langrise Co.,Ltd. All rights reserved.
//

#import "ModelData3ds.h"

@implementation ModelData3ds

- (BOOL)normalize:(const float *)input to:(float *)output
{
    float len;
    float x, y, z;
    
    x = input[0];
    y = input[1];
    z = input[2];
    len = sqrt(x * x + y * y + z * z);
    
    if(len < (1e-6)) return NO;
    
    len = 1.0 / len;
    x *= len;
    y *= len;
    z *= len;
    
    output[0] = x;
    output[1] = y;
    output[2] = z;
    
    return YES;
}

- (BOOL)calculateNormal_p1:(const float *)p1 p2:(const float *)p2 p3:(const float *)p3 normal:(float *)n
{
	double v1[3];
	double v2[3];
	double cross[3];
	double length;
	int i;
    
	/* v1 = p1 - p2を求める */
	for (i = 0; i < 3; i++) {
		v1[i] = p1[i] - p2[i];
	}

	/* v2 = p3 - p2を求める */
	for (i = 0; i < 3; i++) {
		v2[i] = p3[i] - p2[i];
	}
    
	/* 外積v2×v1（= cross）を求める */    
	for (i = 0; i < 3; i++) {
		cross[i] = v2[(i+1)%3] * v1[(i+2)%3] - v2[(i+2)%3] * v1[(i+1)%3];        
	}
    
	/* 外積v2×v1の長さ|v2×v1|（= length）を求める */
	length = sqrt(cross[0] * cross[0] + 
                  cross[1] * cross[1] + 
                  cross[2] * cross[2]);
    
	/* 長さ|v2×v1|が0のときは法線ベクトルは求められない */
	if (length == 0.0f) {
		return NO;
	}
    
	/* 外積v2×v1を長さ|v2×v1|で割って法線ベクトルnを求める */
	for (i = 0; i < 3; i++) {
        if(cross[i] == 0.0f){
            cross[i] = fabs(cross[i]);
        }
        n[i] = cross[i] / length;
	}
	return YES;
}

- (void)allocAndCaluculateNormals:(MODEL_CHUNK *)model_chunkp
{
    //NSLog(@"[DEBUG] allocAndCaluculateNormals faces:%d vertices:%d", model_chunkp->num_faces, model_chunkp->num_vertices);
    // calculate normals
    if(model_chunkp->vertices){
        if(model_chunkp->normals){
            free(model_chunkp->normals);
        }
        model_chunkp->num_normals = model_chunkp->num_vertices;
        model_chunkp->normals = calloc(sizeof(float)*model_chunkp->num_vertices*3, 1);
        
        float p1[3], p2[3], p3[3];
        unsigned short f1, f2, f3;
        float normal[3];
        
        FACE *face = model_chunkp->faces;
        while(face != NULL){
            NSLog(@"[DEBUG] face triangles:%d", face->num_triangles);
            for(int i = 0; i < face->num_triangles; i++){
                f1 = face->triangles[i*3+0];
                f2 = face->triangles[i*3+1];
                f3 = face->triangles[i*3+2];
                
                p1[0] = model_chunkp->vertices[f1*3+0];
                p1[1] = model_chunkp->vertices[f1*3+1];
                p1[2] = model_chunkp->vertices[f1*3+2];
                
                p2[0] = model_chunkp->vertices[f2*3+0];
                p2[1] = model_chunkp->vertices[f2*3+1];
                p2[2] = model_chunkp->vertices[f2*3+2];
                
                p3[0] = model_chunkp->vertices[f3*3+0];
                p3[1] = model_chunkp->vertices[f3*3+1];
                p3[2] = model_chunkp->vertices[f3*3+2];
                
                normal[0] = 0.0f;
                normal[1] = 0.0f;
                normal[2] = 1.0f;
                if(![self calculateNormal_p1:p1 p2:p2 p3:p3 normal:normal]){
                    NSLog(@"[WARN] cannot calculate normal. (%f,%f,%f) (%f,%f,%f) (%f,%f,%f)",
                          p1[0], p1[1], p1[2], p2[0], p2[1], p2[2], p3[0], p3[1], p3[2]);
                }
                model_chunkp->normals[f1*3+0] = normal[0];
                model_chunkp->normals[f1*3+1] = normal[1];
                model_chunkp->normals[f1*3+2] = normal[2];
                model_chunkp->normals[f2*3+0] = normal[0];
                model_chunkp->normals[f2*3+1] = normal[1];
                model_chunkp->normals[f2*3+2] = normal[2];
                model_chunkp->normals[f3*3+0] = normal[0];
                model_chunkp->normals[f3*3+1] = normal[1];
                model_chunkp->normals[f3*3+2] = normal[2];
            }            
            face = face->next;
        }
    }    
}

- (void)bindFacesAndMaterials{
    for(id model_chunk in model_chunks){
        MODEL_CHUNK *model_chunkp = (MODEL_CHUNK *)[model_chunk unsignedIntValue];
        [self allocAndCaluculateNormals:model_chunkp];

        FACE *face = model_chunkp->faces;
        while(face != NULL){
            for(id material in materials){
                MATERIAL *materialp = (MATERIAL *)[material unsignedIntValue];
                if(strcmp(materialp->name, face->material_name) == 0){
                    face->material = materialp;
                    NSLog(@"[DEBUG] face material found:%@", [NSString stringWithUTF8String:materialp->name]);
                    break;
                }
            }
            face = face->next;
        }        
    }
}

- (id)initWithData:(NSData *)data
{
    dataSource = [data retain];
    model_chunks = [[NSMutableArray alloc] init];
    materials = [[NSMutableArray alloc] init];

    const unsigned char *ptr = [dataSource bytes];
    float *float_ptr = NULL;
    unsigned short *facedesc_ptr = NULL;

    unsigned short chunk_id;
    unsigned int chunk_length;
    unsigned short face_length;
    
    const unsigned char *ends = ptr + [data length];
    
    bool ambient, specular, diffuse, shineness;        

    MATERIAL *current_material = NULL;
    MODEL_CHUNK *current_model = NULL;
    FACE *current_face = NULL;
    
    while(ptr < ends)
    {
        // read chunk id
        chunk_id = *((unsigned short *)ptr);
        ptr += sizeof(unsigned short);
                
        // read chunk length
        chunk_length = *((int *)ptr);
        ptr += sizeof(int);
        
        //NSLog(@"[DEBUG] chunk_id:%x chunk_length:%x offset:%x", chunk_id, chunk_length, (char *)ptr - (const char *)[data bytes] - 6);        
        switch (chunk_id) {
            case 0x0010:
            case 0x0013:
                float_ptr = (float *)ptr;
                if(ambient){
                    current_material->ambient[0] = *(float_ptr+0);
                    current_material->ambient[1] = *(float_ptr+1);
                    current_material->ambient[2] = *(float_ptr+2);
                    current_material->ambient[3] = 1.0f;
                }
                if(specular){
                    current_material->specular[0] = *(float_ptr+0);
                    current_material->specular[1] = *(float_ptr+1);
                    current_material->specular[2] = *(float_ptr+2);
                    current_material->specular[3] = 1.0f;
                }
                if(diffuse){
                    current_material->diffuse[0] = *(float_ptr+0);
                    current_material->diffuse[1] = *(float_ptr+1);
                    current_material->diffuse[2] = *(float_ptr+2);
                    current_material->diffuse[3] = 1.0f;
                }
                ptr += sizeof(float) * 3;
                break;
            case 0x0011:
            case 0x0012:
                if(ambient){
                    current_material->ambient[0] = *(ptr+0) / 255.0f;
                    current_material->ambient[1] = *(ptr+1) / 255.0f;
                    current_material->ambient[2] = *(ptr+2) / 255.0f;
                    current_material->ambient[3] = 1.0f;
                    NSLog(@"[DEBUG] material    ambient(%x):(%f,%f,%f)", 
                          chunk_id, 
                          current_material->ambient[0], 
                          current_material->ambient[1], 
                          current_material->ambient[2]);
                }
                if(specular){
                    current_material->specular[0] = *(ptr+0) / 255.0f;
                    current_material->specular[1] = *(ptr+1) / 255.0f;
                    current_material->specular[2] = *(ptr+2) / 255.0f;
                    current_material->specular[3] = 1.0f;                    
                    NSLog(@"[DEBUG] material    specular(%x):(%f,%f,%f)", 
                          chunk_id, 
                          current_material->specular[0], 
                          current_material->specular[1], 
                          current_material->specular[2]);
                }
                if(diffuse){
                    current_material->diffuse[0] = *(ptr+0) / 255.0f;
                    current_material->diffuse[1] = *(ptr+1) / 255.0f;
                    current_material->diffuse[2] = *(ptr+2) / 255.0f;
                    current_material->diffuse[3] = 1.0f;
                    NSLog(@"[DEBUG] material    diffuse(%x):(%f,%f,%f)", 
                          chunk_id, 
                          current_material->diffuse[0], 
                          current_material->diffuse[1], 
                          current_material->diffuse[2]);
                }
                ptr += sizeof(unsigned char) * 3;
                break;
            case 0x0030:
                if(shineness){
                    current_material->shineness = *((unsigned short *)ptr);
                    NSLog(@"[DEBUG] material    shiness(%x):%d", chunk_id, current_material->shineness);
                }
                ptr += sizeof(unsigned short);
                break;
            case 0x0031:
                if(shineness){
                    float_ptr = (float *)ptr;
                    current_material->shineness = (int)(*float_ptr * 100);
                    NSLog(@"[DEBUG] material    shiness(%x):%d", chunk_id, current_material->shineness);
                }
                ptr += sizeof(float);
                break;
			case 0x4d4d: 
                break;    
			case 0x3d3d:
                break;
			case 0x4000: 
                NSLog(@"[DEBUG] model name:%@", [NSString stringWithUTF8String:(char *)ptr]);
                ptr += strlen((char *)ptr) + 1;
                break;
			case 0x4100:
                if(current_model){
                    [model_chunks addObject:[NSNumber numberWithUnsignedInt:(unsigned int)current_model]];
                }                     
                current_model = calloc(sizeof(MODEL_CHUNK),1);
                current_face = NULL;
                break;
			case 0x4110: 
                current_model->num_vertices = *((unsigned short *)ptr);
                ptr += sizeof(unsigned short);

                current_model->vertices = (float *)ptr;
                ptr += sizeof(float) * (current_model->num_vertices * 3);
				break;
			case 0x4120:
                face_length = *((unsigned short *)ptr);
                //NSLog(@"[DEBUG] faces length:%d",face_length);
                ptr += sizeof(unsigned short);
                
                facedesc_ptr = (unsigned short *)ptr;
                ptr += face_length * 4 * sizeof(unsigned short);
                break;
            case 0x4130:
                if(current_model->faces == NULL){
                    current_model->faces = calloc(sizeof(FACE), 1);
                    current_face = current_model->faces;
                }else{
                    current_face->next = calloc(sizeof(FACE), 1);
                    current_face = current_face->next;
                }
                current_face->material_name = (char *)ptr;
                ptr += strlen((char *)ptr) + 1;

                current_face->num_triangles = *((unsigned short *)ptr);
                current_face->num_triangles = current_face->num_triangles;
                ptr += sizeof(unsigned short);
                
                unsigned short *_triangles = (unsigned short *)ptr;
                current_face->triangles = calloc(sizeof(unsigned short)*3*current_face->num_triangles,1);
                for(int i = 0; i < current_face->num_triangles; i++){
                    current_face->triangles[i*3+0] = facedesc_ptr[_triangles[i]*4+0];
                    current_face->triangles[i*3+1] = facedesc_ptr[_triangles[i]*4+1];
                    current_face->triangles[i*3+2] = facedesc_ptr[_triangles[i]*4+2];                    
                }

                ptr += sizeof(unsigned short) * current_face->num_triangles;
                break;
			case 0x4140:
                current_model->num_coords = *((unsigned short *)ptr);
                ptr += sizeof(unsigned short);
                
                current_model->coords = (float *)ptr;
                ptr += sizeof(float) * (current_model->num_coords * 2);
                break;
            case 0x4160:
                float_ptr = (float *)ptr;
                /*
                NSLog(@"[DEBUG] local coord X1:(%f,%f,%f)",*(float_ptr+0),*(float_ptr+1),*(float_ptr+2));
                NSLog(@"[DEBUG] local coord X2:(%f,%f,%f)",*(float_ptr+3),*(float_ptr+4),*(float_ptr+5));
                NSLog(@"[DEBUG] local coord X3:(%f,%f,%f)",*(float_ptr+6),*(float_ptr+7),*(float_ptr+8));
                NSLog(@"[DEBUG] local coord  O:(%f,%f,%f)",*(float_ptr+9),*(float_ptr+10),*(float_ptr+11));
                 */
                current_model->local_coordinate = float_ptr;
                ptr += sizeof(float) * 12;
                break;
            case 0xAFFF:
                if(current_material){
                    [materials addObject:[NSNumber numberWithUnsignedInt:(unsigned int)current_material]];
                    current_material = NULL;
                }
                current_material = calloc(sizeof(MATERIAL),1);
                break;
            case 0xA000:
                NSLog(@"[DEBUG] material name:%@", [NSString stringWithUTF8String:(char *)ptr]);
                current_material->name = (char *)ptr;
                ptr += strlen((char *)ptr) + 1;
                break;
            case 0xA010:
                ambient  = YES;
                specular = NO;
                diffuse  = NO;
                break;
            case 0xA020:
                ambient  = NO;
                specular = NO;
                diffuse  = YES;
                break;
            case 0xA030:
                ambient  = NO;
                specular = YES;
                diffuse  = NO;
                break;
            case 0xA040:
                shineness = YES;
                break;
            case 0xA200:
                break;
            case 0xA300:
                NSLog(@"[DEBUG] material    texture name:%@", [NSString stringWithUTF8String:(char *)ptr]);
                current_material->texture_name = (char *)ptr;
                ptr += strlen((char *)ptr) + 1;
                break;
                
            default:
                // chunk length include id and length(6 bytes)
                ptr += chunk_length - 6; 
                break;
        }
    }
    
    if(current_material){
        [materials addObject:[NSNumber numberWithUnsignedInt:(unsigned int)current_material]];
    }
    
    if(current_model){
        [model_chunks addObject:[NSNumber numberWithUnsignedInt:(unsigned int)current_model]];
    }
    
    [self bindFacesAndMaterials];
    
    //NSLog(@"[DEBUG] initWithData completed.");    
    return self;
}

- (void)dealloc
{
    [dataSource release];
    for(id material in materials){
        MATERIAL *material_p = (MATERIAL *)[material unsignedIntValue];
        free(material_p);
    }
    [materials release];
    for(id model_chunk in model_chunks){
        MODEL_CHUNK *model_chunkp = (MODEL_CHUNK *)[model_chunk unsignedIntValue];
        if(model_chunkp->faces){
            FACE *face = model_chunkp->faces;
            while(face != NULL){
                if(face->next != NULL){
                    FACE *next = face->next;
                    free(face->triangles);
                    free(face);
                    face = next;
                }else{
                    free(face->triangles);
                    free(face);
                    face = NULL;
                }
            }
            model_chunkp->faces = NULL;
        }
        if(model_chunkp->normals){
            free(model_chunkp->normals);
            model_chunkp->normals = NULL;
        }
        free(model_chunkp);
    }
    [model_chunks release];
    
    [super dealloc];
}

- (NSArray *)model_chunks
{
    return model_chunks;
}


@end
