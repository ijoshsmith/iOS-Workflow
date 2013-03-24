//
//  DEMOViewController.m
//  Workflow
//
//  Created by Josh on 3/22/13.
//  Copyright (c) 2013 iJoshSmith. All rights reserved.
//

#import "DEMOViewController.h"
#import "JASWorkflow.h"

// Import custom workflow nodes
#import "DEMODecisionIsInjured.h"
#import "DEMODecisionWillExercise.h"
#import "DEMOWorkItemDoSitUps.h"
#import "DEMOWorkItemLiftWeights.h"


// Represents all valid outcomes for the demo workflow.
typedef enum
{
    DEMOOutcomeHealthy      = 1,
    DEMOOutcomeInconclusive = 2,
    DEMOOutcomeUnhealthy    = 3
}   DEMOOutcome;

static NSString *DEMOOutcomeName(DEMOOutcome outcome)
{
    switch (outcome) {
        case DEMOOutcomeHealthy:      return @"Healthy";
        case DEMOOutcomeInconclusive: return @"Inconclusive";
        case DEMOOutcomeUnhealthy:    return @"Unhealthy";
    }
}

@implementation DEMOViewController
{
    __weak IBOutlet UILabel *_exercisesLabel;
    __weak IBOutlet UILabel *_injuredLabel;
    __weak IBOutlet UILabel *_notInjuredLabel;
    
    // Use a weak reference to provide that a
    // workflow keeps itself alive while executing.
    __weak JASWorkflow *_exercisesWorkflow;
}

- (IBAction)runInjuredWorkflow:(id)sender
{
    [self runWorkflowWithWillExercise:NO
                            isInjured:YES
                                label:_injuredLabel];
}

- (IBAction)runNotInjuredWorkflow:(id)sender
{
    [self runWorkflowWithWillExercise:NO
                            isInjured:NO
                                label:_notInjuredLabel];
}

- (IBAction)runExercisesWorkflow:(id)sender
{
    // This workflow takes a few seconds to complete.
    // Ignore button taps while the workflow is executing.
    if (_exercisesWorkflow)
        return;
    
    _exercisesLabel.text = @"Testing...";
    _exercisesWorkflow = [self runWorkflowWithWillExercise:YES
                                                 isInjured:NO
                                                     label:_exercisesLabel];
}

- (IBAction)cancelExercisesWorkflow:(id)sender
{
    [_exercisesWorkflow cancel];
}

// This workflow determines if someone is healthy.
// Refer to 'Health Workflow.png' for a visual overview.
- (JASWorkflow *)runWorkflowWithWillExercise:(BOOL)exercise
                                   isInjured:(BOOL)injured
                                       label:(UILabel *)label
{
    // Build a workflow and its nodes, using some dummy values.
    JASWorkflowNode *rootNode = nil;
    JASWorkflow *workflow = [self makeWorkflowWithExercise:exercise
                                                   injured:injured
                                                  rootNode:&rootNode];
    
    // Run the workflow with a callback for when it finishes.
    [workflow startExecutingWithNode:rootNode
                          completion:^(id               outcome,
                                       JASWorkflowNode *finalNode,
                                       BOOL             cancelled)
    {
        if (cancelled)
        {
            label.text = @"Cancelled";
            NSLog(@"Workflow cancelled");
        }
        else if (outcome)
        {
            label.text = DEMOOutcomeName([outcome intValue]);
            NSLog(@"Outcome '%@' Node '%@'", label.text, finalNode);
        }
        else if (finalNode.error)
        {
            label.text = @"Error";
            NSLog(@"Failed with error: %@", finalNode.error);
        }
        else
        {
            label.text = @"Invalid";
            NSLog(@"Unanticipated node/result combination!");
        }
    }];
    return workflow;
}

- (JASWorkflow *)makeWorkflowWithExercise:(BOOL)exercise
                                  injured:(BOOL)injured
                                 rootNode:(JASWorkflowNode **)rootNode
{
    // Create workflow nodes.
    JASDecision *willExercise = [[DEMODecisionWillExercise alloc] init];
    JASDecision *isInjured = [[DEMODecisionIsInjured alloc] init];
    JASWorkItem *liftWeights = [[DEMOWorkItemLiftWeights alloc] init];
    JASWorkItem *doSitUps = [[DEMOWorkItemDoSitUps alloc] initWithCount:50];
    
    // Tell both decision nodes what value to return, for testing purposes.
    [isInjured    setValue:@(injured)  forKey:@"mockResult"];
    [willExercise setValue:@(exercise) forKey:@"mockResult"];
    
    // Link nodes together.
    willExercise.no  = isInjured;
    willExercise.yes = liftWeights;
    liftWeights.next = doSitUps;
    
    // Create a workflow to execute the nodes.
    JASWorkflow *workflow = [[JASWorkflow alloc] initWithNodes:
                             @[willExercise, isInjured,
                               liftWeights,  doSitUps]];
    
    // Specify how node results are translated into
    // meaningful outcomes for this particular workflow.
    [workflow ifFinalNode:doSitUps
           producesResult:JASWorkflowNodeResultComplete
               evaluateTo:@(DEMOOutcomeHealthy)];
    
    [workflow ifFinalNode:isInjured
           producesResult:JASWorkflowNodeResultNo
               evaluateTo:@(DEMOOutcomeUnhealthy)];
    
    [workflow ifFinalNode:isInjured
           producesResult:JASWorkflowNodeResultYes
               evaluateTo:@(DEMOOutcomeInconclusive)];
    
    // Point the out param at a node to execute first. 
    if (rootNode != NULL)
        *rootNode = willExercise;
    
    return workflow;
}

@end
