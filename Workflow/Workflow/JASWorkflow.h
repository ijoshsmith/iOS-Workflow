// JASWorkflow.h
//
// Copyright (c) 2013 Josh Smith http://ijoshsmith.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "JASDecision.h"
#import "JASWorkItem.h"

typedef void (^JASWorkflowCompletionBlock)(id outcome, JASWorkflowNode *finalNode, BOOL cancelled);

/*
 Manages a set of nodes that evaluate to an outcome value.
 
 Use the -startWithNode:completion: method to begin execution.
 
 Completion is always asynchronous (non-blocking) with respect
 to the code that started executing the workflow.
 
 All nodes and the completion handler execute on the same thread.
 
 A workflow object retains itself while executing, so your code
 does not need to keep a strong reference to it.
 */
@interface JASWorkflow : NSObject

#pragma mark - Initializers

/* Designated initializer. */
- (id)initWithNodes:(NSArray *)nodes;


#pragma mark - Properties

/* Returns YES if the workflow is busy and cannot be modified or re-started. */
@property (readonly, nonatomic) BOOL isExecuting;

/* This dictionary can be used to share state between nodes. */
@property (readonly, nonatomic) NSMutableDictionary *userInfo;


#pragma mark - Methods

/* Causes the workflow to ignore any remaining nodes and complete ASAP. */
- (void)cancel;

/* 
 Associates a result from the last node available to execute 
 with a semantically relevant outcome for the workflow.
 This method must be used prior to starting the workflow.
 */
- (void)ifFinalNode:(JASWorkflowNode *)finalNode
     producesResult:(JASWorkflowNodeResult)result
         evaluateTo:(id)outcome;

/* 
 Resets the state of the workflow and its nodes in order 
 to execute again. Outcome mappings are preserved. The
 userInfo dictionary has all entries removed.
 Do not use this method while the workflow is executing.
 */
- (void)prepareForReuse;

/* Invoked when a node finishing executing. */
- (void)processResult:(JASWorkflowNodeResult)result
             fromNode:(JASWorkflowNode *)node;

/* 
 Begins running the workflow starting at the specified node.
 This is not a blocking/synchronous call.
 The completion handler is invoked on the thread from which this method is called.
 */
- (void)startExecutingWithNode:(JASWorkflowNode *)node
                    completion:(JASWorkflowCompletionBlock)completion;

@end
