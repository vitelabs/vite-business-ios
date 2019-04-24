//
//  ViteStatistics.h
//  Action
//
//  Created by haoshenyang on 2018/12/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface ViteStatistics : NSObject


@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *shortAppVersion;

- (void)startWithAppId:(NSString *)appKey;
- (NSString *)getDeviceCuid;
- (void)logEvent:(NSString *)eventId eventLabel:(NSString *)eventLabel;
- (void)logEvent:(NSString *)eventId eventLabel:(NSString *)eventLabel attributes:(NSDictionary *)attributes;
- (void)pageviewStartWithName:(NSString *)name;
- (void)pageviewEndWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
