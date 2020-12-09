//////////////////////////////////////////////////////////////////////////////
// DiscoFloor.m
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////////
#import "DiscoFloor.h"
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import <memory.h>
#import <math.h>
#import <time.h>

//////////////////////////////////////////////////////////////////////////////
// DiscoFloor implementation
//////////////////////////////////////////////////////////////////////////////
@implementation DiscoFloor

//////////////////////////////////////////////////////////////////////////////
// initWithSizeW:H:
//////////////////////////////////////////////////////////////////////////////
- initWithSizeW:(int)w H:(int)h
{
	srand((unsigned int)time(NULL));
	
	changeTime = 0;

	self = [super init];
	if (self)
	{
		m_texture = NULL;
	
		sizeW = w;
		sizeH = h;
	
		brightness = new float[w * h];
		hue = new float[w * h];
		
		for (int j=0; j<sizeH; j++)
			for (int i=0; i<sizeW; i++)
			{
				brightness[sizeW*j + i] = 1;	//(float)i/(float)sizeW;
				hue[sizeW*j + i] = ((float)rand() / (float)RAND_MAX) * 360.0;
			}
	}
	return self;
}

//////////////////////////////////////////////////////////////////////////////
// dealloc
//////////////////////////////////////////////////////////////////////////////
- (void)dealloc
{
	delete [] brightness;
	delete [] hue;

	[super dealloc];
}

- (void)prepare
{

	// Must run this in the correct opengl context
	// otherwise it would be in init...
	if (m_texture == NULL)
	{
		NSLog(@"DiscoFloor");
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *path = [bundle resourcePath];
		
		NSString *res1 = [path stringByAppendingString:@"/tile.png"];
		
		m_texture = [[OpenGLTexture alloc] init];		
		[m_texture loadTexture:res1 number:12];
	}
}

//////////////////////////////////////////////////////////////////////////////
// updateWithDiffTime:
//////////////////////////////////////////////////////////////////////////////
- (void)updateWithDiffTime:(float)diffTime
{
	changeTime += diffTime;
	
	if (changeTime < 0.4)
		return;
		
	changeTime = 0;
	
	for (int j=0; j<sizeH; j++)
		for (int i=0; i<sizeW; i++)
		{
			hue[sizeW*j + i] = ((float)rand() / (float)RAND_MAX) * 360.0;
			
//			if (hue[sizeW*j + i] >= 360)
//				hue[sizeW*j + i] = 0;
		}

}


void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v )
{
	int i;
	float f, p, q, t;
	if( s == 0 ) {
		// achromatic (grey)
		*r = *g = *b = v;
		return;
	}
	h /= 60;			// sector 0 to 5
	i = floor( h );
	f = h - i;			// factorial part of h
	p = v * ( 1 - s );
	q = v * ( 1 - s * f );
	t = v * ( 1 - s * ( 1 - f ) );
	switch( i ) {
		case 0:
			*r = v;
			*g = t;
			*b = p;
			break;
		case 1:
			*r = q;
			*g = v;
			*b = p;
			break;
		case 2:
			*r = p;
			*g = v;
			*b = t;
			break;
		case 3:
			*r = p;
			*g = q;
			*b = v;
			break;
		case 4:
			*r = t;
			*g = p;
			*b = v;
			break;
		default:		// case 5:
			*r = v;
			*g = p;
			*b = q;
			break;
	}
}

//////////////////////////////////////////////////////////////////////////////
// render
//////////////////////////////////////////////////////////////////////////////
- (void)render
{
//	static GLfloat materialAmbient[4] = { 0.1, 0.1, 0.1, 0.0 };
//	static GLfloat materialDiffuse[4] = { 0.3, 0.3, 0.3, 0.3 };
//	static GLfloat materialEmission[4] = { 0.0, 0.0, 0.0, 1.0 };



	glPushMatrix();



	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	int texnum = [m_texture getTextureName:12];
	glBindTexture(GL_TEXTURE_2D, texnum);







		int i,j;

//		glMaterialfv(GL_FRONT, GL_AMBIENT, materialAmbient);
//		glMaterialfv(GL_FRONT, GL_DIFFUSE, materialDiffuse);

		glTranslatef(-sizeW/2, 0, -sizeH/2);

		for (j=0; j<sizeH; j++)
		{
			for (i=0; i<sizeW; i++)
			{
				float h = hue[sizeW*j + i];
				float s = 1;
				float v = brightness[sizeW*j + i];
				float r,g,b;
				
				HSVtoRGB(&r,&g,&b,h,s,v);

				glBegin(GL_QUADS);
					glColor3f(r,g,b);
					
					glTexCoord2d(0.0,1.0); glVertex3f(i+0,0,j+0);
					glTexCoord2d(1.0,1.0); glVertex3f(i+0,0,j+1);
					glTexCoord2d(1.0,0.0); glVertex3f(i+1,0,j+1);
					glTexCoord2d(0.0,0.0); glVertex3f(i+1,0,j+0);
					
				glEnd();
			}
		}

	glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
		
	glPopMatrix();
}

@end
