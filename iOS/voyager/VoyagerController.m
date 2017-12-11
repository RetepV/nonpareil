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
//  NonpareilController.h
//  nonpareil
//
//  Created by Maciej Bartosiak on 2005-09-09.
//  Copyright Maciej Bartosiak 2005.
//

#import "VoyagerController.h"
#import "VoyagerDisplayView.h"
#import "VoyagerSimulator.h"

@interface VoyagerController ()

@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (assign) IBOutlet VoyagerDisplayView *display;

@property (nonatomic, strong) VoyagerSimulator *simulator;

@property (nonatomic, strong) NSTimer		    *timer;
@property (nonatomic, strong) NSMutableArray	*keyQueue;

@end

@implementation VoyagerController

#define JIFFY_PER_SEC 30.0

- (void)awakeFromNib
{
	// [NSApp setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    CGRect frame = self.view.frame;
    CGRect bgFrame = self.background.frame;
    
    CGFloat mulFact = frame.size.width / bgFrame.size.width;
    CGFloat newHeight = bgFrame.size.height * mulFact;
    if (newHeight > frame.size.height)
    {
        mulFact = frame.size.height / bgFrame.size.height;
    }
    
    _keyQueue = [[NSMutableArray alloc] init];
    
    _simulator = [[VoyagerSimulator alloc] initWithDisplay: _display];
    //[display setupDisplayWith:[simulator displaySegments] count: [simulator displayDigits]];
    [_display setupDisplayWith: [_simulator displaySegments]
                         count: [_simulator displayDigits]
                       yOffset: 24.0 / mulFact
                   digitHeight: 25.0 * mulFact
                    digitWidth: 15.0 * mulFact
                   digitOffset: 10.5 * mulFact
                    digitShear: 0.1
                   digitStroke: 3.5 * mulFact
                     dotOffset: 3.5 * mulFact];

    CGFloat xOfs = (frame.size.width - (bgFrame.size.width * mulFact)) / 2.0;
    CGFloat yOfs = (frame.size.height - (bgFrame.size.height * mulFact)) / 2.0;
    
    UIView* item;
    for (item in self.view.subviews)
    {
        CGRect frame = item.frame;
        frame.origin.x *= mulFact;
        frame.origin.x += xOfs;
        frame.origin.y *= mulFact;
        frame.origin.y += yOfs;
        frame.size.width *= mulFact;
        frame.size.height *= mulFact;
        if ([item isKindOfClass:[UIButton class]])
        {
            UIButton* button = item;
            button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        }
        [item setFrame:frame];
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0/JIFFY_PER_SEC)
                                              target:self
                                            selector:@selector(run:)
                                            userInfo:nil
                                             repeats:YES];    
}

- (IBAction)buttonPressed:(id)sender
{
	[self.keyQueue insertObject:[NSNumber numberWithInt: [sender tag]] atIndex:0];
	[self.keyQueue insertObject:[NSNumber numberWithInt: -1] atIndex:0];
}

- (void)run:(NSTimer *)aTimer
{
	[self.simulator readKeysFrom: self.keyQueue];
	
	[self.simulator executeCycle];
    
    //if([simulator executeCycle])
	//{
	//	[display updateDisplay];
	//}
}

- (void)quit
{
    [self.timer invalidate];
    //if (! write_ram_file (ram))
	[self.simulator printState];
}

- (void)applicationWillResignActive
{
    [self.simulator saveState];
}

- (void)applicationWillTerminate
{
    [self.simulator saveState];
    [self quit];
}

//--------------------------------------------------------------------------------------------------------
// NSWindow delegate methods
//--------------------------------------------------------------------------------------------------------
- (void)windowDidBecomeKey:(NSNotification *)aNotification
{
    [[aNotification object] setAlpha:1.0];
}

- (void)windowDidResignKey:(NSNotification *)aNotification
{
    [[aNotification object] setAlpha:0.85];
}


@end
