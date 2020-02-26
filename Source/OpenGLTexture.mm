//
//  OpenGLTexture.mm
//  Atoms
//
//  Created by Emiel Lensink on 9/12/06.
//  Copyright 2006 Qixis. All rights reserved.
//

#import "OpenGLTexture.h"

unsigned int truncPowerOf2(unsigned int x)
{
	int i = 0;
	while (x = x >> 1) i++;
	return (1 << i);
}

bool TextureFromNSImage(NSImage *image, GLuint *texID, GLuint *width, GLuint *height)
{
    NSBitmapImageRep *sourceImageRep;
    GLenum imageFormat = GL_RGBA;
    GLubyte *sourcePic;
    long sourceRowBytes, pixelSize;
    NSSize imageSize;
	
    sourceImageRep = [[NSBitmapImageRep alloc]initWithData: [image TIFFRepresentation]];
	
    if ([sourceImageRep hasAlpha] == YES)
    {
		if ([sourceImageRep bitsPerPixel] != 32) return false;
		imageFormat = GL_RGBA;
		pixelSize = 4;
    }
    else
    {
		if ([sourceImageRep bitsPerPixel] != 24) return false;
		imageFormat = GL_RGB;
		pixelSize = 3;
    }
	
    sourceRowBytes = [sourceImageRep bytesPerRow];
    sourcePic = (GLubyte*) [sourceImageRep bitmapData];
    imageSize.width = [sourceImageRep pixelsWide];
    imageSize.height = [sourceImageRep pixelsHigh];
	
    //Do the OpenGL flip 
	{
		GLubyte *pic = (GLubyte *)malloc(imageSize.height * sourceRowBytes);
		GLuint i;

		for (i = 0; i < imageSize.height; i++)
		{
			memcpy (pic + (i * sourceRowBytes), sourcePic + ((((int)imageSize.height - i) - 1) *
					sourceRowBytes), sourceRowBytes);
		}
		sourcePic = pic;
    }
	
	glGenTextures(1, texID);
	
	NSLog(@"%X\n", *texID);
	
    glBindTexture(GL_TEXTURE_2D, *texID);
	
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, sourceRowBytes/pixelSize);
 	
    *width = truncPowerOf2(imageSize.width);
    *height = truncPowerOf2(imageSize.height);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
	
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glTexImage2D(GL_TEXTURE_2D, 0, imageFormat, *width, *height, 0, imageFormat, GL_UNSIGNED_BYTE, sourcePic);
	
    [sourceImageRep release];
	
	return true;
}

@implementation OpenGLTexture

// Initialization
- init
{
	self = [super init];
	if (self)
	{
		m_mTextures = new std::map<int, GLuint>;
	}
	return self;
}

// Destructor
- (void)dealloc
{
	delete m_mTextures;
	
	[super dealloc];
}

- (bool)loadTexture:(NSString *)filename number:(int)number
{
	NSImage *pImage = [NSImage alloc];
	[pImage initWithContentsOfFile:filename];
	
	GLuint ID;
	GLuint Width;
	GLuint Height;
	
	TextureFromNSImage(pImage, &ID, &Width, &Height);
	(*m_mTextures)[number] = ID;
	
	[pImage release];
	
	return true;
}

- (GLuint)getTextureName:(int)number
{
	return (*m_mTextures)[number];
}

@end
