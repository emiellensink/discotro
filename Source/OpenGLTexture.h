//
//  OpenGLTexture.h
//  Atoms
//
//  Created by Emiel Lensink on 9/12/06.
//  Copyright 2006 Qixis. All rights reserved.
//

#include <map>

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>

@interface OpenGLTexture : NSObject
{
	std::map<int, GLuint> *m_mTextures;
}

//- (void)newGame:(int)boardsize humans:(int)humans computers:(int)computers;
- (bool)loadTexture:(NSString *)filename number:(int)number;
- (GLuint)getTextureName:(int)number;

@end
