//
//  DataCache.m
//  TopPlaces
//
//  Created by Lucas Charrier on 25/10/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import "DataCache.h"

@implementation DataCache

//URL of cache directory
static NSURL * cacheURL;

// file properties that we are interested in
static NSArray *fileProperties;

+ (NSFileManager*) fileManager
{
    return [[NSFileManager alloc] init];
}

+ (NSURL *) cacheURL
{
    if(!cacheURL){
        NSArray * cachesArray = [[self fileManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
        cacheURL = [cachesArray lastObject];
    }
    return cacheURL;
}

+ (NSArray *) fileProperties 
{
	if (!fileProperties) { // Create file properties array (if none already)
		
		fileProperties = 
        [NSArray arrayWithObjects: NSURLNameKey, NSURLIsDirectoryKey, NSURLCreationDateKey, nil];		
	}	
	
	return fileProperties;
}

+ (void) cacheInspection
{
    NSFileManager * fileManager = [self fileManager];
    
    // Get a handle to all of the files in the caches directory
    NSArray* URLsInCache = [NSArray arrayWithArray:[fileManager contentsOfDirectoryAtURL:self.cacheURL includingPropertiesForKeys:fileProperties options:NSDirectoryEnumerationSkipsHiddenFiles error:nil]];
    
    int cacheSize = 0;
    
    for(NSURL* url in URLsInCache)
    {
        cacheSize += [[[[self fileManager] attributesOfItemAtPath:url.path error:nil] valueForKey:NSFileSize]intValue];
    }
    
    if(cacheSize > MAXIMUM_CACHE_SIZE)
    {
        URLsInCache = [URLsInCache sortedArrayUsingComparator: ^(id item1, id item2) {
			
			NSDate *date1 = [ [fileManager attributesOfItemAtPath:[item1 path] error:nil]
                             valueForKey:NSFileModificationDate];			
			NSDate *date2 = [ [fileManager attributesOfItemAtPath:[item2 path] error:nil]
                             valueForKey:NSFileModificationDate];			
			return [date2 compare:date1];			
		}];
        
        NSMutableArray * URLsInCacheBis = [NSMutableArray arrayWithArray:URLsInCache];
        
        while (cacheSize > TRIM_CACHE_SIZE & URLsInCacheBis.count > 0) {
            NSURL * url = [URLsInCacheBis lastObject];
            [[self fileManager] removeItemAtURL:url error:nil];
            cacheSize -= [[[[self fileManager] attributesOfItemAtPath:url.path error:nil] valueForKey:NSFileSize] intValue];
        }
    }
}

+ (NSURL *) getURLforFile: (NSString *) name
{
    return [NSURL URLWithString:name relativeToURL:cacheURL];
}

+ (NSData *) fetchData: (NSString *) name
{
    return [[NSData alloc] initWithContentsOfURL:[self getURLforFile:name]];
}

+ (void) storeData: (NSString *)name: (NSData *) data
{
    [data writeToURL:[self getURLforFile:name] atomically:YES];
    
    dispatch_queue_t cacheInspection = dispatch_queue_create("cacheInspection", NULL);
    dispatch_async(cacheInspection, ^{[self cacheInspection];});
    dispatch_release(cacheInspection);
    
}

@end
