//
//  ViewController.m
//  mapDemo
//
//  Created by Jekity on 3/11/17.
//  Copyright © 2017年 snow. All rights reserved.
//

#import "ViewController.h"
#import "GFBMapView.h"

@interface ViewController ()<UITextFieldDelegate>

    @property (nonatomic, strong) GFBMapView *mapView;
    @property (nonatomic, strong) UITextField *field;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView = [[GFBMapView alloc]initWithFrame:CGRectMake(10, 100, 320, 300)];
    [self.view addSubview:self.mapView];
    
    _field = [[UITextField alloc]initWithFrame:CGRectMake(20, 20, 200, 30)];
    _field.backgroundColor = [UIColor orangeColor];
    _field.delegate = self;
    [self.view addSubview:_field];
    
    __weak typeof(self) weakSelf = self;
    self.mapView.resultBlock   = ^(GFBMapModel *model) {
         weakSelf.field.text  = model.formattedAddress;
    } ;
}

    - (void)textFieldDidEndEditing:(UITextField *)textField{
        NSString *text = textField.text;
        if (text.length > 0) {
            [self.mapView setSearchKeywords:text city:@"南宁" types:nil];
        }
    }
    

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
