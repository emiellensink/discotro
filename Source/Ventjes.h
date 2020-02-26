//
//  Ventjes.h
//  Discotro
//
//  Created by Emiel Lensink on 28/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OpenGLTexture.h"

@interface Ventjes : NSObject 
{
	OpenGLTexture *m_texture;
	
	float bounce;
	
	float scrollcalc;
	int scrollpos;
}

- init;

- (void)prepare;

- (void)updateWithDiffTime:(float)diffTime;
- (void)render;

@end
