//
//  FirestorePluginJSONHelper.m
//  leave your Egos at the door
//
//  Created by Richard WIndley on 05/12/2017.
//

#import "FirestorePluginJSONHelper.h"
#import "FirestorePlugin.h"
@import Firebase;

@implementation FirestorePluginJSONHelper;

static NSString *datePrefix = @"__DATE:";
static NSString *geopointPrefix = @"__GEOPOINT:";
static NSString *fieldValueDelete = @"__DELETE";
static NSString *fieldValueServerTimestamp = @"__SERVERTIMESTAMP";

+ (NSDictionary *)toJSON:(NSDictionary *)values {
    NSMutableDictionary *result = [[NSMutableDictionary alloc]initWithCapacity:[values count]];

    for (id key in values) {
        id value = [values objectForKey:key];

        if ([value isKindOfClass:[NSDate class]]) {

            NSDate *date = (NSDate *)value;

            NSMutableString *dateString = [[NSMutableString alloc] init];
            [dateString appendString:datePrefix];
            [dateString appendString:[NSString stringWithFormat:@"%.0f000",[date timeIntervalSince1970]]];
            value = dateString;
        } else if ([value isKindOfClass:[FIRGeoPoint class]]) {
          FIRGeoPoint *point = (FIRGeoPoint *)value;
          
          NSMutableString *geopointString = [[NSMutableString alloc] init];
          [geopointString appendString:geopointPrefix];
          [geopointString appendString:[NSString stringWithFormat:@"%f,%f", point.latitude, point.longitude]];
          value = geopointString;
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            value = [self toJSON:value];
        }

        [result setObject:value forKey:key];
    }

    return result;
}

+ (NSDictionary *)fromJSON:(NSDictionary *)values {
    NSMutableDictionary *result = [[NSMutableDictionary alloc]initWithCapacity:[values count]];

    for (id key in values) {
        id value = [values objectForKey:key];

        if ([value isKindOfClass:[NSDictionary class]]) {
            value = [self fromJSON:value];
        } else {
            value = [self parseSpecial:value];
        }

        [result setObject:value forKey:key];
    }

    return result;
}

+ (NSObject *)parseSpecial:(NSObject *)value {

    if ([value isKindOfClass:[NSString class]]) {
        NSString *stringValue = (NSString *)value;

        NSUInteger datePrefixLength = (NSUInteger)datePrefix.length;
        NSUInteger geopointPrefixLength = (NSUInteger)geopointPrefix.length;

        if ([stringValue length] > datePrefixLength && [datePrefix isEqualToString:[stringValue substringToIndex:datePrefixLength]]) {
            NSTimeInterval timestamp = [[stringValue substringFromIndex:datePrefixLength] doubleValue];
            timestamp /= 1000;
            NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:timestamp];
            value = date;
        }

        if ([stringValue length] > geopointPrefixLength && [geopointPrefix isEqualToString:[stringValue substringToIndex:geopointPrefixLength]]) {
          NSArray *tmp = [[stringValue substringFromIndex:geopointPrefixLength] componentsSeparatedByString:@","];
          FIRGeoPoint *geopoint = [[FIRGeoPoint alloc] initWithLatitude:[[tmp objectAtIndex:0] doubleValue] longitude:[[tmp objectAtIndex:1] doubleValue]];
          value = geopoint;
        }
      
      
        if ([fieldValueDelete isEqualToString:stringValue]) {
            value = FIRFieldValue.fieldValueForDelete;
        }

        if ([fieldValueServerTimestamp isEqualToString:stringValue]) {
            value = FIRFieldValue.fieldValueForServerTimestamp;
        }
    }

    return value;
}

+ (void)setDatePrefix:(NSString *)newDatePrefix {
    datePrefix = newDatePrefix;
}

+ (void)setGeopointPrefix:(NSString *)newGeopointPrefix {
    geopointPrefix = newGeopointPrefix;
}

+ (void)setFieldValueDelete:(NSString *)newFieldValueDelete {
    fieldValueDelete = newFieldValueDelete;
}

+ (void)setFieldValueServerTimestamp:(NSString *)newFieldValueServerTimestamp {
    fieldValueServerTimestamp = newFieldValueServerTimestamp;
}
@end
