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
//  VoyagerDisplayView.m
//  nonpareil
//
//  Created by Maciej Bartosiak on 2005-09-09.
//  Copyright Maciej Bartosiak 2005.
//

#import "VoyagerDisplayView.h"

@implementation VoyagerDisplayView

- (id)initWithFrame:(CGRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
        [self basicInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self basicInit];
    }
    return self;
}

- (void)basicInit {
    UIFont *font;
    
    ds = NULL;
    dc = 0;
    
    attrs = [[NSMutableDictionary alloc] init];
    [attrs setObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    
    if ((font = [UIFont fontWithName:@"Monaco" size:9.0]) != nil)
        [attrs setObject:[UIFont fontWithName:@"Monaco" size:9.0] forKey:NSFontAttributeName];
    else
        [attrs setObject:[UIFont systemFontOfSize:9.0] forKey:NSFontAttributeName];
}

- (void)drawRect:(CGRect)rect
{
	int num;
	
	if (ds == NULL)
		return;
	
	[[UIColor blackColor] set];
	
	for (num = 0; num < dc; num++)
		if (ds[num]) // we don't want to draw empty digit
			[[digits objectAtIndex: num] drawDigit:ds[num]];
		
		
	// Now is time for annunciatiors

    float annuncOff = [self frame].size.height - 20;
    
	if (((ds[1] >> 17) & 1))
		[[NSString stringWithCString: "*"] drawAtPoint: CGPointMake(15.0,annuncOff)
											 withAttributes: attrs];
	if (((ds[2] >> 17) & 1))
		[[NSString stringWithCString: "USER"] drawAtPoint: CGPointMake(47.0,annuncOff)
										withAttributes: attrs];
	if (((ds[3] >> 17) & 1))
		[[NSString stringWithCString: "f"] drawAtPoint: CGPointMake(89.0,annuncOff)
										   withAttributes: attrs];
	if (((ds[4] >> 17) & 1))
		[[NSString stringWithCString: "g"] drawAtPoint: CGPointMake(107.0,annuncOff)
										withAttributes: attrs];
	if (((ds[5] >> 17) & 1))
		[[NSString stringWithCString: "BEGIN"] drawAtPoint: CGPointMake(125.0,annuncOff)
										withAttributes: attrs];
	if (((ds[6] >> 17) & 1))
		[[NSString stringWithCString: "G"] drawAtPoint: CGPointMake(183.0,annuncOff)
										  withAttributes: attrs];
	if (((ds[7] >> 17) & 1))
		[[NSString stringWithCString: "RAD"] drawAtPoint: CGPointMake(189.0,annuncOff)
											withAttributes: attrs];
	if (((ds[8] >> 17) & 1))
		[[NSString stringWithCString: "D.MY"] drawAtPoint: CGPointMake(212.0,annuncOff)
										   withAttributes: attrs];
	if (((ds[9] >> 17) & 1))
		[[NSString stringWithCString: "C"] drawAtPoint: CGPointMake(246.0,annuncOff)
										   withAttributes: attrs];
	if (((ds[10] >> 17) & 1))
		[[NSString stringWithCString: "PRGM"] drawAtPoint: CGPointMake(273.0,annuncOff)
										withAttributes: attrs];
	
    [self setNeedsDisplay];
}

//- (void)setupDisplayWith:(segment_bitmap_t *)disps count: (int)count
- (void)setupDisplayWith: (segment_bitmap_t *)disps
				   count: (int) count
				 yOffset: (float) y
			 digitHeight: (float) digitHeight
			  digitWidth: (float) digitWidth
			 digitOffset: (float) digitOffset
			  digitShear: (float) digitShear
			 digitStroke: (float) digitStroke
			   dotOffset: (float) dotOffset
{
	VoyagerDigit *dig;
	NSMutableArray *tmp;
	
	int i;
	float xOff = ([self frame].size.width - ((count - 1) * (digitWidth + digitOffset)))/2.0;
    float yOff = [self frame].size.height - y - digitHeight;
	dc = count;
	ds = disps;
	
	tmp = [NSMutableArray arrayWithCapacity: dc];
	
	for (i = 0; i < dc; i++)
	{
		/*dig = [[VoyagerDigit alloc] initWithDigitHeight: (float) 25.0 
												  width: (float) 15.0 
												  shear: (float) 0.1
												 stroke: (float) 3.5
											  dotOffset: (float) 3.0
													  x: (float) xoff
													  y: (float) 24.0];*/
		dig = [[VoyagerDigit alloc] initWithDigitHeight: digitHeight
												  width: digitWidth
												  shear: digitShear
												 stroke: digitStroke
											  dotOffset: dotOffset
													  x: xOff
													  y: yOff];
		[tmp insertObject: dig atIndex: i];
		xOff += (digitWidth + digitOffset);
	}
	
	digits = [[NSArray alloc] initWithArray: tmp];
}

- (void)updateDisplay
{
	//if (memcmp( cds, ds, MAX_DIGIT_POSITION))
	//{
	//	memcpy(cds, ds, MAX_DIGIT_POSITION);
		[self setNeedsDisplay];
	//	NSLog(@"disp");
	//}
		
}

@end
