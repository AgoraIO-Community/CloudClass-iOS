//
//  ViewDebugVC.m
//  AgoraEducation
//
//  Created by ZYP on 2021/2/2.
//  Copyright © 2021 yangmoumou. All rights reserved.
//

#import "ViewDebugVC.h"
#import "AgoraEduSDK-swift.h"

@interface ViewDebugVC ()

@property (nonatomic, copy)NSArray<NSString *> *dataList;

@end

@implementation ViewDebugVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
    _dataList = @[@"教室：未到下课时间",
                  @"教室：已到下课时间",
                  @"教室：课程结束"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:false animated:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = _dataList[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    switch (indexPath.row) {
        case 0:
            [self showAlertType1];
            break;
        case 1:
            [self showAlertType2];
            break;
        default:
            [self showAlertType3];
            break;
    }
}

#pragma mark -- show

- (void)showAlertType1 {
//    AgoraCourseComfirAlertView *v = [AgoraCourseComfirAlertView new];
//    NSInteger type = AgoraCourseComfirAlertView.type1;
//    [v setTypeWithType:type];
//    v.didTapAction = ^(NSInteger actionValue) {
//        NSLog(@"%ld", actionValue);
//    };
//    [v showIn:UIApplication.sharedApplication.keyWindow];
}

- (void)showAlertType2 {
//    AgoraCourseComfirAlertView *v = [AgoraCourseComfirAlertView new];
//    NSInteger type = AgoraCourseComfirAlertView.type2;
//    [v setTypeWithType:type];
//    v.didTapAction = ^(NSInteger actionValue) {
//        NSLog(@"%ld", actionValue);
//    };
//    [v showIn:UIApplication.sharedApplication.keyWindow];
}

- (void)showAlertType3 {
//    AgoraCourseComfirAlertView *v = [AgoraCourseComfirAlertView new];
//    NSInteger type = AgoraCourseComfirAlertView.type3;
//    [v setTypeWithType:type];
//    v.didTapAction = ^(NSInteger actionValue) {
//        NSLog(@"%ld", actionValue);
//    };
//    [v showIn:UIApplication.sharedApplication.keyWindow];
}

@end
