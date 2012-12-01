//
//  Features.h
//  SGD_2
//
//  Created by Vivek on 26/07/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Alias;
@class FeatAnnotation;
@class FeatLocation;
@class GODetails;
@class Interactions;
@class Phenotypes;
@class References;

@interface Features :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * dbxrefId;
@property (nonatomic, retain) NSString * featureName;
@property (nonatomic, retain) NSString * dateCreated;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSDate * usedDateMoreInfo;
@property (nonatomic, retain) NSString * geneName;
@property (nonatomic, retain) NSNumber * taxonId;
@property (nonatomic, retain) NSString * featureType;
@property (nonatomic, retain) NSSet* aliases;
@property (nonatomic, retain) FeatAnnotation * annotation;
@property (nonatomic, retain) NSSet* interaction;
@property (nonatomic, retain) FeatLocation * location;
@property (nonatomic, retain) NSSet* phenotype;
//@property (nonatomic, retain) GODetails * godetails;
@property (nonatomic, retain) NSSet* godetails;
@property (nonatomic, retain) NSSet* references;

@end


@interface Features (CoreDataGeneratedAccessors)

- (void)addAliasesObject:(Alias *)value;
- (void)removeAliasesObject:(Alias *)value;
- (void)addAliases:(NSSet *)value;
- (void)removeAliases:(NSSet *)value;

- (void)addInteractionObject:(Interactions *)value;
- (void)removeInteractionObject:(Interactions *)value;
- (void)addInteraction:(NSSet *)value;
- (void)removeInteraction:(NSSet *)value;

- (void)addPhenotypeObject:(Phenotypes *)value;
- (void)removePhenotypeObject:(Phenotypes *)value;
- (void)addPhenotype:(NSSet *)value;
- (void)removePhenotype:(NSSet *)value;

- (void)addGodetailsObject:(GODetails *)value;
- (void)removeGodetailsObject:(GODetails *)value;
- (void)addGodetails:(NSSet *)value;
- (void)removeGodetails:(NSSet *)value;

- (void)addReferencesObject:(References *)value;
- (void)removeReferencesObject:(References *)value;
- (void)addReferences:(NSSet *)value;
- (void)removeReferences:(NSSet *)value;

- (NSString *)displayName;
- (NSString *)featType;
- (NSString *)sequenceInformation;
-(NSString *)sequenceInformationTitle;


- (NSString *)searchfeaturesName;
- (NSString *)searchGeneName;
- (NSSet *)searchAliasesName;
//- (NSSet *)searchGodetails;
- (NSString *)searchDescription;
- (int)favorite;
- (void)setFavorite:(int)b;
-(NSString *)seqInfoForReport;

//-(void)getGodetails:(NSSet *)resultset;
- (void)setGodetails:(NSSet *)resultset;
- (void)setReferences:(NSSet *)referenceSet;
- (void)setCitation:(NSString *)citation;

@end

