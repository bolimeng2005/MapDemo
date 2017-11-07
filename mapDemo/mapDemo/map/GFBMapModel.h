//
//  GFBMapModel.h
//  seller_Elms_ios
//
//  Created by Jekity on 6/11/17.
//  Copyright © 2017年 snow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GFBMapModel : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
///格式化地址
@property (nonatomic, copy) NSString     *formattedAddress;
///所在省/直辖市
@property (nonatomic, copy) NSString     *province;
///省编码
@property (nonatomic, copy)   NSString    *pcode;
///城市名
@property (nonatomic, copy) NSString     *city;
///城市编码
@property (nonatomic, copy) NSString     *citycode;
///区域名称
@property (nonatomic, copy) NSString     *district;
///区域编码
@property (nonatomic, copy) NSString     *adcode;

///街道名称
@property (nonatomic, copy) NSString     *street;
@property (nonatomic, copy) NSString     *streeId;//街

@property (nonatomic, copy) NSString     *detailAdress;
@property (nonatomic, assign) BOOL        isSearchKeyWords;

@end
