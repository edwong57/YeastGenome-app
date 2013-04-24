//
//  staticFunctionClass.h
//  SGD_Vivek
//
//  Created by Vivek on 29/04/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface staticFunctionClass : NSObject {

}

+ (void) initializeSearchObjFeat;
+(void)setSearchObjFeat:(NSString*)newValue;
+ (NSString*) getSearchObjFeat;

+ (void) initializeFeatObjListFeat;
+(void)setFeatObjFeat:(NSString*)newValue;
+ (NSString*) getFeatObjFeat;

+ (void) initializeFavObjFeat;
+(void)setFavObjFeat:(NSString*)newValue;
+ (NSString*) getFavObjFeat;

+ (void) initializeGeneName;
+ (void)setGeneName:(NSString *)newValue;
+ (NSString *)getGeneName;

+ (void) initializeMolFnName;
+ (void)setMolFnName:(NSString *)newValue;
+ (NSString *)getMolFnName;

+ (void) initializeBioPrName;
+ (void)setBioPrName:(NSString *)newValue;
+ (NSString *)getBioPrName;

+ (void) initializeCelCmName;
+ (void)setCelCmName:(NSString *)newValue;
+ (NSString *)getCelCmName;

+ (void) initRecipient;
+ (void)setRecipient:(NSArray *)newValue;
+ (NSMutableArray *)getRecipient;


+ (void) initSubjectLine;
+ (void)setSubjectLine:(NSString *)newValue;
+ (NSString *)getSubjectLine;

+ (void) initMessageBody;
+ (void)setMessageBody:(NSString *)newValue;
+ (NSString *)getMessageBody;

//
+ (void) initInteractionDict;
+ (void)setInteractionDict:(NSDictionary *)newValue;
+ (NSDictionary *)getInteractionDict;

+ (void) initPhenoDict;
+ (void) setPhenoDict:(NSDictionary *)newValue;
+ (NSDictionary *)getPhenoDict;


//Predicate String

+ (void) initPredicateStr;
+ (void)setPredicateStr:(NSString *)newValue;
+ (NSString *)getPredicateStr;

//FeatGOType String

+ (void) initFeatGOTypeStr;
+ (void)setFeatGOTypeStr:(NSString *)newValue;
+ (NSString *)getFeatGOTypeStr;

+ (void) initPreviewItem;
+ (void)setRprtPreview:(NSMutableArray *)newValue;
+ (NSMutableArray *)getRprtPreview;

+ (void) initializeFeatureType;
+ (void)setFeatureType:(NSString *)newValue;
+ (NSString *)getFeatureType;

// Browse Image co ordinates
+ (void) initBrowseImg;
+ (void)setBrowseImg:(NSString *)newValue;
+ (NSString *)getBrowseImg;

+ (void) initReferencePub;
+ (void)setReferencePub:(NSString *)newValue;
+ (NSString *)getReferencePub;

@end
