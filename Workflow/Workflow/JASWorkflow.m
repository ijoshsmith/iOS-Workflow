// JASWorkflow.m
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

#import "JASWorkflow.h"

static NSString *const kTranslationFinalNodeKey  = @"kTranslationFinalNodeKey";
static NSString *const kTranslationNodeResultKey = @"kTranslationNodeResultKey";
static NSString *const kTranslationOutcomeKey    = @"kTranslationOutcomeKey";

@implementation JASWorkflow
{
    BOOL                       _cancelled;
    JASWorkflowCompletionBlock _completion;
    JASWorkflow               *_keepAliveRef;
    NSSet                     *_nodes;
    NSOperationQueue          *_queue;
    NSMutableSet              *_translations;
}

- (id)initWithNodes:(NSArray *)nodes
{
    NSParameterAssert([nodes count]);
    
    self = [super init];
    if (self)
    {
        _nodes = [NSSet setWithArray:nodes];
        [_nodes makeObjectsPerformSelector:@selector(setWorkflow:)
                                withObject:self];
        _translations = [NSMutableSet set];
    }
    return self;
}

#pragma mark - Properties

@dynamic isExecuting;
- (BOOL)isExecuting
{
    return _keepAliveRef != nil;
}

@synthesize userInfo=_userInfo;
- (NSMutableDictionary *)userInfo
{
    return _userInfo ?: (_userInfo = [NSMutableDictionary dictionary]);
}

#pragma mark - Methods

- (void)cancel { _cancelled = self.isExecuting; }

- (void)ifFinalNode:(JASWorkflowNode *)finalNode
     producesResult:(JASWorkflowNodeResult)result
         evaluateTo:(id)outcome
{
    NSParameterAssert(finalNode);
    NSParameterAssert(outcome);
    NSAssert(!self.isExecuting, @"Workflow is executing");
    
    [_translations addObject:@{
      kTranslationFinalNodeKey  : finalNode,
      kTranslationNodeResultKey : @(result),
      kTranslationOutcomeKey    : outcome
     }];
}

- (void)prepareForReuse
{
    NSAssert(!self.isExecuting, @"Workflow is executing");
    _cancelled = NO;
    [_userInfo removeAllObjects];
    [_nodes makeObjectsPerformSelector:@selector(prepareForReuse)];
}

- (void)processResult:(JASWorkflowNodeResult)result
             fromNode:(JASWorkflowNode *)node
{
    NSParameterAssert(node);
    NSAssert(self.isExecuting, @"Workflow is not executing");
    
    if (_cancelled)
        result = 0;
    
    JASWorkflowNode *nextNode = nil;
    switch (result)
    {
        case JASWorkflowNodeResultPending:
            // The node needs to perform a long-running task.
            return;
            
        case JASWorkflowNodeResultComplete: {
            NSAssert([node isKindOfClass:[JASWorkItem class]],
                     @"result/node type mismatch");
            JASWorkItem *workItem = (JASWorkItem *)node;
            nextNode = workItem.next;
        }   break;
    
        case JASWorkflowNodeResultYes: {
            NSAssert([node isKindOfClass:[JASDecision class]],
                     @"result/node type mismatch");
            JASDecision *decision = (JASDecision *)node;
            nextNode = decision.yes;
        }   break;
            
        case JASWorkflowNodeResultNo: {
            NSAssert([node isKindOfClass:[JASDecision class]],
                     @"result/node type mismatch");
            JASDecision *decision = (JASDecision *)node;
            nextNode = decision.no;
        }   break;
            
        case JASWorkflowNodeResultError: {
            nextNode = nil;
        }   break;    
    }
    
    if (nextNode)
        [self executeNode:nextNode];
    else
        [self completeWithResult:result finalNode:node];
}

- (void)startExecutingWithNode:(JASWorkflowNode *)node
           completion:(JASWorkflowCompletionBlock)completion
{
    NSParameterAssert(node);
    NSAssert(!self.isExecuting, @"Workflow interrupted while executing");
    
    // This ivar causes the workflow to retain itself, which enables
    // client code to use this class via stack variables instead of
    // needing to create a property or ivar to retain the workflow
    // until it completes. This reference is released after the
    // workflow completes, enabling -dealloc to execute.
    _keepAliveRef = self;
    
    // Remember which operation queue the workflow started on, so that
    // its nodes and completion handler all execute on the same thread.
    _queue = [NSOperationQueue currentQueue];
    
    // Copy the block to the heap since it won't run during this callstack.
    _completion = [completion copy];
    
    [self executeNode:node];
}

#pragma mark - Helper methods

- (void)completeWithResult:(JASWorkflowNodeResult)result
                 finalNode:(JASWorkflowNode *)finalNode
{
    JASWorkflowCompletionBlock completion = _completion;
    _completion = nil;
    if (completion)
    {
        [_queue addOperationWithBlock:^
        {
            if (_cancelled)
            {
                completion(nil, nil, YES);
            }
            else
            {
                id outcome = [self translateResult:result
                                     fromFinalNode:finalNode];
                completion(outcome, finalNode, NO);
            }
            _keepAliveRef = nil;
         }];
    }
    else
    {
        _keepAliveRef = nil;
    }
}

- (void)executeNode:(JASWorkflowNode *)node
{
    [_queue addOperationWithBlock:^{
        JASWorkflowNodeResult result = [node execute];
        [self processResult:result fromNode:node];
    }];
}

- (id)translateResult:(JASWorkflowNodeResult)result
        fromFinalNode:(JASWorkflowNode *)finalNode
{
    id outcome = nil;
    for (NSDictionary *translation in _translations)
    {
        JASWorkflowNode *node = translation[kTranslationFinalNodeKey];
        if (finalNode != node)
            continue;
        
        NSNumber *resultBox = translation[kTranslationNodeResultKey];
        if (result != [resultBox intValue])
            continue;
        
        outcome = translation[kTranslationOutcomeKey];
        break;
    }
    return outcome;
}

@end
