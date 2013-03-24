//
//  DEMOWorkItemDoSitUps.m
//  Workflow
//
//  Created by Josh on 3/22/13.
//  Copyright (c) 2013 iJoshSmith. All rights reserved.
//

#import "DEMOWorkItemDoSitUps.h"

@implementation DEMOWorkItemDoSitUps
{
    NSUInteger _count;
}

- (id)initWithCount:(NSUInteger)count
{
    self = [super init];
    if (self)
    {
        _count = count;
    }
    return self;
}

- (JASWorkflowNodeResult)execute
{
    NSLog(@"Doing %u sit-up(s)...", _count);
    
    // Pretend to perform a task that takes two seconds to complete.
    [self performSelector:@selector(finish)
               withObject:nil
               afterDelay:2];
    
    return JASWorkflowNodeResultPending;
}

- (void)finish
{
    [self reportPendingResult:JASWorkflowNodeResultComplete];
}

@end
