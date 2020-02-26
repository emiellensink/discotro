//////////////////////////////////////////////////////////////////////////////
//  Scene.m
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////////
#import "Scene.h"
#import "InputManager.h"
#import "DiscoFloor.h"
#import "Ventjes.h"
#import "Ball.h"
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import <math.h>

//////////////////////////////////////////////////////////////////////////////
// Scene implementation
//////////////////////////////////////////////////////////////////////////////
@implementation Scene

//////////////////////////////////////////////////////////////////////////////
// init
//////////////////////////////////////////////////////////////////////////////
- init
{
	self = [super init];
	if (self)
	{
		inputManager = [[InputManager alloc] init];
		discofloor = [[DiscoFloor alloc] initWithSizeW:10 H:10];
		ventjes = [[Ventjes alloc] init];
		ball = [[Ball alloc] initWithRadius:0.5];
		oldTime = CFAbsoluteTimeGetCurrent();
		
		NSBundle *bundle = [NSBundle mainBundle];
        NSURL *music = [bundle URLForResource:@"discotro" withExtension:@"m4a"];
        
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:music error:nil];
        		
		offset = 0;
	}
	return self;
}

//////////////////////////////////////////////////////////////////////////////
// dealloc
//////////////////////////////////////////////////////////////////////////////
- (void)dealloc
{
	[discofloor release];
	[ventjes release];
	[ball release];
	[inputManager release];
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////////////
// getInputManager
//////////////////////////////////////////////////////////////////////////////
- (InputManager *)getInputManager
{
	return inputManager;
}

//////////////////////////////////////////////////////////////////////////////
// setViewportRect
//////////////////////////////////////////////////////////////////////////////
- (void)setViewportRect:(NSRect)bounds
{
	glViewport(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(60, bounds.size.width / bounds.size.height, 1.0, 1000.0);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
}

- (void)prepare
{
	[ventjes prepare];
	[discofloor prepare];

    player.numberOfLoops = -1;
    [player play];
}


//////////////////////////////////////////////////////////////////////////////
// updateScene:
//////////////////////////////////////////////////////////////////////////////
- (void)updateScene:(float)diffTime
{
	float accX = 0;
	float accZ = 0;
	
	if (inputManager->keyLeft)	accX -= 5;		// 1 m/s^2 acceleration
	if (inputManager->keyRight)	accX += 5;
	if (inputManager->keyUp)	accZ -= 5;
	if (inputManager->keyDown)	accZ += 5;
	
	[ball setAccelerationX:accX Z:accZ];

	[discofloor updateWithDiffTime:diffTime];
	[ventjes updateWithDiffTime:diffTime];
	[ball updateWithDiffTime:diffTime];
	
	offset += diffTime / 2.5f;
}

//////////////////////////////////////////////////////////////////////////////
// render
//////////////////////////////////////////////////////////////////////////////
- (void)render
{
    CFAbsoluteTime newTime = CFAbsoluteTimeGetCurrent();
	double diffTime = newTime - oldTime;
	oldTime = newTime;

	// Update scene
	[self updateScene:diffTime];

	// Set up rendering state
	glEnable(GL_DEPTH_TEST);
	glDisable(GL_CULL_FACE);
	glDisable(GL_LIGHTING);

	// Clear the framebuffer
	glClearColor(0, 0, 0, 0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	
	vec3_t ballPos;
	[ball getPosition:&ballPos];
	
	gluLookAt(sin(offset * 1.3) * 3.5f, 6.0, 2.5f * cos(offset / 1.239f) + 9.0f, 0, 2, 0, 0, 1, 0);

	{
		// Render the floor
		[discofloor render];
		[ventjes render];
	}
	
	glPopMatrix();

	// Flush out any unfinished rendering before swapping
	glFinish();
}

@end
