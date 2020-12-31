//
//  SIngleDemo.m
//  GCDAPi
//
//  Created by 刘洋 on 2020/12/18.
//

#import "SIngleDemo.h"


static SIngleDemo * _single = nil;
@implementation SIngleDemo

- (instancetype)sharedManager {
    static dispatch_once_t onceTocken;
    dispatch_once(&onceTocken, ^{
        _single = [[SIngleDemo alloc]init];
    });
    return _single;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _single = [super allocWithZone:zone];
    });
    return _single;
}

- (id)copyWithZone:(NSZone *)zone {
    return _single;
}

@end
