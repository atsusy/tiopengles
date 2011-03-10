//
//  ComTiopenglesViewProxy.m
//  tiopengles
//
//  Created by KATAOKA,Atsushi on 11/03/07.
//  Copyright 2011 LANGRISE Co.,Ltd. All rights reserved.
//

#import "ComTiopenglesViewProxy.h"

@implementation ComTiopenglesViewProxy

- (void)show:(id)args 
{
    [[self view] performSelectorOnMainThread:@selector(show:) 
								  withObject:args 
							   waitUntilDone:NO];
}

- (void)addModel:(id)name
{
    [(ComTiopenglesView *)[self view] addModel:name];
}

- (void)viewDidAttach
{
	[(ComTiopenglesView *)[self view] openContext];	
}

- (void)viewDidDetach
{
	[(ComTiopenglesView *)[self view] closeContext];	
}

@end
