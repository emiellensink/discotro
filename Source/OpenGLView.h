//////////////////////////////////////////////////////////////////////////////
// OpenGLView.h
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////////
#import <Cocoa/Cocoa.h>

@class Scene;

//////////////////////////////////////////////////////////////////////////////
// OpenGLView interface definition
//////////////////////////////////////////////////////////////////////////////
@interface OpenGLView : NSOpenGLView
{
    CVDisplayLinkRef displayLink;
    
	// The scene graph
	Scene *scene;
    CFAbsoluteTime timeBefore;
}

- (void)beginAnimation;

@end