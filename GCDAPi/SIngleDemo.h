//
//  SIngleDemo.h
//  GCDAPi
//
//  Created by 刘洋 on 2020/12/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SIngleDemo : NSObject<NSCopying>

- (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
