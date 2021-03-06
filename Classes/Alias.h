//
//  Alias.h
//  SGD_2
//
//  Created by Vivek on 29/06/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Features;

@interface Alias :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * dateCreated;
@property (nonatomic, retain) NSString * aliasName;
@property (nonatomic, retain) NSString * aliasType;
@property (nonatomic, retain) Features * aliasToFeat;

@end



