// 
//  Features.m
//  SGD_2
//
//  Created by Vivek on 26/07/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "Features.h"

#import "Alias.h"
#import "FeatAnnotation.h"
#import "FeatLocation.h"
#import "GODetails.h"
#import "Interactions.h"
#import "Phenotypes.h"
#import "References.h"

@implementation Features 

@dynamic favorite;
@dynamic dbxrefId;
@dynamic featureName;
@dynamic dateCreated;
@dynamic source;
@dynamic usedDateMoreInfo;
@dynamic geneName;
@dynamic taxonId;
@dynamic featureType;
@dynamic aliases;
@dynamic annotation;
@dynamic interaction;
@dynamic location;
@dynamic phenotype;
@dynamic godetails;
@dynamic references;


- (int)favorite {
	[self willAccessValueForKey: @"favorite"];
	Boolean b = [[self primitiveValueForKey:@"favorite"] boolValue];
	[self didAccessValueForKey:@"favorite"];
	return [[NSNumber numberWithBool:b] intValue];
}

- (void)setFavorite:(int)b {
	[self willChangeValueForKey:@"favorite"];
	[self setPrimitiveValue:[NSNumber numberWithInt:b] forKey:@"favorite"];
	[self didChangeValueForKey:@"favorite"];
	
}

-(NSString *)displayName {
	if ([self.geneName length] > 0 && self.geneName != self.featureName) {
		return [NSString stringWithFormat:@"%@/%@", self.geneName, self.featureName];
	} else {
		return [NSString stringWithFormat:@"%@", self.featureName];
	}
}

-(NSString *)featType {
	if ([self.annotation.qualifier length] > 0) {
		return [NSString stringWithFormat:@"%@, %@", self.featureType, self.annotation.qualifier]; 
	} else {
		return [NSString stringWithFormat:@"%@", self.featureType];
	}
}

-(NSString *)searchfeaturesName {
	if ([self.featureName length] > 0) {
		return [NSString stringWithFormat:@"%@", self.featureName]; 
	} 
	else 
	{
		return nil;
	}
}

-(NSString *)searchGeneName {
	if ([self.geneName length] > 0)
	{
		return [NSString stringWithFormat:@"%@", self.geneName];
	} 
	else 
	{
		return nil;
	}
}

- (NSSet *)searchAliasesName{

    
    NSSet *aliasesSet = self.aliases;
	
	if ([aliasesSet count] != 0)
	{
		return aliasesSet;
	}
   
	else 
	{
		return nil;
	}
}

//- (NSSet *)searchGoDetails{
	
    
//    NSSet *godetailsSet = self.godetails;
	
//	if ([godetailsSet count] != 0)/
//	{/
//		return godetailsSet;
//	}
	
//	else /
	//{
//		return nil;
//	}
//}


-(NSString *)searchDescription
{
	if ([self.annotation.descriptions length] > 0) 
	{
		return	[NSString stringWithFormat:@"%@", self.annotation.descriptions];
	}
	else
	{
		return nil;
	}
}


-(NSString *)sequenceInformation {
	// setting sequence Info; add strand note if on crick strand
    

    NSSet *set = [NSSet setWithObjects:@"I", @"II",@"III",@"IV",@"V",@"VI",@"VII",@"VIII",@"IX",@"X", @"XI",@"XII",@"XIII",@"XIV",@"XV",@"XVI",@"XVII",@"XVIII",@"XIX",@"XX",@"XXI",@"XXII",@"XXIII",@"XXIV",@"XXV",nil];

    BOOL containsString2 = [set containsObject:self.location.chromosome];
    NSString *sequenceInfo; 
    self.location.chromosome = [self.location.chromosome stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];

    
    //NSInteger myInteger = [self.location.minCoord integerValue];

   
//    NSLog(@"Min %@ - Max %@ ",self.location.minCoord,self.location.maxCoord);
   /* if (containsString2) {
        //NSLog(@"Chromosome is Roman");
        sequenceInfo = [NSString stringWithFormat:@"Chr%@: %@ to %@", self.location.chromosome, self.location.minCoord, self.location.maxCoord];//, self.location.strand
    }   
    else{*/
    
        //NSLog(@"Chromosome is Not Roman");
        //check for chromosome is empty
    if ([self.location.chromosome length] == 0) {
   // if (self.location.chromosome == nil) {
            sequenceInfo = @"";
            
//               NSLog(@"Sequence INFO 1-->%@",sequenceInfo);  
            return sequenceInfo;
            
    }else{
    
    
    //*****
            
    if ([self.location.minCoord integerValue] == 0 && [self.location.maxCoord integerValue]== 0) {
                
                if (containsString2) {
                    //NSLog(@"Chromosome is Roman");
                    sequenceInfo = [NSString stringWithFormat:@"Chr%@", self.location.chromosome];//, self.location.strand
                }   
                else{
                    //NSLog(@"Chromosome is Not Roman");
                    
                    if ([self.location.chromosome hasPrefix:@"Chr"]) {
                        //NSLog(@"Chromosome Have Prefix Chr");
                        
                        sequenceInfo = [NSString stringWithFormat:@"%@", self.location.chromosome];//, self.location.strand
                    }else{
                        // NSLog(@"Chromosome Dont Have Prefix Chr");
                        
                        sequenceInfo = [NSString stringWithFormat:@"%@", self.location.chromosome];//, self.location.strand
                    }
                              
                  }
               
                      
       }else{
            
                  if (containsString2) {
 //                   NSLog(@"Chromosome is Roman");
                     sequenceInfo = [NSString stringWithFormat:@"Chr%@: %@ to %@", self.location.chromosome, self.location.minCoord, self.location.maxCoord];//, self.location.strand
                }   
                else{
    //                NSLog(@"Chromosome is Not Roman");
                    
                    
                     if ([self.location.chromosome hasPrefix:@"Chr"]) {
                     //NSLog(@"Chromosome Have Prefix Chr");
                     
                     sequenceInfo = [NSString stringWithFormat:@"%@: %@ to %@", self.location.chromosome, self.location.minCoord, self.location.maxCoord];//, self.location.strand
                     }else{
                     // NSLog(@"Chromosome Dont Have Prefix Chr");
                     
                     
                     
                     sequenceInfo = [NSString stringWithFormat:@"%@: %@ to %@", self.location.chromosome, self.location.minCoord, self.location.maxCoord];//, self.location.strand
                     }
                }

                
                }
                          
    }
    
    if ([self.location.strand isEqualToString:@"-"]) {
        sequenceInfo = [sequenceInfo stringByAppendingString:@"\n"];
        
        sequenceInfo = [sequenceInfo stringByAppendingString:@"Note: this feature is encoded on the Crick strand"];
    }
    
//    NSLog(@"Sequence INFO 2-->%@",sequenceInfo);    
    return sequenceInfo;

}
            //*****
                /*
         if ([self.location.chromosome hasPrefix:@"Chr"]) {
            //NSLog(@"Chromosome Have Prefix Chr");
            
            sequenceInfo = [NSString stringWithFormat:@"%@: %@ to %@", self.location.chromosome, self.location.minCoord, self.location.maxCoord];//, self.location.strand
        }else{
           // NSLog(@"Chromosome Dont Have Prefix Chr");
            
	
            sequenceInfo = [NSString stringWithFormat:@"%@: %@ to %@", self.location.chromosome, self.location.minCoord, self.location.maxCoord];//, self.location.strand
        }
        
        if ([self.location.strand isEqualToString:@"-"]) {
            sequenceInfo = [sequenceInfo stringByAppendingString:@"\n"];
            sequenceInfo = [sequenceInfo stringByAppendingString:@"Note: this feature is encoded on the Crick strand"];
        }
        return sequenceInfo;

     	}
      }*/
    
		
//}

-(NSString *)sequenceInformationTitle {
    NSString *sequenceInfoTitle;
    sequenceInfoTitle = [NSString stringWithFormat:@"Chr%@:", self.location.chromosome];
    return sequenceInfoTitle;
}


-(NSString *)seqInfoForReport {
	// setting sequence Info; add strand note if on crick strand
	NSString *sequenceInfo; 
	sequenceInfo = [NSString stringWithFormat:@"Chr%@:%@--%@", self.location.chromosome, self.location.minCoord, self.location.maxCoord];
	return sequenceInfo;
	
}


- (void)setGodetails:(NSSet *)resultset
{
	[self willChangeValueForKey:@"godetails"];
	[self setPrimitiveValue:resultset forKey:@"godetails"];
	[self didChangeValueForKey:@"godetails"];
}

- (void)setReferences:(NSSet *)referenceSet
{
	[self willChangeValueForKey:@"references"];
	[self setPrimitiveValue:referenceSet forKey:@"references"];
	[self didChangeValueForKey:@"references"];
}

- (void)setCitation:(NSString *)citation
{
	[self willChangeValueForKey:@""];
}





@end
