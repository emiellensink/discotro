//////////////////////////////////////////////////////////////////////////////
// OpenGLView.m
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////////
#import "OpenGLView.h"
#import "Scene.h"
#include <stdlib.h>

#include <OpenGL/OpenGL.h>
#include <OpenGL/gl.h>

//////////////////////////////////////////////////////////////////////////////
// OpenGLView implementation
//////////////////////////////////////////////////////////////////////////////
@implementation OpenGLView

//////////////////////////////////////////////////////////////////////////////
// dealloc
//////////////////////////////////////////////////////////////////////////////
- initWithFrame:(NSRect)frameRect
{
    NSLog(@"initWithFrame");
    
    // Pixel Format Attributes for the View-based (non-FullScreen) NSOpenGLContext
    NSOpenGLPixelFormatAttribute attrs[] =
    {
        // Specifying "NoRecovery" gives us a context that cannot fall back
        // to the software renderer. This makes the View-based context a
        // compatible with the fullscreen context, enabling us to use
        // the "shareContext" feature to share textures, display lists,
        // and other OpenGL objects between the two.
        NSOpenGLPFANoRecovery,
        
        // Attributes Common to FullScreen and non-FullScreen
        NSOpenGLPFAColorSize, (NSOpenGLPixelFormatAttribute)24,
        NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)16,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAAccelerated,
        (NSOpenGLPixelFormatAttribute)0
    };
    
    GLint rendererID;
    
    // Create our non-FullScreen pixel format.
    NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    
    // Just as a diagnostic, report the renderer ID that this pixel format binds to.
    // CGLRenderers.h contains a list of known renderers and their corresponding RendererID codes.
    [pixelFormat getValues:&rendererID forAttribute:NSOpenGLPFARendererID forVirtualScreen:0];
    NSLog(@"NSOpenGLView pixelFormat RendererID = %08x", (unsigned)rendererID);
    
    self = [super initWithFrame:frameRect pixelFormat:pixelFormat];
    if (self)
    {
        scene = [[Scene alloc] init];
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////
// awakeFromNib
//////////////////////////////////////////////////////////////////////////////
- (void)beginAnimation
{
    NSLog(@"Awake");

    // Create a display link capable of being used with all active displays
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
    
    // Set the renderer output callback function
    CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, self);
    
    // Set the display link for the current renderer
    CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
    CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);
    
    // Activate the display link
    CVDisplayLinkStart(displayLink);
}

// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    CVReturn result = [(OpenGLView*)displayLinkContext getFrameForTime:outputTime];
    return result;
}
 
- (CVReturn)getFrameForTime:(const CVTimeStamp*)outputTime
{
    // Ehm?
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay:YES];
    });
    
    return kCVReturnSuccess;
}

//////////////////////////////////////////////////////////////////////////////
// dealloc
//////////////////////////////////////////////////////////////////////////////
- (void)dealloc
{
    // Release the display link
    CVDisplayLinkRelease(displayLink);
    
    [scene release];
    [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////
// prepareOpenGL
//////////////////////////////////////////////////////////////////////////////
- (void)prepareOpenGL
{
    [super prepareOpenGL];
    // Set VBL synching
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
    
    [scene prepare];
}

//////////////////////////////////////////////////////////////////////////////
// drawRect
//////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(NSRect)aRect
{
    // Delegate to our scene object for rendering
    [scene render];
    [[self openGLContext] flushBuffer];
}

//////////////////////////////////////////////////////////////////////////////
// reshape
//////////////////////////////////////////////////////////////////////////////
- (void)reshape
{
    [super reshape];
    CGFloat factor = [NSScreen mainScreen].backingScaleFactor;
    CGRect newBounds = CGRectMake(0, 0, self.bounds.size.width * factor, self.bounds.size.height * factor);
    [scene setViewportRect: newBounds];
}

//////////////////////////////////////////////////////////////////////////////
// keyDown
//////////////////////////////////////////////////////////////////////////////
- (void)keyDown:(NSEvent *)theEvent
{
    [[scene getInputManager] keyDown:theEvent];
    
    /*
     //	NSLog([theEvent characters]);
     
     unsigned int modifierFlags = [theEvent modifierFlags];
     unichar ch = [[theEvent characters] characterAtIndex:0];
     
     if ((modifierFlags & NSFunctionKeyMask)  && (ch == NSRightArrowFunctionKey))
     [scene keyPressed:TRUE];
     
     [[scene getInputManager] keyDown:theEvent];
     
     //	if (![theEvent isARepeat])
     //		NSLog(@"keyDown");
     //	[self setNeedsDisplay:YES];
     */
}

//////////////////////////////////////////////////////////////////////////////
// keyUp
//////////////////////////////////////////////////////////////////////////////
- (void)keyUp:(NSEvent *)theEvent
{
    [[scene getInputManager] keyUp:theEvent];
    
    /*
     //	if (([theEvent modifierFlags] & NSFunctionKeyMask) == NSRightArrowFunctionKey)
     //	if ([theEvent keyCode] == 0x7C)
     
     unsigned int modifierFlags = [theEvent modifierFlags];
     unichar ch = [[theEvent characters] characterAtIndex:0];
     
     if ((modifierFlags & NSFunctionKeyMask)  && (ch == NSRightArrowFunctionKey))
     [scene keyPressed:FALSE];
     
     //	if ([theEvent keyCode] == kLeftArrowCharCode)
     //		[scene keyPressed:FALSE];
     //	NSLog(@"keyUp");
     */
}

//////////////////////////////////////////////////////////////////////////////
// acceptsFirstResponder
//////////////////////////////////////////////////////////////////////////////
- (BOOL)acceptsFirstResponder
{
    // We want this view to be able to receive key events
    return YES;
}

@end
