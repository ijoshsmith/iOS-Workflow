//
//  DEMODecisionIsInjured.m
//  Workflow
//
//  Created by Josh on 3/22/13.
//  Copyright (c) 2013 iJoshSmith. All rights reserved.
//

#import "DEMODecisionIsInjured.h"

@implementation DEMODecisionIsInjured

- (JASWorkflowNodeResult)execute
{
    return JASDecisionResultFromBOOL(self.mockResult);
}

@end
