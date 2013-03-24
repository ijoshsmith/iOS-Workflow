// JASWorkflowNode.h
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

// NS_ENUM is the preferred way to declare an enum starting in iOS 6.
#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

/* Values a node can return from its overriden -execute method. */
typedef NS_ENUM(int8_t, JASWorkflowNodeResult)
{
    JASWorkflowNodeResultComplete = 1,
    JASWorkflowNodeResultError    = 2,
    JASWorkflowNodeResultYes      = 3,
    JASWorkflowNodeResultNo       = 4,
    JASWorkflowNodeResultPending  = 5,
};

@class JASWorkflow;

/* Base class for a node in a workflow. */
@interface JASWorkflowNode : NSObject

/* Invoked when the node should perform its task. */
- (JASWorkflowNodeResult)execute;

/* 
 Invoked before the owning workflow runs again.
 Overrides should call the super implementation.
 */
- (void)prepareForReuse;

/* 
 Subclasses use this method to inform the workflow that
 they have finished executing and a result is available.
 Use this method if -execute returns 'Pending'.
 */
- (void)reportPendingResult:(JASWorkflowNodeResult)result;

/* 
 The error this node encountered while executing, or nil.
 This value is only meaningful if the node's result is 'Error'.
 */
@property (nonatomic) NSError *error;

/* The workflow that owns this node. */
@property (weak, nonatomic) JASWorkflow *workflow;

@end
