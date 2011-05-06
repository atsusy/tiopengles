//
//  Texture2D.m
//  ParticleEmitterDemo
//
// Copyright (c) 2010 71Squared
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <OpenGLES/ES1/glext.h>
#import "Texture2D.h"
#import "Global.h"

#define kMaxTextureSize	1024

@implementation Texture2D

@synthesize contentSize;
@synthesize pixelFormat;
@synthesize width;
@synthesize height;
@synthesize name;
@synthesize maxS;
@synthesize maxT;
@synthesize textureRatio;

- (void)dealloc
{

	// If this instance is deallocated then delete the texture from OpenGL
	if(name)
	 glDeleteTextures(1, &name);
	
	[super dealloc];
}

- (id)initWithImage:(UIImage*)aImage filter:(GLenum)aFilter {
    
    self = [super init];
    if(self != nil) {
    
        // Create a variable which will store the CGImageRef from the image which has been passed in
        CGImageRef image;        
        
        // Grab the CGImage from the image which has been passed in
        image = [aImage CGImage];
        
        // Check to make sure we have been able to get the CGImage from the Image passed in.  If not then 
		// raise an error.  We don't want the application to continue as a missing image could create unexpected
		// results
		NSAssert(image, @"ERROR - Texture2D: The supplied UIImage was null.");
        
        // Check to see if the image contains alpha information by reading the alpha info from the image
        // supplied.  Set hasAlpha accordingly
        CGImageAlphaInfo info = CGImageGetAlphaInfo(image);
        BOOL hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || 
                    (info == kCGImageAlphaPremultipliedFirst) || 
                    (info == kCGImageAlphaLast) || 
                    (info == kCGImageAlphaFirst) ? YES : NO);
        
        // Check to see what pixel format the image is using
        if(CGImageGetColorSpace(image)) {
            if(hasAlpha)
                pixelFormat = kTexture2DPixelFormat_RGBA8888;
            else
                pixelFormat = kTexture2DPixelFormat_RGB565;
        } else  //NOTE: No colorspace means a mask image
            pixelFormat = kTexture2DPixelFormat_A8;
        
        // Set the imageSize to the size of the image which has been passed in
        contentSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));

        // We need to make sure that the texture we create is power of 2 so start at 1 and then multiply
        // i by 2 until i is greater than the width-1 of the image.  This will give us our power of 2 width
        // and will be set as the textures width.
        NSUInteger pot; // Holds the power of 2 value being calculated
        
        width = contentSize.width;
        if((width != 1) && (width & (width - 1))) {
            pot = 1;
            while( pot < width)
                pot *= 2;
            width = pot;
        }
        
        // Do the same power of 2 check for the height of the image
        height = contentSize.height;
        if((height != 1) && (height & (height - 1))) {
            pot = 1;
            while(pot < height)
                pot *= 2;
            height = pot;
        }
        
		// Load up Identity matrix for the affine transform
        CGAffineTransform transform = CGAffineTransformIdentity;

        // Now that we have created a width and height which is power of 2 and will contain our image
        // we need to make sure that the texture is now not bigger than 1024 x 1024 which is the largest
        // single texture size the iPhone can handle.  If it is too big then the image is scaled down by
        // 50%
        while((width > kMaxTextureSize) || (height > kMaxTextureSize)) {
            width /= 2;
            height /= 2;
            transform = CGAffineTransformScale(transform, 0.5, 0.5);
            contentSize.width *= 0.5;
            contentSize.height *= 0.5;
        }
        
        // Based on the pixel format we have read in from the image we are processing, allocate memory to hold
        // an image the size of the newly calculated power of 2 width and height.  Also create a bitmap context
        // using that allocated memory of the same size into which the image will be rendered
        CGColorSpaceRef colorSpace;
        CGContextRef context = nil;
        GLvoid* data = nil;
        
        switch(pixelFormat) {		
            case kTexture2DPixelFormat_RGBA8888:
                colorSpace = CGColorSpaceCreateDeviceRGB();
                data = malloc(height * width * 4);
                context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
                CGColorSpaceRelease(colorSpace);
                break;
                
            case kTexture2DPixelFormat_RGB565:
                colorSpace = CGColorSpaceCreateDeviceRGB();
                data = malloc(height * width * 4);
                context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
                CGColorSpaceRelease(colorSpace);
                break;
                
            case kTexture2DPixelFormat_A8:
                data = malloc(height * width);
                context = CGBitmapContextCreate(data, width, height, 8, width, NULL, kCGImageAlphaOnly);
                break;				
            default:
                [NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
        }
     
        // Now we have the pixelformat info we need we clear the context we have just created and into which the
        // image will be rendered
        CGContextClearRect(context, CGRectMake(0, 0, width, height));
        
        // We now need to move the origin with the context we have created.  We want to render the image into
        // the CG context so that the bottom of the rendered image will be at the bottom of the newly created
        // context.  To do this we move the Y element of the origin (which is the top left corner) down by the
        // difference between the image height and the context height
        CGContextTranslateCTM(context, 0, height - contentSize.height);

        
        // If transform is something other than the identity matrix then apply that transform to the
        // context. This is normally set due to the texture size being greater than the max allowed
        // and the texture therefore being scaled to 0.5 of its size.
        if(!CGAffineTransformIsIdentity(transform))
            CGContextConcatCTM(context, transform);
        
        // Now we are done with the setup, we can render the image which was passed in into the new context
        // we have created.  It will then be the data from this context which will be used to create
        // the OpenGL texture.
        CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
		
		// If the pixel format is RGB565 then sort out the image data.
		if(pixelFormat == kTexture2DPixelFormat_RGB565) {
			void* tempData = malloc(height * width * 2);
			unsigned int *inPixel32 = (unsigned int*)data;
			unsigned short *outPixel16 = (unsigned short*)tempData;
			for(int i = 0; i < width * height; ++i, ++inPixel32)
				*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | 
					((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | 
					((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
			free(data);
			data = tempData;	
		}

        // Generate a new OpenGL texture name and bind to it
        glGenTextures(1, &name);
        glBindTexture(GL_TEXTURE_2D, name);
        
        // Configure the textures min and mag filters.  This MUST happen for textures to show up on the iPhone
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, aFilter);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, aFilter);

        // Based on the pixel format of the image, use glTexImage2D to load the data from the CG context
        // into the new GL texture
        switch(pixelFormat) {
            case kTexture2DPixelFormat_RGBA8888:
                glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
                break;
            case kTexture2DPixelFormat_RGB565:
                glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data);
                break;
            case kTexture2DPixelFormat_A8:
                glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, width, height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
                break;
            default:
                [NSException raise:NSInternalInconsistencyException format:@""];
        }
        
        // We need to calculate the maximum texture coordinates for our image within the texture.
        // As the texture size is power of 2 and could be therefore larger than the actual image
        // which it contains, we need to calculate the maximum s, t values using the size of the 
        // content and the size of the texture
        maxS = contentSize.width / (float)width;
        maxT = contentSize.height / (float)height;
        
        // So that we can convert pixels into texture coordinates easily we need to calculate
        // the pixel to texture ratio for this texture.  Remember that the maximum s, t texture
        // coordinates you can have are 1.0, 1.0f.  Behavior if the texture coordinates are 
        // greatee than 1.0f will be based on the clamping and wrapping configuraton for this
        // texture.
        textureRatio.width = 1.0f / (float)width;
        textureRatio.height = 1.0f / (float)height;
        
        // We are now done with the CG context so we can release it and the memory we allocated to 
        // store the data within the context
        CGContextRelease(context);
        free(data);
    }
	
	// Return self with aurorelease.  The receiver is responsbile for retaining this instance
	return self;
}

@end
