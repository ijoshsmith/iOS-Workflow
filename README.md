iOS Workflow
============

A lightweight workflow component for iOS applications.
This code is made available under the MIT license.
All of the files that you should add to your project are in the Workflow subdirectory, and are prefixed with <b>JAS</b>.

Why use a workflow?
===================

Modeling complex and/or asynchronous application logic as a workflow makes it easier to decompose a difficult problem into 
loosely coupled steps, or "nodes" of responsibility. This enables your code to mimic a workflow diagram that expresses an
overall solution to the problem being solved.

Workflow objects
================

<b>JASWorkflow</b> manages a graph of <b>JASWorkflowNode</b> objects and notifies your code when the workflow completes.

A decision node, of type <b>JASDecision</b>, acts as a predicate that causes one of its two associated nodes to execute.

A work item node, of type <b>JASWorkItem</b>, represents a task that must be performed to complete the workflow.

When a node executes it must immediately evaluate to a result. If the node cannot determine its result at that time
it should evaluate to 'Pending' and report its result to the workflow later. This scenario is commonly seen when a node
must wait for a Web service response to arrive before it can determine its result.
