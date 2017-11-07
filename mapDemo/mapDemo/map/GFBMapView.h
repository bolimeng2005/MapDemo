//
//  GFBMapView.h
//  mapDemo
//
//  Created by Jekity on 3/11/17.
//  Copyright © 2017年 snow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "GFBMapModel.h"

typedef void(^MapViewResultBlock)(GFBMapModel *model);

@interface GFBMapView : UIView<MAMapViewDelegate,AMapLocationManagerDelegate,AMapSearchDelegate>

    @property (nonatomic, strong) MAMapView                  *mapView;
    @property (nonatomic, strong) AMapLocationManager *locationManager;
    @property (nonatomic, strong) AMapSearchAPI             *search;
    @property (nonatomic, strong) MAPointAnnotation       *pointAnnotation;
    @property (nonatomic,copy)     MapViewResultBlock       resultBlock;

- (void)setSearchKeywords:(NSString *)keywords city:(NSString *)city types:(NSString *)type;
    
    
@end
