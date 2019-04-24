//
//  ViteStatistics.m
//  Action
//
//  Created by haoshenyang on 2018/12/12.
//

#import "ViteStatistics.h"
#import <BaiduMobStat/BaiduMobStat.h>

@implementation ViteStatistics

- (void)setChannelId:(NSString *)channelId {
    [BaiduMobStat defaultStat].channelId = channelId;
}

- (void)setUserId:(NSString *)userId {
    [BaiduMobStat defaultStat].userId = userId;

}

- (void)setShortAppVersion:(NSString *)shortAppVersion {
    [BaiduMobStat defaultStat].shortAppVersion = shortAppVersion;
}

- (void)startWithAppId:(NSString *)appKey {
    [[BaiduMobStat defaultStat] startWithAppId:appKey];
}

- (NSString *)getDeviceCuid {
    return [[BaiduMobStat defaultStat] getDeviceCuid];
}

- (void)logEvent:(NSString *)eventId eventLabel:(NSString *)eventLabel {
    [[BaiduMobStat defaultStat] logEvent:eventId eventLabel:eventLabel];
}

- (void)logEvent:(NSString *)eventId eventLabel:(NSString *)eventLabel attributes:(NSDictionary *)attributes {
    [[BaiduMobStat defaultStat] logEvent:eventId eventLabel:eventLabel attributes:attributes];
}

- (void)pageviewStartWithName:(NSString *)name {
    [[BaiduMobStat defaultStat] pageviewStartWithName:name];
}

- (void)pageviewEndWithName:(NSString *)name {
    [[BaiduMobStat defaultStat] pageviewEndWithName:name];
}


@end
