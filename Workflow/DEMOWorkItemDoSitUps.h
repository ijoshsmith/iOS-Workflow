//
//  DEMOWorkItemDoSitUps.h
//  Workflow
//
//  Created by Josh on 3/22/13.
//  Copyright (c) 2013 iJoshSmith. All rights reserved.
//

#import "JASWorkItem.h"

/* 
 This workflow node causes the imaginary test subject
 to do sit-ups, which takes several seconds to complete.
 */
@interface DEMOWorkItemDoSitUps : JASWorkItem

- (id)initWithCount:(NSUInteger)count;

@end
