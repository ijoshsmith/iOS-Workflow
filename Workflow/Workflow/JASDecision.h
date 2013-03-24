// JASDecision.h
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

#import "JASWorkflowNode.h"

/* Macro for converting a BOOL into its equivalent JASWorkflowNodeResult value. */
#define JASDecisionResultFromBOOL(_bool) (_bool ? JASWorkflowNodeResultYes : JASWorkflowNodeResultNo)

/* Represents a predicate in a workflow. */
@interface JASDecision : JASWorkflowNode

/*
 The node to execute if the decision is 'No', 
 or nil if 'No' ends the workflow.
 */
@property (weak, nonatomic) JASWorkflowNode *no;

/* 
 The node to execute if the decision is 'Yes', 
 or nil if 'Yes' ends the workflow.
 */
@property (weak, nonatomic) JASWorkflowNode *yes;

@end
