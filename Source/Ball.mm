//////////////////////////////////////////////////////////////////////////////
// Ball.m
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////////
#import "Ball.h"
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>

//////////////////////////////////////////////////////////////////////////////
// Ball implementation
//////////////////////////////////////////////////////////////////////////////
@implementation Ball

//////////////////////////////////////////////////////////////////////////////
// initWithRadius:
//////////////////////////////////////////////////////////////////////////////
- initWithRadius:(float)radius
{
	self = [super init];
	if (self)
	{
		ballRadius = radius;
		
		acceleration.x = 0;
		acceleration.y = 0;
		acceleration.z = 0;
		
		velocity.x = 0;
		velocity.y = 0;
		velocity.z = 0;
		
		position.x = 0;
		position.y = 0;
		position.z = 0;

		QuatSetRotation(&rotationQuat, 0, 0,0,0);
	}
	return self;
}

//////////////////////////////////////////////////////////////////////////////
// dealloc
//////////////////////////////////////////////////////////////////////////////
- (void)dealloc
{
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////////////
// updateWithDiffTime:
//////////////////////////////////////////////////////////////////////////////
- (void)updateWithDiffTime:(float)diffTime
{
	vec3_t oldPos = position;

	// Update ball position
	{
		float finalAccX = acceleration.x + (-velocity.x * 0.4);
		float finalAccZ = acceleration.z + (-velocity.z * 0.4);

		velocity.x += (finalAccX * diffTime);
		velocity.z += (finalAccZ * diffTime);

		position.x += (velocity.x * diffTime);
		position.z += (velocity.z * diffTime);
	}
	
	// Update ball rotation
	{
		quat_t qdr;
		
		// Calculate circle circumference
		float circumference = ballRadius * 2.0 * M_PI;
		
		float rotX = ((position.z - oldPos.z) / circumference) * 360.0;
		float rotZ = ((position.x - oldPos.x) / circumference) * 360.0;

		// Rotation around x-axis
		QuatSetRotation(&qdr, rotX, 1,0,0);
		QuatMultiply(&rotationQuat, &rotationQuat, &qdr);

		// Rotation around z-axis
		QuatSetRotation(&qdr, rotZ, 0,0,-1);
		QuatMultiply(&rotationQuat, &rotationQuat, &qdr);
	}

}

//////////////////////////////////////////////////////////////////////////////
// render
//////////////////////////////////////////////////////////////////////////////
- (void)render
{
	GLfloat materialAmbient[4] = { 0.1, 0.1, 0.1, 0.0 };
	GLfloat materialDiffuse[4] = { 1.0, 1.0, 1.0, 1.0 };

	glPushMatrix();

		glTranslatef(position.x, position.y + ballRadius, position.z);
		
		{
			float rotMat[16];
			QuatCreateMatrix(&rotationQuat, rotMat);
			glMultMatrixf(rotMat);
		}
		
		glShadeModel(GL_FLAT);

		GLUquadric *quadric = gluNewQuadric();
		gluQuadricTexture(quadric, GL_TRUE);
		glMaterialfv(GL_FRONT, GL_AMBIENT, materialAmbient);
		glMaterialfv(GL_FRONT, GL_DIFFUSE, materialDiffuse);

		gluSphere(quadric, ballRadius, 24, 16);
		gluDeleteQuadric(quadric);

	glPopMatrix();
}

//////////////////////////////////////////////////////////////////////////////
// setAccelerationX:Z:
//////////////////////////////////////////////////////////////////////////////
- (void)setAccelerationX:(float)x Z:(float)z
{
	acceleration.x = x;
	acceleration.z = z;
}

//////////////////////////////////////////////////////////////////////////////
// getPosition:
//////////////////////////////////////////////////////////////////////////////
- (void)getPosition:(vec3_t *)pos
{
	*pos = position;
}

@end
