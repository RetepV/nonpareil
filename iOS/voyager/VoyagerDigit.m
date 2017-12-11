/*
 $Id$
 Copyright 1995, 2003, 2004, 2005 Eric L. Smith <eric@brouhaha.com>
 
 Nonpareil is free software; you can redistribute it and/or modify it
 under the terms of the GNU General Public License version 2 as
 published by the Free Software Foundation.  Note that I am not
 granting permission to redistribute or modify Nonpareil under the
 terms of any later version of the General Public License.
 
 Nonpareil is distributed in the hope that it will be useful, but
 WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program (in the file "COPYING"); if not, write to the
 Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
 MA 02111, USA.
 */

//
//  VoyagerDigit.m
//  nonpareil
//
//  Created by Maciej Bartosiak on 2005-09-26.
//  Copyright 2005 Maciej Bartosiak.
//

#import "VoyagerDigit.h"

@implementation VoyagerDigit

- (id)initWithDigitHeight: (float) digitH 
					width: (float) digitW 
					shear: (float) shear
				   stroke: (float) stroke
				dotOffset: (float) dotOff
						x: (float) x
						y: (float) y
{
	float digito = 1.0;
	float digitO = digito * 2.0;
	float digith = digitH / 2.0;
	float digits = stroke / 2.0;
	float digitWS = digitW - (stroke * 2.0);
	float digitHS = digith - (stroke * 1.5); // (stroke * 1.5) = stroke + digits 
			
    self = [super init];
    

    float xPoint = digito;
    float yPoint = 0.0;
    a = [UIBezierPath bezierPath];
    [a moveToPoint:    CGPointMake(xPoint, yPoint)];
    xPoint += (digitW - digitO); yPoint += 0.0;
    [a addLineToPoint: CGPointMake(xPoint, yPoint)];
    xPoint += -stroke; yPoint += stroke;
    [a addLineToPoint: CGPointMake(xPoint, yPoint)];
    xPoint += (-digitWS + digitO); yPoint += 0.0;
    [a addLineToPoint: CGPointMake(xPoint, yPoint)];
    [a closePath];
	
	
    xPoint = digitW;
    yPoint = digito;
    b = [UIBezierPath bezierPath];
    [b moveToPoint: CGPointMake(xPoint, yPoint)];
    xPoint += 0.0; yPoint += (digith - digitO);
    [b addLineToPoint: CGPointMake(xPoint, yPoint)];
    xPoint += -stroke; yPoint += -digits;
    [b addLineToPoint: CGPointMake(xPoint, yPoint)];
    xPoint += 0.0; yPoint += (-digitHS + digitO);
    [b addLineToPoint: CGPointMake(xPoint, yPoint)];
    [b closePath];
    
	
	c = [b copy];
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, -digitH);
    [c applyTransform:translate];
    CGAffineTransform scale = CGAffineTransformMakeScale(1.0, -1.0);
    [c applyTransform:scale];
    [c closePath];

    
	d = [a copy];
    translate = CGAffineTransformMakeTranslation(0.0, -digitH);
    [d applyTransform:translate];
    scale = CGAffineTransformMakeScale(1.0, -1.0);
    [d applyTransform:scale];

    
	e = [b copy];
    translate = CGAffineTransformMakeTranslation(-digitW, -digitH);
    [e applyTransform:translate];
    scale = CGAffineTransformMakeScale(-1.0, -1.0);
    [e applyTransform:scale];

	
	f = [c copy];
    translate = CGAffineTransformMakeTranslation(-digitW, -digitH);
    [f applyTransform:translate];
    scale = CGAffineTransformMakeScale(-1.0, -1.0);
    [f applyTransform:scale];

    
    xPoint = digito;
    yPoint = digith;
    g = [UIBezierPath bezierPath];
    [g moveToPoint: CGPointMake(xPoint, yPoint)];
    xPoint += stroke; yPoint += -digits;
    [g addLineToPoint: CGPointMake(xPoint, yPoint)];
    xPoint += (digitWS - digito); yPoint += 0;
    [g addLineToPoint: CGPointMake(xPoint, yPoint)];
    xPoint += stroke; yPoint += digits;
    [g addLineToPoint: CGPointMake(xPoint, yPoint)];
    xPoint += -stroke; yPoint += digits;
    [g addLineToPoint: CGPointMake(xPoint, yPoint)];
    xPoint += (-digitWS+digitO); yPoint += 0.0;
    [g addLineToPoint: CGPointMake(xPoint, yPoint)];
    [g closePath];


    
	// "dot" segment
    xPoint = digitW + dotOff;
    yPoint = digitH;
    h = [UIBezierPath bezierPath];
    [h moveToPoint: CGPointMake(xPoint, yPoint)];
    xPoint += 0.0; yPoint += -stroke;
    [h addLineToPoint: CGPointMake(xPoint, yPoint)];
    xPoint += stroke; yPoint += 0.0;
    [h addLineToPoint: CGPointMake(xPoint, yPoint)];
    xPoint += 0.0; yPoint += stroke;
    [h addLineToPoint: CGPointMake(xPoint, yPoint)];
    [h closePath];

    
	// "," segment
    xPoint = digitW + dotOff;
    yPoint = digitH + digito;
    i = [UIBezierPath bezierPath];
    [i moveToPoint: CGPointMake(xPoint, yPoint)];
    xPoint += stroke; yPoint += 0.0;
    [i addLineToPoint: CGPointMake(xPoint, yPoint)];
    xPoint += -stroke; yPoint += stroke;
    [i addLineToPoint: CGPointMake(xPoint, yPoint)];
    xPoint += (-stroke/2.0); yPoint += 0.0;
    [i addLineToPoint: CGPointMake(xPoint, yPoint)];
    [i closePath];

    
    // [1     0     0]
    // [shear 1     0]
    // [0     0     1]
    CGAffineTransform shearTransform = CGAffineTransformMake(1.0, 0.0, -shear, 1.0, 0.0, 0.0);
    [a applyTransform:shearTransform];
    [b applyTransform:shearTransform];
    [c applyTransform:shearTransform];
    [d applyTransform:shearTransform];
    [e applyTransform:shearTransform];
    [f applyTransform:shearTransform];
    [g applyTransform:shearTransform];
    [h applyTransform:shearTransform];
    [i applyTransform:shearTransform];
    
/*
    translate = CGAffineTransformMakeTranslation(DIGIT_OFF/2.0, 0.0);
    [a applyTransform:shearTransform];
    [b applyTransform:shearTransform];
    [c applyTransform:shearTransform];
    [d applyTransform:shearTransform];
    [e applyTransform:shearTransform];
    [f applyTransform:shearTransform];
    [g applyTransform:shearTransform];
    [h applyTransform:shearTransform];
    [i applyTransform:shearTransform];
*/
    
    translate = CGAffineTransformMakeTranslation(x, y);
    [a applyTransform:translate];
    [b applyTransform:translate];
    [c applyTransform:translate];
    [d applyTransform:translate];
    [e applyTransform:translate];
    [f applyTransform:translate];
    [g applyTransform:translate];
    [h applyTransform:translate];
    [i applyTransform:translate];
    
	return self;
}

- (id)init
{
	return [self initWithDigitHeight: (float) 25.0 
							   width: (float) 15.0 
							   shear: (float) 0.1
							  stroke: (float) 3.5
						   dotOffset: (float) 5.0
								   x: (float) 25.0
								   y: (float) 3.0];
}

- (void) drawDigit: (segment_bitmap_t)dig
{		
	if((dig >> 0) & 1) [a fill];
	if((dig >> 1) & 1) [b fill];
	if((dig >> 2) & 1) [c fill];
	if((dig >> 3) & 1) [d fill];
	if((dig >> 4) & 1) [e fill];
	if((dig >> 5) & 1) [f fill];
	if((dig >> 6) & 1) [g fill];
	if((dig >> 7) & 1) [h fill];
	if((dig >> 8) & 1) [i fill];	
}

@end
