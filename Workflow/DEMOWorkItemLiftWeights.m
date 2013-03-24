//
//  DEMOWorkItemLiftWeights.m
//  Workflow
//
//  Created by Josh on 3/22/13.
//  Copyright (c) 2013 iJoshSmith. All rights reserved.
//

#import "DEMOWorkItemLiftWeights.h"

@implementation DEMOWorkItemLiftWeights

- (JASWorkflowNodeResult)execute
{
    NSLog(@"Lifting weights...");
    
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
