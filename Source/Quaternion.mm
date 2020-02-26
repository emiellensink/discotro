//////////////////////////////////////////////////////////////////////////////
// Quaternion.m
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////////
#import "Quaternion.h"
#import <math.h>

//////////////////////////////////////////////////////////////////////////////
// QuatSetRotation
//////////////////////////////////////////////////////////////////////////////
void QuatSetRotation(quat_t *q, float angle, float x, float y, float z)
{
	float halfAngle = angle / 180.0f * M_PI * 0.5;
	float sinHalfAngle = sin(halfAngle);

	q->x = x * sinHalfAngle;
	q->y = y * sinHalfAngle;
	q->z = z * sinHalfAngle;
	q->w = cos(halfAngle);
}

//////////////////////////////////////////////////////////////////////////////
// QuatMultiply
//////////////////////////////////////////////////////////////////////////////
void QuatMultiply(quat_t *result, quat_t *qa, quat_t *qb)
{
	quat_t qr;

	qr.x = qb->y*qa->z - qb->z*qa->y + qb->w*qa->x + qb->x*qa->w;
	qr.y = qb->z*qa->x - qb->x*qa->z + qb->w*qa->y + qb->y*qa->w;
	qr.z = qb->x*qa->y - qb->y*qa->x + qb->w*qa->z + qb->z*qa->w;
	qr.w = qb->w*qa->w - qb->x*qa->x - qb->y*qa->y - qb->z*qa->z;
	
	*result = qr;
}

//////////////////////////////////////////////////////////////////////////////
// QuatGetAngleAxis
//////////////////////////////////////////////////////////////////////////////
void QuatGetAngleAxis(quat_t *q, float *angle, float *x, float *y, float *z)
{
	float theta2 = acos(q->w);
	float sinTheta2 = (float)(1.0 / sin((double)theta2));	// this can give a inf (division by zero)

	*angle = theta2 * 2.0f * 180.0f / M_PI;
    *x = q->x * sinTheta2;
    *y = q->y * sinTheta2;
    *z = q->z * sinTheta2;
}

//////////////////////////////////////////////////////////////////////////////
// QuatCreateMatrix
//////////////////////////////////////////////////////////////////////////////
void QuatCreateMatrix(quat_t *q, float *m)
{
	// First row
	m[ 0] = 1.0f - 2.0f * (q->y * q->y + q->z * q->z);
	m[ 1] = 2.0f * (q->x * q->y + q->z * q->w);
	m[ 2] = 2.0f * (q->x * q->z - q->y * q->w);
	m[ 3] = 0.0f;

	// Second row
	m[ 4] = 2.0f * (q->x * q->y - q->z * q->w);
	m[ 5] = 1.0f - 2.0f * ( q->x * q->x + q->z * q->z);
	m[ 6] = 2.0f * (q->z * q->y + q->x * q->w);
	m[ 7] = 0.0f;

	// Third row
	m[ 8] = 2.0f * (q->x * q->z + q->y * q->w);
	m[ 9] = 2.0f * (q->y * q->z - q->x * q->w);
	m[10] = 1.0f - 2.0f * (q->x * q->x + q->y * q->y);
	m[11] = 0.0f;

	// Fourth row
	m[12] = 0;
	m[13] = 0;
	m[14] = 0;
	m[15] = 1.0f;
}
