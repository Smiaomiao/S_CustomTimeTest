//
//  S_CustomDatePicker.m
//  text
//
//  Created by apple on 2018/11/15.
//  Copyright © 2018年 dufei. All rights reserved.
//

#define kMainScreen_width [[UIScreen mainScreen] bounds].size.width
#define kMainScreen_height [[UIScreen mainScreen] bounds].size.height

#import "S_CustomDatePicker.h"
#import <objc/runtime.h>
#import <Masonry/Masonry.h>

@interface S_CustomDatePicker()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *customPicker;
@property (nonatomic, strong) NSMutableArray *sumDataArr;
@property (nonatomic, strong) UIView *actionView;

@property (nonatomic, strong) NSDateComponents *minComp;
@property (nonatomic, strong) NSDateComponents *maxComp;
@property (nonatomic, strong) NSDateComponents *selComp;

@property (nonatomic, assign) NSInteger dayLength;

@end

@implementation S_CustomDatePicker

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.spaceWidth = 20;
    [self setPicker];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadDataArr];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.minDate = nil;
    self.maxDate = nil;
    self.selDate = nil;
    self.minComp = nil;
    self.maxComp = nil;
    self.selComp = nil;
}

- (void)show {
    [self showFromController:[self topViewController]];
}

- (void)showFromController:(UIViewController *)fromController {
    if ([[self topViewController].class isKindOfClass:[self class]]) {
        return;
    }
    if (self.dateResultFormatterStr.length == 0) {
        self.dateResultFormatterStr = @"yyyy-MM-dd HH:mm:ss";
    }
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f];
    [fromController presentViewController:self animated:YES completion:nil];
}

- (void)hide {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self.view];
    if (!CGRectContainsPoint(self.customPicker.frame,point)) {
        [self df_removePicker];
    }
}

#pragma mark - InitView
- (void)setPicker {
    CALayer *pickerLayer = self.customPicker.layer;
    pickerLayer.frame = CGRectMake(0, kMainScreen_height - 200, kMainScreen_width, 200);
    [self.view addSubview:self.customPicker];
    [self.view addSubview:self.actionView];
    
    [self.actionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.bottom.equalTo(self.customPicker.mas_top);
        make.height.equalTo(@40);
    }];
}


#pragma mark - SetDate

/*
 G: 公元时代，例如AD公元
 yy: 年的后2位
 yyyy: 完整年
 MM: 月，显示为1-12
 MMM: 月，显示为英文月份简写,如 Jan
 MMMM: 月，显示为英文月份全称，如 Janualy
 dd: 日，2位数表示，如02
 d: 日，1-2位显示，如 2
 EEE: 简写星期几，如Sun
 EEEE: 全写星期几，如Sunday
 aa: 上下午，AM/PM
 H: 时，24小时制，0-23
 K：时，12小时制，0-11
 m: 分，1-2位
 mm: 分，2位
 s: 秒，1-2位
 ss: 秒，2位
 S: 毫秒
 */
- (void)setDateResultFormatterStr:(NSString *)dateResultFormatterStr {
    NSLog(@"24小时制  无法创建关于公元、星期、上下午以及毫秒类型");
    
    if (([dateResultFormatterStr rangeOfString:@"G"].location != NSNotFound) || ([dateResultFormatterStr rangeOfString:@"EEE"].location != NSNotFound) || ([dateResultFormatterStr rangeOfString:@"aa"].location != NSNotFound)) {
        [self df_removePicker];
        return;
    }
    
    if ([dateResultFormatterStr rangeOfString:@"K"].location != NSNotFound) {
        dateResultFormatterStr = [dateResultFormatterStr stringByReplacingOccurrencesOfString:@"K" withString:@"H"];
    }
    
    _dateResultFormatterStr = dateResultFormatterStr;
    
    [self.sumDataArr removeAllObjects];
    
    [self.sumDataArr addObjectsFromArray:[self checkResultType:dateResultFormatterStr]];
    
    if (self.customPicker) {
        [self.customPicker reloadAllComponents];
    }
}

- (NSArray *)checkResultType:(NSString *)dateType {
    NSString *temp = nil;
    NSMutableArray *typeArr = [[NSMutableArray alloc]init];
    for(int i =0; i < [dateType length]; i++)
    {
        NSString *resultStr = [dateType substringWithRange:NSMakeRange(i, 1)];
        if (!temp) {
            temp = resultStr;
        } else {
            if ([temp rangeOfString:resultStr].location != NSNotFound) {
                temp = [temp stringByAppendingString:resultStr];
            } else {
                [typeArr addObject:temp];
                temp = resultStr;
            }
        }
        NSLog(@"第%d个字是:%@",i,resultStr);
    }
    [typeArr addObject:temp];
    NSLog(@"%@",typeArr);
    
    return typeArr;
}

- (void)setPickerHeight:(CGFloat)pickerHeight {
    CALayer *pickerLayer = self.customPicker.layer;
    pickerLayer.frame = CGRectMake(0, kMainScreen_height - pickerHeight, kMainScreen_width, pickerHeight);
    if (self.customPicker.superview == self.view) {
        [self.customPicker removeFromSuperview];
    }
    [self.view addSubview:self.customPicker];
}

- (void)df_customSetTopActionView:(UIView *)customView withCancelBtn:(UIButton *)cancelBtn withSureBtn:(UIButton *)sureBtn {
    [self.actionView removeFromSuperview];
    [self.view addSubview:customView];
    if (cancelBtn) {
        [cancelBtn addTarget:self action:@selector(df_cancelSelectChoosePicker) forControlEvents:UIControlEventTouchUpInside];
    }
    if (sureBtn) {
        [sureBtn addTarget:self action:@selector(chooseSelectChoosePicker) forControlEvents:UIControlEventTouchUpInside];
    }
    
    CGFloat x = customView.frame.origin.x;
    CGFloat width = customView.frame.size.width;
    CGFloat height = customView.frame.size.height;
    
    if (x <= 0) {
        x = 0;
    }
    if (width <= 0) {
        width = kMainScreen_width;
    }
    if (height <= 0) {
        height = 40;
    }
    
    [customView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(x));
        make.width.equalTo(@(width));
        make.bottom.equalTo(self.customPicker.mas_top);
        make.height.equalTo(@(height));
    }];
}

- (void)reloadDataArr {
    
    if (!self.minDate) {
        self.minDate = [NSDate date];
    }
    
    if (!self.maxDate) {
        NSDateComponents *temp = [self returnComponentWithDate:self.minDate];
        if ([self.sumDataArr indexOfObject:@"yy"] != NSNotFound) {
            NSInteger year = temp.year%100;
            year = 100 - year;
            temp.year = temp.year/100 * 100 + year;
        } else {
            temp.year += 1000;
        }
        self.maxDate = [self returnCompnentDate:temp];
    }
    
    if (!self.selDate) {
        self.selDate = self.minDate;
    }
    
    
    NSComparisonResult result =[self.minDate compare:self.maxDate];
    if (result == NSOrderedDescending) {
        NSDate *temp = self.maxDate;
        self.minDate = temp;
        self.maxDate = self.minDate;
    }
    
    self.minComp = [self returnComponentWithDate:self.minDate];
    self.maxComp = [self returnComponentWithDate:self.maxDate];
    self.selComp = [self returnComponentWithDate:self.selDate];
    
    [self reloadDay];
    
    
    
    [self equalDate];
}

- (UIPickerView *)currentPickerView {
    return self.customPicker;
}

#pragma mark- Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView//列
{
    return self.sumDataArr.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component //行数
{
    NSString *str = self.sumDataArr[component];
    if ([str rangeOfString:@"y"].location != NSNotFound) {
        if (str.length == 2) {
            NSInteger num = self.minComp.year%100;
            return 100 - num;
        } else {
            return self.maxComp.year - self.minComp.year;
        }
    } else if ([str rangeOfString:@"M"].location != NSNotFound) {
        return 12;
    } else if ([str rangeOfString:@"d"].location != NSNotFound) {
        return self.dayLength;
    } else if ([str rangeOfString:@"H"].location != NSNotFound) {
        return 24;
    } else if ([str rangeOfString:@"m"].location != NSNotFound) {
        return 60;
    } else if ([str rangeOfString:@"s"].location != NSNotFound) {
        return 60;
    } else {
        return 1;
    }
}


#pragma mark- Picker Delegate Methods
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    
    BOOL isSel = NO;
    if (row == [self.customPicker selectedRowInComponent:component]) {
        isSel = YES;
    }
    
    UIView *labelView = [self df_viewForRow:row forComponent:component reusingView:view withStr:@"" isSelectRow:isSel];
    return labelView;
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return [self df_widthForComponent:component];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return [self df_rowHeightForComponent:component];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *str = self.sumDataArr[component];
    if ([str rangeOfString:@"y"].location != NSNotFound) {
        self.selComp.year = self.minComp.year + row;
    } else if ([str rangeOfString:@"M"].location != NSNotFound) {
        self.selComp.month = row + 1;
    } else if ([str rangeOfString:@"d"].location != NSNotFound) {
        self.selComp.day = row + 1;
        [self reloadDay];
    } else if ([str rangeOfString:@"H"].location != NSNotFound) {
        self.selComp.hour = row;
    } else if ([str rangeOfString:@"m"].location != NSNotFound) {
        self.selComp.minute = row;
    } else if ([str rangeOfString:@"s"].location != NSNotFound) {
        self.selComp.second = row;
    } else {
        return;
    }
    
    [self equalDate];
}


#pragma mark - Reload
- (void)reloadDay {
    
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM"];//根据自己的需求定义格式
#if __LP64__ || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
    NSDate* startDate = [formater dateFromString:[NSString stringWithFormat:@"%ld-%ld",self.selComp.year,self.selComp.month]];
#else
    NSDate* startDate = [formater dateFromString:[NSString stringWithFormat:@"%d-%d",self.selComp.year,self.selComp.month]];
#endif

    [self reloadDayLenght:startDate];
    
    if (self.selComp.day > self.dayLength) {
        self.selComp.day = self.dayLength;
        self.selDate = [self returnCompnentDate:self.selComp];
    }
}

- (void)equalDate {
    
    if (self.selComp.year <= self.minComp.year) {
        self.selComp.year = self.minComp.year;
        if (self.selComp.month <= self.minComp.month) {
            self.selComp.month = self.minComp.month;
            if (self.selComp.day <= self.minComp.day) {
                self.selComp.day = self.minComp.day;
                if (self.selComp.hour <= self.minComp.hour) {
                    self.selComp.hour = self.minComp.hour;
                    if (self.selComp.minute <= self.minComp.minute) {
                        self.selComp.minute = self.minComp.minute;
                        if (self.selComp.second <= self.minComp.second) {
                            self.selComp.second = self.minComp.second;
                        }
                    }
                }
            }
        }
    } else if (self.selComp.year >= self.maxComp.year) {
        self.selComp.year = self.maxComp.year;
        if (self.selComp.month >= self.maxComp.month) {
            self.selComp.month = self.maxComp.month;
            if (self.selComp.day >= self.maxComp.day) {
                self.selComp.day = self.maxComp.day;
                if (self.selComp.hour >= self.maxComp.hour) {
                    self.selComp.hour = self.maxComp.hour;
                    if (self.selComp.minute >= self.maxComp.minute) {
                        self.selComp.minute = self.maxComp.minute;
                        if (self.selComp.second >= self.maxComp.second) {
                            self.selComp.second = self.maxComp.second;
                        }
                    }
                }
            }
        }
    }
    
    for (int i = 0; i < self.sumDataArr.count; i++) {
        NSString *str = self.sumDataArr[i];
        if ([str rangeOfString:@"y"].location != NSNotFound) {
            [self.customPicker selectRow:self.selComp.year - self.minComp.year inComponent:i animated:YES];
        } else if ([str rangeOfString:@"M"].location != NSNotFound) {
            [self.customPicker selectRow:self.selComp.month - 1 inComponent:i animated:YES];
        } else if ([str rangeOfString:@"d"].location != NSNotFound) {
            [self.customPicker selectRow:self.selComp.day - 1 inComponent:i animated:YES];
        } else if ([str rangeOfString:@"H"].location != NSNotFound) {
            [self.customPicker selectRow:self.selComp.hour inComponent:i animated:YES];
        } else if ([str rangeOfString:@"m"].location != NSNotFound) {
            [self.customPicker selectRow:self.selComp.minute inComponent:i animated:YES];
        } else if ([str rangeOfString:@"s"].location != NSNotFound) {
            [self.customPicker selectRow:self.selComp.second inComponent:i animated:YES];
        }
    }
    
    self.selDate = [self returnCompnentDate:self.selComp];
    
    [self.customPicker reloadAllComponents];
}

#pragma mark - Delegate
- (void)chooseSelectChoosePicker {
    if ([self.dataSource respondsToSelector:@selector(df_didSelectChoosePickerWithTime:withDate:)]) {
        
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        
        [formatter setDateFormat:self.dateResultFormatterStr];
        
        NSString *dateTime=[formatter stringFromDate:[self returnCompnentDate:self.selComp]];
        
        NSDate *date = [formatter dateFromString:dateTime];
        
        [self.dataSource df_didSelectChoosePickerWithTime:dateTime withDate:date];
        
    }
    
    [self df_removePicker];
}

- (NSString *)currentTime {
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:self.dateResultFormatterStr];
    
    NSString *dateTime=[formatter stringFromDate:[self returnCompnentDate:self.selComp]];
    
    return dateTime;
}

- (NSDate *)currentDate {
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:self.dateResultFormatterStr];
    
    NSString *dateTime=[formatter stringFromDate:[self returnCompnentDate:self.selComp]];
    
    NSDate *date = [formatter dateFromString:dateTime];
    
    return date;
}

#pragma mark - DataSource

- (void)df_cancelSelectChoosePicker {
    if ([self.dataSource respondsToSelector:@selector(df_cancelSelectChoosePicker)]) {
        [self.dataSource df_cancelSelectChoosePicker];
    }
    [self df_removePicker];
}

- (void)df_didSelectChoosePickerWithTime:(NSString *)resultStr withDate:(NSDate *)resultDate {
    
}

- (void)df_removePicker {
    if ([self.dataSource respondsToSelector:@selector(df_removePicker)]) {
        [self.dataSource df_removePicker];
    }
    [self hide];
}

#pragma mark - Delegate

- (UIView *)df_viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)showView withStr:(NSString *)showData isSelectRow:(BOOL)isSelect{
    
    NSString *str = self.sumDataArr[component];
    NSString *currentTitle = str;
    
#if __LP64__ || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
    if ([str rangeOfString:@"y"].location != NSNotFound) {
        currentTitle = [NSString stringWithFormat:@"%ld",self.minComp.year + row];
        if (str.length == 2) {
            if (currentTitle.length >= 4) {
                currentTitle = [currentTitle substringFromIndex:2];
            }
        }
    } else if ([str rangeOfString:@"M"].location != NSNotFound) {
        NSCalendar *caldendar = [NSCalendar currentCalendar];// 获取日历
        
        if (str.length == 3) {
            NSArray *monthArr = [NSArray arrayWithArray:caldendar.shortMonthSymbols];  // 获取日历月数组
            currentTitle = monthArr[row];  // 获得数字月份下的对应英文月缩写
        } else if (str.length == 4) {
            NSArray *monthArr = [NSArray arrayWithArray:caldendar.standaloneMonthSymbols];  // 获取日历月数组
            currentTitle = monthArr[row];  // 获得数字月份下的对应英文月缩写
        } else {
            currentTitle = [NSString stringWithFormat:@"%ld",row + 1];
        }
        
    } else if ([str rangeOfString:@"d"].location != NSNotFound) {
        currentTitle = [NSString stringWithFormat:@"%ld",row + 1];
        if (str.length == 2 && currentTitle.length == 1) {
            currentTitle = [NSString stringWithFormat:@"0%@",currentTitle];
        }
    } else if ([str rangeOfString:@"H"].location != NSNotFound) {
        currentTitle = [NSString stringWithFormat:@"%ld",row];
        if (str.length == 2 && currentTitle.length == 1) {
            currentTitle = [NSString stringWithFormat:@"0%@",currentTitle];
        }
    } else if ([str rangeOfString:@"m"].location != NSNotFound) {
        currentTitle = [NSString stringWithFormat:@"%ld",row];
        if (str.length == 2 && currentTitle.length == 1) {
            currentTitle = [NSString stringWithFormat:@"0%@",currentTitle];
        }
    } else if ([str rangeOfString:@"s"].location != NSNotFound) {
        currentTitle = [NSString stringWithFormat:@"%ld",row];
        if (str.length == 2 && currentTitle.length == 1) {
            currentTitle = [NSString stringWithFormat:@"0%@",currentTitle];
        }
    }
#else
    if ([str rangeOfString:@"y"].location != NSNotFound) {
        currentTitle = [NSString stringWithFormat:@"%d",self.minComp.year + row];
        if (str.length == 2) {
            if (currentTitle.length >= 4) {
                currentTitle = [currentTitle substringFromIndex:2];
            }
        }
    } else if ([str rangeOfString:@"M"].location != NSNotFound) {
        NSCalendar *caldendar = [NSCalendar currentCalendar];// 获取日历
        
        if (str.length == 3) {
            NSArray *monthArr = [NSArray arrayWithArray:caldendar.shortMonthSymbols];  // 获取日历月数组
            currentTitle = monthArr[row];  // 获得数字月份下的对应英文月缩写
        } else if (str.length == 4) {
            NSArray *monthArr = [NSArray arrayWithArray:caldendar.standaloneMonthSymbols];  // 获取日历月数组
            currentTitle = monthArr[row];  // 获得数字月份下的对应英文月缩写
        } else {
            currentTitle = [NSString stringWithFormat:@"%d",row + 1];
        }
        
    } else if ([str rangeOfString:@"d"].location != NSNotFound) {
        currentTitle = [NSString stringWithFormat:@"%d",row + 1];
        if (str.length == 2 && currentTitle.length == 1) {
            currentTitle = [NSString stringWithFormat:@"0%@",currentTitle];
        }
    } else if ([str rangeOfString:@"H"].location != NSNotFound) {
        currentTitle = [NSString stringWithFormat:@"%d",row];
        if (str.length == 2 && currentTitle.length == 1) {
            currentTitle = [NSString stringWithFormat:@"0%@",currentTitle];
        }
    } else if ([str rangeOfString:@"m"].location != NSNotFound) {
        currentTitle = [NSString stringWithFormat:@"%d",row];
        if (str.length == 2 && currentTitle.length == 1) {
            currentTitle = [NSString stringWithFormat:@"0%@",currentTitle];
        }
    } else if ([str rangeOfString:@"s"].location != NSNotFound) {
        currentTitle = [NSString stringWithFormat:@"%d",row];
        if (str.length == 2 && currentTitle.length == 1) {
            currentTitle = [NSString stringWithFormat:@"0%@",currentTitle];
        }
    }
#endif
    
    UIView *view = nil;
    
    
    if ([self.delegate respondsToSelector:@selector(df_viewForRow:forComponent:reusingView:withStr:isSelectRow:)]) {
        view = [self.delegate df_viewForRow:row forComponent:component reusingView:showView withStr:currentTitle isSelectRow:isSelect];
    }
    
    if (!view) {
        UILabel *myView = (UILabel*)showView;
        myView = [[UILabel alloc] init];
        myView.text = currentTitle;
        myView.backgroundColor = [UIColor clearColor];
        myView.textAlignment = NSTextAlignmentCenter;
        
        if (isSelect) {
            myView.font = [UIFont systemFontOfSize:16];
        } else {
            myView.font = [UIFont systemFontOfSize:14];
        }
        [myView adjustsFontSizeToFitWidth];
        [myView sizeToFit];
        return myView;
    } else {
        return view;
    }
}

- (CGFloat)df_widthForComponent:(NSInteger)component {
    NSString *str = self.sumDataArr[component];
    
    if (!str) {
        return 0.01;
    }
    CGFloat width = 0;
    
    if ([self.delegate respondsToSelector:@selector(df_widthForComponent:)]) {
        width = [self.delegate df_widthForComponent:component];
        width += self.spaceWidth;
    }
    
    if (width == 0) {
        width = (kMainScreen_width - self.spaceWidth*4)/self.sumDataArr.count;
        
        if (component == 0 || component == self.sumDataArr.count) {
            width += self.spaceWidth;
        }
    }
    
    return width;
}

- (CGFloat)df_rowHeightForComponent:(NSInteger)component {
    CGFloat height = 0;
    
    if ([self.delegate respondsToSelector:@selector(df_rowHeightForComponent:)]) {
        height = [self.delegate df_rowHeightForComponent:component];
    }
    
    if (height == 0) {
        height = 30;
    }
    
    return height;
}

#pragma mark - Action
- (NSDateComponents *)returnComponentWithDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit type = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *cmps = [calendar components:type fromDate:date];
    return cmps;
}

- (NSDate *)returnCompnentDate:(NSDateComponents *)comp {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateFromComponents:comp];
    return date;
}

- (void)reloadDayLenght:(NSDate *)currentDate{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange timeRange = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:currentDate];
    self.dayLength = timeRange.length;
}

#pragma mark - Get
- (UIPickerView *)customPicker {
    if (!_customPicker) {
        _customPicker = [[UIPickerView alloc]init];
        _customPicker.backgroundColor = [UIColor whiteColor];
        _customPicker.delegate = self;
        _customPicker.dataSource = self;
        _customPicker.showsSelectionIndicator = YES;
    }
    return _customPicker;
}

- (NSMutableArray *)sumDataArr {
    if (!_sumDataArr) {
        _sumDataArr = [[NSMutableArray alloc]init];
    }
    return _sumDataArr;
}

- (UIView *)actionView {
    if (!_actionView) {
        _actionView = [[UIView alloc]init];
        _actionView.backgroundColor = [UIColor whiteColor];
        
        UIButton *cancelBtn = [self createActionBtn];
        cancelBtn.frame = CGRectMake(0, 0, 50, 40);
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(df_cancelSelectChoosePicker) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *sureBtn = [self createActionBtn];
        sureBtn.frame = CGRectMake(kMainScreen_width - 50, 0, 50, 40);
        [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [sureBtn addTarget:self action:@selector(chooseSelectChoosePicker) forControlEvents:UIControlEventTouchUpInside];

        [_actionView addSubview:cancelBtn];
        [_actionView addSubview:sureBtn];
    }
    return _actionView;
}

- (UIButton *)createActionBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor whiteColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    return btn;
}

@end



@implementation UIViewController (TopVC)

#pragma mark - ========= 获取当前的VC =================
- (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

@end
