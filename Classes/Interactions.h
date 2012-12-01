//
//  Interactions.h
//  SGD_2
//
//  Created by Vivek on 14/07/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Features;

@interface Interactions :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * action;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * intDescription;
@property (nonatomic, retain) NSString * intReferences;
@property (nonatomic, retain) NSString * featureType;
@property (nonatomic, retain) NSString * geneName;
@property (nonatomic, retain) NSString * experimentType;
@property (nonatomic, retain) NSString * featureName;
@property (nonatomic, retain) Features * intertofeat;

@end



