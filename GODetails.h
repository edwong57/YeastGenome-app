//
//  GODetails.h
//  SGD_2
//
//  Created by Vivek on 26/07/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Features;

@interface GODetails :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * goType;
@property (nonatomic, retain) NSString * evidence;
@property (nonatomic, retain) NSString * assignedBy;
@property (nonatomic, retain) NSString * annotationType;
@property (nonatomic, retain) NSString * annotation;
@property (nonatomic, retain) NSString * definition;
@property (nonatomic, retain) NSString * goId;


@property (nonatomic, retain) NSString * goReferences;
@property (nonatomic, retain) NSString * pubMedId;

@property (nonatomic, retain) Features * gotofeat;

@end



