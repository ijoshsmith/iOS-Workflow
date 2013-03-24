//
//  DEMODecisionWillExercise.m
//  Workflow
//
//  Created by Josh on 3/22/13.
//  Copyright (c) 2013 iJoshSmith. All rights reserved.
//

#import "DEMODecisionWillExercise.h"

@implementation DEMODecisionWillExercise

- (JASWorkflowNodeResult)execute
{
    return JASDecisionResultFromBOOL(self.mockResult);
}

@end
