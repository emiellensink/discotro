//
//  Ventjes.mm
//  Discotro
//
//  Created by Emiel Lensink on 28/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Ventjes.h"
#include <algorithm>
#include <vector>


int CharacterOffsets[]=
{
	0,		// a
	17,		// b
	34,		// c
	57,		// d
	78,		// e
	93,		// f
	108,	// g
	127,	// h
	144,	// i
	154,	// j
	165,	// k
	186,	// l
	198,	// m
	221,	// n
	237,	// o
	261,	// p
	277,	// q
	299,	// r
	317,	// s
	330,	// t
	346,	// u
	363,	// v
	381,	// w
	403,	// x
	419,	// y
	435,	// z
	452,	// !
	464,	// ?
	480,	// .
	493,	// #
	512
};

const char *scrolltext = "                                                                       " \
" THE HOLLOW CHOCOLATE BUNNIES OF THE APOCALYPSE PRESENT THEIR FIRST" \
" DISCOTRO EVER AND IT WAS ABOUT TIME. THIS LONG AND BORING SCROLLER" \
" WILL TELL YOU THAT WE ARE A GROUP OF DUTCH SCENERS WHO MADE THIS" \
" RELEASE ENTIRELY AT THE PARTY. IT WILL ALSO TELL YOU THAT THE CODING WAS" \
" DONE BY QLONE AND PACMAN OF HCBA AND ALSO THAT THEY DID THE GRAPHICS AND" \
" MUSIC FOR THIS THING. BECAUSE THIS TEXT IS NOT NEARLY LONG ENOUGH YET WE" \
" WILL ALSO DO THE GREETINGS TO ALL THE GROUPS WE KNOW OR HAVE HEARD OF OR SIMPLY" \
" FORGOT ABOUT. SUCH AS... FAIRLIGHT FARBRAUSCH SCOOPEX RED.SECTOR.TRSI METALFOTZE SPECKDRUMM" \
" CONSPIRACY LIMP NINJA THE.BLACK.LOTUS DEKADANCE TITAN TRIAD KAKIARTS GUIDELINE" \
" BITPOLER MELON DRIFTERS MOODSPLATEAU BAUKNECHT AND ALL OTHER SCENERS OUT THERE." \
" HCBA ARE QLONE PACMAN LOBOTM TAB FEAR TMC NEBULAH MARAUDER RACEEEND. IF YOU" \
" HAVE TROUBLE REMEMBERING ALL THIS THE SCROLLER WILL NOW RESTART FOR ANOTHER" \
" ROUND OF READING PLEASURE." \
		"                                                                       |";


@implementation Ventjes

- init
{
	self = [super init];
	if (self)
	{
		m_texture = NULL;
	}
	return self;
}

- (void)dealloc
{
	[m_texture release];
	[super dealloc];
}

- (void)prepare
{
	// Must run this in the correct opengl context
	// otherwise it would be in init...
	if (m_texture == NULL)
	{
		NSLog(@"Ventjes");
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *path = [bundle resourcePath];
		
		NSString *res1 = [path stringByAppendingString:@"/nine.png"];
		NSString *res2 = [path stringByAppendingString:@"/tumlogo.png"];
		NSString *res3 = [path stringByAppendingString:@"/round.png"];
		NSString *res4 = [path stringByAppendingString:@"/font.png"];
		
		m_texture = [[OpenGLTexture alloc] init];		
		[m_texture loadTexture:res1 number:0];
		[m_texture loadTexture:res2 number:1];
		[m_texture loadTexture:res3 number:2];
		[m_texture loadTexture:res4 number:3];
	}

	bounce = 0;
	scrollpos = 0;
	scrollcalc = 0;
}

- (void)updateWithDiffTime:(float)diffTime
{	
	bounce += diffTime * 60.0;
	if (bounce > 36000.0) bounce -= 36000.0;
	
	scrollcalc += diffTime * 4.0;
	if (scrollcalc >= 1.0f) 
	{ 
		scrollpos += 1;
		scrollcalc -= 1.0f;
	}
}

class bunny
{
public:
	float x;
	float y;
	float j;
	float r;
	
	float scalex;
	float scaley;
	
	int tex;
};


bool MyDataSortPredicate(const bunny& lhs, const bunny& rhs)
{
	return lhs.y < rhs.y;
}


- (void)render
{
//	bounce++;
	std::vector<bunny> renderlist;
	
	float offset = bounce;
	
	float j = sin((float)bounce / 12.5f);
	float r = sin((float)bounce / 12.5f);
	if (j < 0.0) j = 0.0f - j;
	
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	// Calculate and render circles...
	float colors[12] = {	0.8, 0.4, 1.0,
							1.0, 0.6, 0.0,
							1.0, 1.0, 0.4,
							0.8, 1.0, 0.0};
	
	for (int c = 3; c >= 0; c--)
	{
		float x = (float)(c + 1) * sin((0.6 * bounce) / (20.0 + (float)(c * 3))); 
		float y = (float)(c + 1) * cos((0.6 * bounce) / (23.0 + ((float)c / 2.0))); 
				
		glPushMatrix();
		
		glTranslatef(x, y, -7.0 - (float)c / 20.0);
		glScalef(c + 2, c + 2, 1.0f);
		
		glBindTexture(GL_TEXTURE_2D, [m_texture getTextureName:2]);
		glBegin(GL_QUADS);
		glColor4f(colors[c * 3], colors[c * 3 + 1], colors[c * 3 + 2], 1.0f);
		glTexCoord2d(0.0,1.0); 			glVertex3f(-2.0f, 2.0f, 0.0f);
		glTexCoord2d(1.0,1.0);			glVertex3f(2.0f, 2.0f, 0.0f);
		glTexCoord2d(1.0,0.0);			glVertex3f(2.0f, -2.0f, 0.0f);
		glTexCoord2d(0.0,0.0);			glVertex3f(-2.0f, -2.0f, 0.0f);
		glEnd();
		
		glPopMatrix();
	}
	
	// Calculate and render scrolltext
	glBindTexture(GL_TEXTURE_2D, [m_texture getTextureName:3]);

	for (int c = 0; c < 80; c++)
	{
		int character = scrolltext[scrollpos + c] - 'A';
		
		if (scrolltext[scrollpos + c] == '.') character = 28;
					
		float p1 = CharacterOffsets[character] / 512.0;
		float p2 = CharacterOffsets[character + 1] / 512.0;
		
		if (scrolltext[scrollpos + c] == ' ') continue;
		if (scrolltext[scrollpos + c] == '|') 
		{
			scrollpos = 0;
			continue;
		}
	
		glPushMatrix();
		
		glTranslatef(-40.0 + c - scrollcalc, 4, -6.0);
		if (scrolltext[scrollpos + c] != 'I') glScalef(0.5f, 0.8f, 1.0f);
		else glScalef(0.3f, 0.8f, 1.0f);
		
		glBegin(GL_QUADS);
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
		glTexCoord2d(p1,1.0); 			glVertex3f(-1.0f, 1.0f, 0.0f);
		glTexCoord2d(p2,1.0);			glVertex3f(1.0f, 1.0f, 0.0f);
		glTexCoord2d(p2,0.0);			glVertex3f(1.0f, -1.0f, 0.0f);
		glTexCoord2d(p1,0.0);			glVertex3f(-1.0f, -1.0f, 0.0f);
		glEnd();
		
		glPopMatrix();
	}
	
	// Calculate and render bunnies... and the chick.
	for (int c = 0; c < 360; c += 20)
	{
		float x = 4.5 * sin((((float)c + offset) / 360.0) * (2.0 * 3.141592654));
		float y = 4.5 * cos((((float)c + offset) / 360.0) * (2.0 * 3.141592654));
		
		bunny b;
		b.x = x;
		b.y = y;
		b.j = j;
		b.r = r;
		b.scalex = 0.3;
		b.scaley = 0.3;
		b.tex = 0;
		
		renderlist.push_back(b);
	}

	{
		bunny b;
		b.x = 0.0;
		b.y = 0.0;
		b.j = 0.0;
		b.r = 0;
		b.scalex = 0.8;
		b.scaley = 1.0;
		b.tex = 1;
		
		renderlist.push_back(b);
	}
	
	// Sort the vector using predicate and std::sort
	std::sort(renderlist.begin(), renderlist.end(), MyDataSortPredicate);
	
	int ct = (int)renderlist.size();
	
	for (int i = 0; i < ct; i++)
	{
		const bunny &b = renderlist[i];
		
		glPushMatrix();
		
		glTranslatef(b.x, b.j, b.y);
		glScalef(b.scalex, b.scaley, 1.0f);
		glRotatef(b.r * 20.0, 0.0, 0.0, 1.0);
		
		glBindTexture(GL_TEXTURE_2D, [m_texture getTextureName:b.tex]);
		glBegin(GL_QUADS);
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
		glTexCoord2d(0.0,1.0); 			glVertex3f(-2.0f, 6.0f, 0.0f);
		glTexCoord2d(1.0,1.0);			glVertex3f(2.0f, 6.0f, 0.0f);
		glTexCoord2d(1.0,0.0);			glVertex3f(2.0f, 0.0f, 0.0f);
		glTexCoord2d(0.0,0.0);			glVertex3f(-2.0f, 0.0f, 0.0f);
		glEnd();
		
		glPopMatrix();
	}
	
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
				
}


@end
