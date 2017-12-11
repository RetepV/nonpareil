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
//  VoyagerSimulator.m
//  nonpareil
//
//  Created by Maciej Bartosiak on 2005-09-09.
//  Copyright Maciej Bartosiak 2005.
//

#define NONPAREIL_INTERNAL

#import "util.h"
#import "VoyagerSimulator.h"
#import <math.h>

@implementation VoyagerSimulator

- (id)initWithDisplay: (VoyagerDisplayView *)display
{
    self = [super init];
	
	NSBundle *nonpareilBundle = [NSBundle mainBundle];
	NSString *objFile = [nonpareilBundle pathForResource: NNPR_OBJ ofType:@"obj"];
	
	nv = nut_new_processor (NNPR_RAM, (__bridge void *)display);
	nut_read_object_file (nv, [objFile cString]);
	
    [self readState];
	lastRun = [NSDate timeIntervalSinceReferenceDate];
	
	return self;
}

- (void)pressKey: (int)key
{
	if (key == -1)
	{
		nut_release_key(nv);
	} else {
		nut_press_key(nv, key);
	}
}

- (void)readKeysFrom: (NSMutableArray *) keyQueue
{
	static int delay = 0;
	int key;
	
	if (delay)
		delay--;
	else
	{
		if([keyQueue lastObject])
		{
			key = [[keyQueue lastObject] intValue];
			[keyQueue removeLastObject];
			[self pressKey: key];
		}
		
		if (key == -1)
		{
			if([keyQueue lastObject])
			{
				key = [[keyQueue lastObject] intValue];
				[keyQueue removeLastObject];
				[self pressKey: key];
				delay = 2;
			}
		}
	}	
}

- (void)executeCycle
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	int i = (int)round((now - lastRun) * (NNPR_CLOCK / NNPR_WSIZE));
	lastRun = now;
	
	if (i > 5000) i = 5000;
	
	while (i--)
	{
		nut_execute_instruction(nv);
	}
}

- (int)displayDigits
{
	return nv->display_digits;
}

- (segment_bitmap_t *)displaySegments
{
	return nv->display_segments;
}

- (BOOL)printState
{
	return (BOOL)nut_print_state(nv);
}

- (NSString *)calculatorStateFilename {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *urls = [fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    
    if ([urls count] == 0)
        return nil;
    
    NSString *nonpareilDirPath = [[urls objectAtIndex:0] path];
    nonpareilDirPath = [nonpareilDirPath stringByAppendingPathComponent:@"nonpareil"];
    NSError *error;
    
    BOOL success = [fileManager createDirectoryAtPath:nonpareilDirPath
                          withIntermediateDirectories:YES
                                           attributes:nil
                                                error:&error];
    if (!success)
        return nil;
    
    
    return [nonpareilDirPath stringByAppendingPathComponent:NNPR_STATE];
}

- (void)readState
{
    NSDictionary *stateDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[self calculatorStateFilename]];
    if (stateDict == nil) {
#ifdef NONPAREIL_25
        //woodstock_set_ext_flag(cpu,3,true);
#endif
        return;
    }
    
    NSUInteger i;
    
    str2reg(nv->a, [[stateDict objectForKey:@"a"] UTF8String]);
    str2reg(nv->b, [[stateDict objectForKey:@"b"] UTF8String]);
    str2reg(nv->c, [[stateDict objectForKey:@"c"] UTF8String]);
    str2reg(nv->m, [[stateDict objectForKey:@"m"] UTF8String]);
    str2reg(nv->n, [[stateDict objectForKey:@"n"] UTF8String]);
    
    nv->g[0]       = (digit_t)[[stateDict objectForKey:@"g0"] unsignedIntValue];
    nv->g[1]       = (digit_t)[[stateDict objectForKey:@"g1"] unsignedIntValue];
    
    nv->p          = (digit_t)[[stateDict objectForKey:@"p"] unsignedIntValue];
    nv->q          = (digit_t)[[stateDict objectForKey:@"q"] unsignedIntValue];
    
    nv->q_sel		= (bool)[[stateDict objectForKey:@"q_sel"] boolValue];
    
    nv->fo         = (digit_t)[[stateDict objectForKey:@"fo"] unsignedIntValue];
    
    nv->decimal    = (bool)[[stateDict objectForKey:@"decimal"] boolValue];
    nv->carry      = (bool)[[stateDict objectForKey:@"carry"] boolValue];
    nv->prev_carry	= (bool)[[stateDict objectForKey:@"prev_carry"] boolValue];
    
    nv->prev_tef_last = [[stateDict objectForKey:@"prev_tef_last"] intValue];
    
    *(uint16_t*)&(nv->s)          = (uint16_t)[[stateDict objectForKey:@"s"] unsignedIntValue];
    *(uint16_t*)&(nv->ext_flag)   = (uint16_t)[[stateDict objectForKey:@"ext_flag"] unsignedIntValue];
    
    nv->pc         = (uint16_t)[[stateDict objectForKey:@"pc"] unsignedIntValue];
    
    for(i=0; i<STACK_DEPTH; i++)
        nv->stack[i] = (uint16_t)[[[stateDict objectForKey:@"stack"] objectAtIndex: i] unsignedIntValue]; //poprawić i na NSUint
    
    nv->cxisa_addr	= (uint16_t)[[stateDict objectForKey:@"cxisa_addr"] unsignedIntValue];
    nv->inst_state	= (inst_state_t)[[stateDict objectForKey:@"inst_state"] unsignedIntValue];
    nv->first_word	= (uint16_t)[[stateDict objectForKey:@"first_word"] unsignedIntValue];
    nv->long_branch_carry  = (bool)[[stateDict objectForKey:@"long_branch_carry"] boolValue];
    
    //bool key_down;      /* true while a key is down */
    //keyboard_state_t kb_state;
    //int kb_debounce_cycle_counter;
    //int key_buf;        /* most recently pressed key */
    
    /*nv->key_down	= (bool)[[stateDict objectForKey:@"key_down"] boolValue];
     nv->kb_state	= (keyboard_state_t)[[stateDict objectForKey:@"kb_state"] intValue];
     nv->kb_debounce_cycle_counter = (int)[[stateDict objectForKey:@"kb_debounce_cycle_counter"] intValue];
     nv->key_buf	= (int)[[stateDict objectForKey:@"key_buf"] intValue];*/
    
    nv->awake			= (bool)[[stateDict objectForKey:@"awake"] boolValue];
    
    //memory
    
    nv->ram_addr = (uint16_t)[[stateDict objectForKey:@"ram_addr"] unsignedIntValue];
    
    for(i=0; i<nv->max_ram; i++) {
        //if (nv->ram_exists[i])
        str2reg(nv->ram[i], [[[stateDict objectForKey:@"memory"] objectAtIndex: i] UTF8String]); //poprawić i na NSUint
    }
    
    nv->display_chip->enable		= (bool)[[stateDict objectForKey:@"display_chip->enable"] boolValue];
    nv->display_chip->blink		= (bool)[[stateDict objectForKey:@"display_chip->blink"] boolValue];
    nv->display_chip->blink_state	= (bool)[[stateDict objectForKey:@"display_chip->blink_state"] boolValue];
    nv->display_chip->blink_count	= (int)[[stateDict objectForKey:@"display_chip->blink_count"] intValue];
}

- (void)saveState
{
    NSMutableDictionary *stateDict = [[NSMutableDictionary alloc] init];
    char tmp[WSIZE+1] ;
    NSUInteger i;
    
    [stateDict setValue:[NSString stringWithUTF8String:reg2str(tmp, nv->a)] forKey:@"a"];
    [stateDict setValue:[NSString stringWithUTF8String:reg2str(tmp, nv->b)] forKey:@"b"];
    [stateDict setValue:[NSString stringWithUTF8String:reg2str(tmp, nv->c)] forKey:@"c"];
    [stateDict setValue:[NSString stringWithUTF8String:reg2str(tmp, nv->n)] forKey:@"n"];
    [stateDict setValue:[NSString stringWithUTF8String:reg2str(tmp, nv->m)] forKey:@"m"];
    
    [stateDict setValue:[NSNumber numberWithUnsignedInt: nv->g[0]]
                 forKey:@"g0"];
    [stateDict setValue:[NSNumber numberWithUnsignedInt: nv->g[1]]
                 forKey:@"g1"];
    
    [stateDict setValue:[NSNumber numberWithUnsignedInt: nv->p]
                 forKey:@"p"];
    [stateDict setValue:[NSNumber numberWithUnsignedInt: nv->q]
                 forKey:@"q"];
    [stateDict setValue:[NSNumber numberWithBool:nv->q_sel]
                 forKey:@"q_sel"];
    
    [stateDict setValue:[NSNumber numberWithUnsignedInt: nv->fo]
                 forKey:@"fo"];
    
    [stateDict setValue:[NSNumber numberWithBool:nv->decimal]
                 forKey:@"decimal"];
    
    [stateDict setValue:[NSNumber numberWithBool:nv->carry]
                 forKey:@"carry"];
    [stateDict setValue:[NSNumber numberWithBool:nv->prev_carry]
                 forKey:@"prev_carry"];
    
    [stateDict setValue:[NSNumber numberWithInt: nv->prev_tef_last]
                 forKey:@"prev_tef_last"];
    
    [stateDict setValue:[NSNumber numberWithUnsignedInt: *(uint16_t*)&(nv->s)]
                 forKey:@"s"];
    [stateDict setValue:[NSNumber numberWithUnsignedInt: *(uint16_t*)&(nv->ext_flag)]
                 forKey:@"ext_flag"];
    
    [stateDict setValue:[NSNumber numberWithUnsignedInt: nv->pc]
                 forKey:@"pc"];
    
    NSMutableArray *stack = [[NSMutableArray alloc] init];
    
    for(i=0; i<STACK_DEPTH; i++)
        [stack insertObject: [NSNumber numberWithUnsignedInt: nv->stack[i]] atIndex:i];
    
    [stateDict setValue:stack
                 forKey:@"stack"];
    
    [stateDict setValue:[NSNumber numberWithUnsignedInt: nv->cxisa_addr]
                 forKey:@"cxisa_addr"];
    [stateDict setValue:[NSNumber numberWithUnsignedInt: nv->inst_state]
                 forKey:@"inst_state"];
    [stateDict setValue:[NSNumber numberWithUnsignedInt: nv->first_word]
                 forKey:@"first_word"];
    [stateDict setValue:[NSNumber numberWithBool:nv->long_branch_carry]
                 forKey:@"long_branch_carry"];
    
    
    //bool key_down;      /* true while a key is down */
    //keyboard_state_t kb_state;
    //int kb_debounce_cycle_counter;
    //int key_buf;        /* most recently pressed key */
    
    /*[stateDict setValue:[NSNumber numberWithBool: nv->key_down]
				 forKey:@"key_down"];
     [stateDict setValue:[NSNumber numberWithInt: nv->kb_state]
				 forKey:@"kb_state"];
     [stateDict setValue:[NSNumber numberWithInt: nv->kb_debounce_cycle_counter]
				 forKey:@"kb_debounce_cycle_counter"];
     [stateDict setValue:[NSNumber numberWithInt: nv->key_buf]
				 forKey:@"key_buf"];*/
    
    [stateDict setValue:[NSNumber numberWithBool:nv->awake]
                 forKey:@"awake"];
    
    //memory
    
    [stateDict setValue:[NSNumber numberWithUnsignedInt: nv->ram_addr]
                 forKey:@"ram_addr"];
    
    NSMutableArray *memory = [[NSMutableArray alloc] init];
    
    for(i=0; i<nv->max_ram; i++)
        [memory insertObject: [NSString stringWithUTF8String:reg2str(tmp, nv->ram[i])] atIndex:i];
    
    [stateDict setValue:memory
                 forKey:@"memory"];
    
    [stateDict setValue:[NSNumber numberWithBool: nv->display_chip->enable]
                 forKey:@"display_chip->enable"];
    [stateDict setValue:[NSNumber numberWithBool: nv->display_chip->blink]
                 forKey:@"display_chip->blink"];
    [stateDict setValue:[NSNumber numberWithBool: nv->display_chip->blink_state]
                 forKey:@"display_chip->blink_state"];
    [stateDict setValue:[NSNumber numberWithInt: nv->display_chip->blink_count]
                 forKey:@"display_chip->blink_count"];
    
    
    [stateDict writeToFile:[self calculatorStateFilename] atomically:YES];
    
}

@end

void display_callback(struct nut_reg_t *nv)
{
	static segment_bitmap_t o_display_segments [MAX_DIGIT_POSITION];
	
	if (memcmp( o_display_segments, nv->display_segments, MAX_DIGIT_POSITION * sizeof(segment_bitmap_t)))
	{
		memcpy( o_display_segments, nv->display_segments, MAX_DIGIT_POSITION * sizeof(segment_bitmap_t));
		[(__bridge VoyagerDisplayView *)nv->display updateDisplay];
	}
}
