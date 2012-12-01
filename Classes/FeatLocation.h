//
//  FeatLocation.h
//  SGD_2
//
//  Created by Vivek on 29/06/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Features;

@interface FeatLocation :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * strand;
@property (nonatomic, retain) NSString * coordVer;
@property (nonatomic, retain) NSNumber * maxCoord;
@property (nonatomic, retain) NSString * chromosome;
@property (nonatomic, retain) NSNumber * minCoord;
@property (nonatomic, retain) NSString * dateCreated;
@property (nonatomic, retain) Features * locToFeat;

@end



