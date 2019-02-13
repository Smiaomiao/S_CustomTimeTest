//
//  ViewController.m
//  S_CustomTimeTest
//
//  Created by apple on 2018/11/22.
//  Copyright © 2018年 dufei. All rights reserved.
//

#define kMainScreen_width [[UIScreen mainScreen] bounds].size.width
#define kMainScreen_height [[UIScreen mainScreen] bounds].size.height

#import "ViewController.h"
#import "S_CustomDatePicker.h"

@interface ViewController ()<CustomDatePickerDataSource,CustomDatePickerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *timeTableView;
@property (nonatomic, strong) NSMutableArray *timeTypeArr;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) S_CustomDatePicker *pickerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self timeTest];
    
}

#pragma mark - Init
- (void)timeTest {
    
    self.timeLabel.frame = CGRectMake(50, 50, 150, 30);
    [self.view addSubview:self.timeLabel];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"时间" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    btn.backgroundColor = [UIColor redColor];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(250, 50, 50, 40);
    [btn addTarget:self action:@selector(showDatePicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [self.view addSubview:self.timeTableView];
}

#pragma mark - Get
- (NSMutableArray *)timeTypeArr {
    if (!_timeTypeArr) {
        _timeTypeArr = [[NSMutableArray alloc]init];
        [_timeTypeArr addObject:@"yyyy-MM-dd HH:mm:ss"];
        [_timeTypeArr addObject:@"yy-MM-dd HH:mm:ss"];
        [_timeTypeArr addObject:@"yy-MMM-dd HH:mm:ss"];
        [_timeTypeArr addObject:@"yy-MMMM-dd HH:mm:ss"];
        [_timeTypeArr addObject:@"yy-MMMM-d HH:mm:ss"];
        [_timeTypeArr addObject:@"yy-MMMM-d H:mm:ss"];
        [_timeTypeArr addObject:@"yy-MMMM-d H:m:ss"];
        [_timeTypeArr addObject:@"yy-MMMM-d H:m:s"];
        
        
        [_timeTypeArr addObject:@"yyyy-MM-dd HH:mm"];
        [_timeTypeArr addObject:@"yyyy-MM-dd HH"];
        [_timeTypeArr addObject:@"yyyy-MM-dd"];
        [_timeTypeArr addObject:@"yyyy-MM"];
        [_timeTypeArr addObject:@"yyyy"];
        
        [_timeTypeArr addObject:@"yy-MM-dd HH:mm:ss"];
        [_timeTypeArr addObject:@"yyyy-MMM-dd HH:mm"];
        [_timeTypeArr addObject:@"yyyy-MM-dd HH"];
        [_timeTypeArr addObject:@"yyyy-MM-dd"];
        [_timeTypeArr addObject:@"yyyy-MM"];
        [_timeTypeArr addObject:@"yyyy"];
        
        [_timeTypeArr addObject:@"yyyy/MM/dd HH:mm:ss"];
        [_timeTypeArr addObject:@"yyyy/MM/dd HH:mm"];
        [_timeTypeArr addObject:@"yyyy/MM/dd HH"];
        [_timeTypeArr addObject:@"yyyy/MM/dd"];
        [_timeTypeArr addObject:@"yyyy/MM"];
        
        
        [_timeTypeArr addObject:@"MM-dd HH:mm:ss"];
        [_timeTypeArr addObject:@"dd HH:mm:ss"];
        [_timeTypeArr addObject:@"HH:mm:ss"];
        [_timeTypeArr addObject:@"mm:ss"];
        [_timeTypeArr addObject:@"ss"];
        
        [_timeTypeArr addObject:@"yyyy年MM月dd日HH:mm:ss"];
        [_timeTypeArr addObject:@"MM月dd日HH:mm:ss"];
        [_timeTypeArr addObject:@"dd日HH:mm:ss"];
        [_timeTypeArr addObject:@"HH时mm分ss秒"];
        [_timeTypeArr addObject:@"mm分ss秒"];
        
        [_timeTypeArr addObject:@"MM dd yyyy"];
        [_timeTypeArr addObject:@"dd yyyy"];
        [_timeTypeArr addObject:@"MM dd"];
        [_timeTypeArr addObject:@"MM"];
        
    }
    return _timeTypeArr;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:15];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.backgroundColor = [UIColor redColor];
    }
    return _timeLabel;
}

- (S_CustomDatePicker *)pickerView {
    if (!_pickerView) {
        _pickerView = [[S_CustomDatePicker alloc]init];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
    }
    return _pickerView;
}

- (UITableView *)timeTableView {
    if (!_timeTableView) {
        _timeTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 100, kMainScreen_width, kMainScreen_height - 100) style:UITableViewStyleGrouped];
        _timeTableView.delegate = self;
        _timeTableView.dataSource = self;
        _timeTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _timeTableView;
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timeTypeArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdenti"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdenti"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.text = self.timeTypeArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showPicker:self.timeTypeArr[indexPath.row]];
}

#pragma mark - PickerDelegate
- (void)showDatePicker {
    [self showPicker:nil];
}

- (void)showPicker:(NSString *)formatter {
    
    self.pickerView.maxDate = [NSDate date];
    
    NSDateFormatter* minformatter = [[NSDateFormatter alloc] init];
    [minformatter setDateFormat:@"yyyy/MM/dd"];
    
    NSDate *date = [minformatter dateFromString:@"1900/01/01"];
    
    self.pickerView.minDate = date;
    
    self.pickerView.dateResultFormatterStr = formatter;//设置时间显示格式及内容 nil则显示默认格式"yyyy-MM-dd HH:mm:ss"
    self.pickerView.selDate = self.currentDate;//设置选中时间，默认选中时间为当前时间
    
    [self.pickerView show];
}

- (void)df_didSelectChoosePickerWithTime:(NSString *)resultStr withDate:(NSDate *)resultDate {
    self.timeLabel.text = resultStr;
    self.currentDate = resultDate;
}

@end
