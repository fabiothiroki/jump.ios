/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright (c) 2012, Janrain, Inc.

 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation and/or
   other materials provided with the distribution.
 * Neither the name of the Janrain, Inc. nor the names of its
   contributors may be used to endorse or promote products derived from this
   software without specific prior written permission.


 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog(...)
#endif

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)


#import "JROinoinoL2Object.h"

@interface JROinoinoL2Object ()
@property BOOL canBeUpdatedOrReplaced;
@end

@implementation JROinoinoL2Object
{
    NSString *_string1;
    NSString *_string2;
    JROinoinoL3Object *_oinoinoL3Object;
}
@dynamic string1;
@dynamic string2;
@dynamic oinoinoL3Object;
@synthesize canBeUpdatedOrReplaced;

- (NSString *)string1
{
    return _string1;
}

- (void)setString1:(NSString *)newString1
{
    [self.dirtyPropertySet addObject:@"string1"];

    [_string1 autorelease];
    _string1 = [newString1 copy];
}

- (NSString *)string2
{
    return _string2;
}

- (void)setString2:(NSString *)newString2
{
    [self.dirtyPropertySet addObject:@"string2"];

    [_string2 autorelease];
    _string2 = [newString2 copy];
}

- (JROinoinoL3Object *)oinoinoL3Object
{
    return _oinoinoL3Object;
}

- (void)setOinoinoL3Object:(JROinoinoL3Object *)newOinoinoL3Object
{
    [self.dirtyPropertySet addObject:@"oinoinoL3Object"];

    [_oinoinoL3Object autorelease];
    _oinoinoL3Object = [newOinoinoL3Object retain];
}

- (id)init
{
    if ((self = [super init]))
    {
        self.captureObjectPath = @"/oinoinoL1Object/oinoinoL2Object";
        self.canBeUpdatedOrReplaced = YES;

        [self.dirtyPropertySet setSet:[NSMutableSet setWithObjects:@"string1", @"string2", @"oinoinoL3Object", nil]];
    }
    return self;
}

+ (id)oinoinoL2Object
{
    return [[[JROinoinoL2Object alloc] init] autorelease];
}

- (id)copyWithZone:(NSZone*)zone
{
    JROinoinoL2Object *oinoinoL2ObjectCopy = (JROinoinoL2Object *)[super copy];

    oinoinoL2ObjectCopy.string1 = self.string1;
    oinoinoL2ObjectCopy.string2 = self.string2;
    oinoinoL2ObjectCopy.oinoinoL3Object = self.oinoinoL3Object;

    return oinoinoL2ObjectCopy;
}

- (NSDictionary*)toDictionary
{
    NSMutableDictionary *dict = 
        [NSMutableDictionary dictionaryWithCapacity:10];

    [dict setObject:(self.string1 ? self.string1 : [NSNull null])
             forKey:@"string1"];
    [dict setObject:(self.string2 ? self.string2 : [NSNull null])
             forKey:@"string2"];
    [dict setObject:(self.oinoinoL3Object ? [self.oinoinoL3Object toDictionary] : [NSNull null])
             forKey:@"oinoinoL3Object"];

    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (id)oinoinoL2ObjectObjectFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath
{
    if (!dictionary)
        return nil;

    JROinoinoL2Object *oinoinoL2Object = [JROinoinoL2Object oinoinoL2Object];


    oinoinoL2Object.string1 =
        [dictionary objectForKey:@"string1"] != [NSNull null] ? 
        [dictionary objectForKey:@"string1"] : nil;

    oinoinoL2Object.string2 =
        [dictionary objectForKey:@"string2"] != [NSNull null] ? 
        [dictionary objectForKey:@"string2"] : nil;

    oinoinoL2Object.oinoinoL3Object =
        [dictionary objectForKey:@"oinoinoL3Object"] != [NSNull null] ? 
        [JROinoinoL3Object oinoinoL3ObjectObjectFromDictionary:[dictionary objectForKey:@"oinoinoL3Object"] withPath:oinoinoL2Object.captureObjectPath] : nil;

    [oinoinoL2Object.dirtyPropertySet removeAllObjects];
    [oinoinoL2Object.dirtyArraySet removeAllObjects];
    
    return oinoinoL2Object;
}

- (void)updateFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath
{
    DLog(@"%@ %@", capturePath, [dictionary description]);

    NSSet *dirtyPropertySetCopy = [[self.dirtyPropertySet copy] autorelease];
    NSSet *dirtyArraySetCopy    = [[self.dirtyArraySet copy] autorelease];

    self.canBeUpdatedOrReplaced = YES;

    if ([dictionary objectForKey:@"string1"])
        self.string1 = [dictionary objectForKey:@"string1"] != [NSNull null] ? 
            [dictionary objectForKey:@"string1"] : nil;

    if ([dictionary objectForKey:@"string2"])
        self.string2 = [dictionary objectForKey:@"string2"] != [NSNull null] ? 
            [dictionary objectForKey:@"string2"] : nil;

    if ([dictionary objectForKey:@"oinoinoL3Object"] == [NSNull null])
        self.oinoinoL3Object = nil;
    else if ([dictionary objectForKey:@"oinoinoL3Object"] && !self.oinoinoL3Object)
        self.oinoinoL3Object = [JROinoinoL3Object oinoinoL3ObjectObjectFromDictionary:[dictionary objectForKey:@"oinoinoL3Object"] withPath:self.captureObjectPath];
    else if ([dictionary objectForKey:@"oinoinoL3Object"])
        [self.oinoinoL3Object updateFromDictionary:[dictionary objectForKey:@"oinoinoL3Object"] withPath:self.captureObjectPath];

    [self.dirtyPropertySet setSet:dirtyPropertySetCopy];
    [self.dirtyArraySet setSet:dirtyArraySetCopy];
}

- (void)replaceFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath
{
    DLog(@"%@ %@", capturePath, [dictionary description]);

    NSSet *dirtyPropertySetCopy = [[self.dirtyPropertySet copy] autorelease];
    NSSet *dirtyArraySetCopy    = [[self.dirtyArraySet copy] autorelease];

    self.canBeUpdatedOrReplaced = YES;

    self.string1 =
        [dictionary objectForKey:@"string1"] != [NSNull null] ? 
        [dictionary objectForKey:@"string1"] : nil;

    self.string2 =
        [dictionary objectForKey:@"string2"] != [NSNull null] ? 
        [dictionary objectForKey:@"string2"] : nil;

    if (![dictionary objectForKey:@"oinoinoL3Object"] || [dictionary objectForKey:@"oinoinoL3Object"] == [NSNull null])
        self.oinoinoL3Object = nil;
    else if (!self.oinoinoL3Object)
        self.oinoinoL3Object = [JROinoinoL3Object oinoinoL3ObjectObjectFromDictionary:[dictionary objectForKey:@"oinoinoL3Object"] withPath:self.captureObjectPath];
    else
        [self.oinoinoL3Object replaceFromDictionary:[dictionary objectForKey:@"oinoinoL3Object"] withPath:self.captureObjectPath];

    [self.dirtyPropertySet setSet:dirtyPropertySetCopy];
    [self.dirtyArraySet setSet:dirtyArraySetCopy];
}

- (NSDictionary *)toUpdateDictionary
{
    NSMutableDictionary *dict =
         [NSMutableDictionary dictionaryWithCapacity:10];

    if ([self.dirtyPropertySet containsObject:@"string1"])
        [dict setObject:(self.string1 ? self.string1 : [NSNull null]) forKey:@"string1"];

    if ([self.dirtyPropertySet containsObject:@"string2"])
        [dict setObject:(self.string2 ? self.string2 : [NSNull null]) forKey:@"string2"];

    if ([self.dirtyPropertySet containsObject:@"oinoinoL3Object"])
        [dict setObject:(self.oinoinoL3Object ?
                              [self.oinoinoL3Object toReplaceDictionaryIncludingArrays:NO] :
                              [[JROinoinoL3Object oinoinoL3Object] toReplaceDictionaryIncludingArrays:NO]) /* Use the default constructor to create an empty object */
                 forKey:@"oinoinoL3Object"];
    else if ([self.oinoinoL3Object needsUpdate])
        [dict setObject:[self.oinoinoL3Object toUpdateDictionary]
                 forKey:@"oinoinoL3Object"];

    return dict;
}

- (NSDictionary *)toReplaceDictionaryIncludingArrays:(BOOL)includingArrays
{
    NSMutableDictionary *dict =
         [NSMutableDictionary dictionaryWithCapacity:10];

    [dict setObject:(self.string1 ? self.string1 : [NSNull null]) forKey:@"string1"];
    [dict setObject:(self.string2 ? self.string2 : [NSNull null]) forKey:@"string2"];

    [dict setObject:(self.oinoinoL3Object ?
                          [self.oinoinoL3Object toReplaceDictionaryIncludingArrays:YES] :
                          [[JROinoinoL3Object oinoinoL3Object] toUpdateDictionary]) /* Use the default constructor to create an empty object */
             forKey:@"oinoinoL3Object"];

    return dict;
}

- (BOOL)needsUpdate
{
    if ([self.dirtyPropertySet count])
         return YES;

    if([self.oinoinoL3Object needsUpdate])
        return YES;

    return NO;
}

- (BOOL)isEqualToOinoinoL2Object:(JROinoinoL2Object *)otherOinoinoL2Object
{
    if (!self.string1 && !otherOinoinoL2Object.string1) /* Keep going... */;
    else if ((self.string1 == nil) ^ (otherOinoinoL2Object.string1 == nil)) return NO; // xor
    else if (![self.string1 isEqualToString:otherOinoinoL2Object.string1]) return NO;

    if (!self.string2 && !otherOinoinoL2Object.string2) /* Keep going... */;
    else if ((self.string2 == nil) ^ (otherOinoinoL2Object.string2 == nil)) return NO; // xor
    else if (![self.string2 isEqualToString:otherOinoinoL2Object.string2]) return NO;

    if (!self.oinoinoL3Object && !otherOinoinoL2Object.oinoinoL3Object) /* Keep going... */;
    else if (!self.oinoinoL3Object && [otherOinoinoL2Object.oinoinoL3Object isEqualToOinoinoL3Object:[JROinoinoL3Object oinoinoL3Object]]) /* Keep going... */;
    else if (!otherOinoinoL2Object.oinoinoL3Object && [self.oinoinoL3Object isEqualToOinoinoL3Object:[JROinoinoL3Object oinoinoL3Object]]) /* Keep going... */;
    else if (![self.oinoinoL3Object isEqualToOinoinoL3Object:otherOinoinoL2Object.oinoinoL3Object]) return NO;

    return YES;
}

- (NSDictionary*)objectProperties
{
    NSMutableDictionary *dict = 
        [NSMutableDictionary dictionaryWithCapacity:10];

    [dict setObject:@"NSString" forKey:@"string1"];
    [dict setObject:@"NSString" forKey:@"string2"];
    [dict setObject:@"JROinoinoL3Object" forKey:@"oinoinoL3Object"];

    return [NSDictionary dictionaryWithDictionary:dict];
}

- (void)dealloc
{
    [_string1 release];
    [_string2 release];
    [_oinoinoL3Object release];

    [super dealloc];
}
@end