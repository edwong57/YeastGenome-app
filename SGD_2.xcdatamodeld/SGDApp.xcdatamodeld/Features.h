//
//  Features.h
//  SGDApp
//
//  Created by Edith Wong on 8/23/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Alias;
@class FeatAnnotation;
@class FeatLocation;

@interface Features :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * dbxrefId;
@property (nonatomic, retain) NSString * dateCreated;
@property (nonatomic, retain) NSString * featureType;
@property (nonatomic, retain) NSString * geneName;
@property (nonatomic, retain) NSNumber * taxonId;
@property (nonatomic, retain) NSString * featureName;
@property (nonatomic, retain) FeatLocation * location;
@property (nonatomic, retain) NSSet* aliases;
@property (nonatomic, retain) FeatAnnotation * annotation;

@end


@interface Features (CoreDataGeneratedAccessors)
- (void)addAliasesObject:(Alias *)value;
- (void)removeAliasesObject:(Alias *)value;
- (void)addAliases:(NSSet *)value;
- (void)removeAliases:(NSSet *)value;

@end

