//
//  GFBMapView.m
//  mapDemo
//
//  Created by Jekity on 3/11/17.
//  Copyright © 2017年 snow. All rights reserved.
//

#import "GFBMapView.h"

@implementation GFBMapView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"GFBMapView" owner:self options:nil] objectAtIndex:0];
    self.frame = frame;
    if (self) {
        [self initMapView];
        [self setLocation];
        [self initSearch];
    }
    return self;
}

    - (void)initSearch{
        self.search = [[AMapSearchAPI alloc] init];
        self.search.delegate = self;
    }
    - (void)initMapView{
        _mapView = [[MAMapView alloc] initWithFrame:self.bounds];
        _mapView.delegate       = self;
        _mapView.zoomLevel    = 16.1;
        [self addSubview:_mapView];
        _pointAnnotation = [[MAPointAnnotation alloc] init];
    }

    - (void)setLocation{
        self.locationManager = [[AMapLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        // 带逆地理信息的一次定位（返回坐标和地址信息）
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        //   定位超时时间，最低2s，此处设置为10s
        self.locationManager.locationTimeout =10;
        //   逆地理请求超时时间，最低2s，此处设置为10s
        self.locationManager.reGeocodeTimeout = 10;
        
        [self.locationManager setLocatingWithReGeocode:YES];
        [self.locationManager startUpdatingLocation];
        
    }
//mapView:viewForAnnotation:中修改 MAAnnotationView 对应的标注图片
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        
//        annotationView.pinColor = MAPinAnnotationColorPurple;
        
//        annotationView.image = [UIImage imageNamed:@"restaurant"];
//        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
//        annotationView.centerOffset = CGPointMake(0, -18);
        
        return annotationView;
    }
    return nil;
}
// 拖拽大头针触发方法
- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view didChangeDragState:(MAAnnotationViewDragState)newState fromOldState:(MAAnnotationViewDragState)oldState
{
    if (newState == MAAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D coordinate = view.annotation.coordinate;
        self.pointAnnotation = view.annotation;
        
        [self searchReGeocodeWithCoordinate:coordinate];
    }
}
//长按添加大头针
- (void)mapView:(MAMapView *)mapView didLongPressedAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self searchReGeocodeWithCoordinate:coordinate];
}

    - (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
    {
        NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
        
        if (reGeocode)
        {
//            NSLog(@"reGeocode:%@", reGeocode);
//            NSLog(@"formattedAddress = %@",reGeocode.formattedAddress);

            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            
              NSString *text = [NSString stringWithFormat:@"%@%@%@", reGeocode.district?: @"",  reGeocode.street?: @"", reGeocode.number?: @""];
            
            [self addPointAnnotationToMapView:coordinate title:reGeocode.POIName subtitle:text];
             [self.locationManager stopUpdatingLocation];
            
            GFBMapModel *model     = [[GFBMapModel alloc]init];
            model.coordinate              = coordinate;
            model.formattedAddress  = reGeocode.formattedAddress;
            model.province                 = reGeocode.province;
            model.city                          = reGeocode.city;
            model.citycode                  = reGeocode.citycode;
            model.district                    = reGeocode.district;
            model.adcode                   = reGeocode.adcode;
            model.street                      = reGeocode.street;
            model.detailAdress            = [NSString stringWithFormat:@"%@%@",  reGeocode.street?: @"", reGeocode.number?: @""];
            model.isSearchKeyWords  = NO;
            if (self.resultBlock) {
                self.resultBlock(model);
            }
        }
    }

    - (void)setSearchKeywords:(NSString *)keywords city:(NSString *)city types:(NSString *)type{
        AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
        request.keywords               = keywords;
        if (city) {
            request.city                    = city;
        }
        
//        request.types                      = type;
        
        request.requireExtension    = YES;
        /*  搜索SDK 3.2.0 中新增加的功能，只搜索本城市的POI。*/
        request.cityLimit                  = YES;
        request.requireSubPOIs       = YES;
        //调用 AMapSearchAPI 的 AMapPOIKeywordsSearch 并发起关键字检索。
        [self.search AMapPOIKeywordsSearch:request];
        
    }
- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate//经纬度转地理地址
{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location                                          = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension                            = YES;
    [self.search AMapReGoecodeSearch:regeo];
}
#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@ - %@", error, AMapSearchErrorDomain);
}
    /* POI 搜索回调. */
/**
 * @brief POI查询回调函数
 * @param request  发起的请求，具体字段参考 AMapPOISearchBaseRequest 及其子类。
 * @param response 响应结果，具体字段参考 AMapPOISearchResponse 。
 */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
    {
        if (response.pois.count == 0)
        {
            return;
        }
        NSMutableArray *poiAnnotations = [NSMutableArray arrayWithCapacity:response.pois.count];
        [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
            [poiAnnotations addObject:obj];
        }];
        AMapPOI *tempAnnotation = [poiAnnotations lastObject];
         NSLog(@"tempAnnotation.name= %@ tempAnnotation.address=%@ district= %@ ",tempAnnotation.name,tempAnnotation.address,tempAnnotation.district);
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(tempAnnotation.location.latitude, tempAnnotation.location.longitude);
    
        NSString *subtitle = [NSString stringWithFormat:@"%@%@",tempAnnotation.district,tempAnnotation.address];
        [self addPointAnnotationToMapView:coordinate title:tempAnnotation.name subtitle:subtitle];
        
        GFBMapModel *model    = [[GFBMapModel alloc]init];
        model.coordinate             = coordinate;
        model.formattedAddress = tempAnnotation.address;
        model.province                = tempAnnotation.province;
        model.pcode                    = tempAnnotation.pcode;
        model.city                        = tempAnnotation.city;
        model.citycode                = tempAnnotation.citycode;
        model.district                   = tempAnnotation.district;
        model.adcode                  = tempAnnotation.adcode;
        model.detailAdress          = tempAnnotation.address;
        model.isSearchKeyWords = YES;
        if (self.resultBlock) {
            self.resultBlock(model);
        }
    }
/**
 * @brief 逆地理编码查询回调函数
 * @param request  发起的请求，具体字段参考 AMapReGeocodeSearchRequest 。
 * @param response 响应结果，具体字段参考 AMapReGeocodeSearchResponse 。
 */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    if (response.regeocode.pois.count == 0)
    {
        return;
    }
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
    
    NSString *text = [NSString stringWithFormat:@"%@%@%@%@", response.regeocode.addressComponent.district?: @"", response.regeocode.addressComponent.building ?: @"", response.regeocode.addressComponent.streetNumber.street?: @"", response.regeocode.addressComponent.streetNumber.number?: @""];
//    NSLog(@" text %@",text);
    [self addPointAnnotationToMapView:coordinate title:response.regeocode.addressComponent.building subtitle:text];
    
    GFBMapModel *model    = [[GFBMapModel alloc]init];
    model.coordinate             = coordinate;
    model.formattedAddress = text;
    model.province                = response.regeocode.addressComponent.province;
    model.city                        = response.regeocode.addressComponent.city;
    model.citycode                = response.regeocode.addressComponent.citycode;
    model.district                   = response.regeocode.addressComponent.district;
    model.adcode                  = response.regeocode.addressComponent.adcode;
    model.street                     = response.regeocode.addressComponent.streetNumber.street;
    model.detailAdress          = [NSString stringWithFormat:@"%@%@%@",  response.regeocode.addressComponent.building ?: @"", response.regeocode.addressComponent.streetNumber.street?: @"", response.regeocode.addressComponent.streetNumber.number?: @""];
    model.isSearchKeyWords  = NO;
    if (self.resultBlock) {
        self.resultBlock(model);
    }
}
- (void)addPointAnnotationToMapView:(CLLocationCoordinate2D)coordinate title:(NSString *)title subtitle:(NSString *)subtitle{
     [self.mapView removeAnnotations:self.mapView.annotations];
    _pointAnnotation.coordinate = coordinate;
    _pointAnnotation.title            = title;
    _pointAnnotation.subtitle      = subtitle;
    /* 将结果以annotation的形式加载到地图上. */
    [_mapView addAnnotation:_pointAnnotation];
    [_mapView setCenterCoordinate:_pointAnnotation.coordinate animated:YES];
}


@end
