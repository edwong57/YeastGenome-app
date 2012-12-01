//
//  FeatAnnotation.h
//  SGD_2
//
//  Created by Vivek on 29/06/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Features;

@interface FeatAnnotation :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * dateCreated;
@property (nonatomic, retain) NSString * descriptions;
@property (nonatomic, retain) NSString * geneticPos;
@property (nonatomic, retain) NSString * qualifier;
@property (nonatomic, retain) NSString * featAttribute;
@property (nonatomic, retain) NSString * nameDescription;
@property (nonatomic, retain) Features * annotToFeat;

@end



