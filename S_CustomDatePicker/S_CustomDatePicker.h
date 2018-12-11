//
//  S_CustomDatePicker.h
//  text
//
//  Created by apple on 2018/11/15.
//  Copyright © 2018年 dufei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomDatePickerDelegate <NSObject>

/**
 *  设置自定义展示view
 *  @param row 行
 *  @param component 列
 *  @param showView 默认view
 *  @param showData 展示内容
 *  @param isSelect 是否为被选中项
 */
- (UIView *)df_viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)showView withStr:(NSString *)showData isSelectRow:(BOOL)isSelect;

/**
 *  设置列宽
 *  @param component 列
 */
- (CGFloat)df_widthForComponent:(NSInteger)component;

/**
 *  设置每列行高  默认30
 *  @param component 列
 */
- (CGFloat)df_rowHeightForComponent:(NSInteger)component;


@end


@protocol CustomDatePickerDataSource <NSObject>

/**
 *  确认选择
 *  @param resultStr 返回已转换的时间字符串，时间格式为dateResultFormatterStr
 *  @param resultDate 返回未转换的时间date
 */
- (void)df_didSelectChoosePickerWithTime:(NSString *)resultStr withDate:(NSDate *)resultDate;

@optional
/**
 *  取消选择
 */
- (void)df_cancelSelectChoosePicker;

/**
 *  移除
 */
- (void)df_removePicker;

@end



@interface S_CustomDatePicker : UIViewController

/**
 *  协议
 *  df_didSelectChoosePickerWithTime:withDate 为必须实现的接口
 */
@property(nonatomic, weak) id<CustomDatePickerDelegate> delegate;
@property(nonatomic, weak) id<CustomDatePickerDataSource> dataSource;


/**
 *  设置时间格式（默认为"yyyy-MM-dd HH:mm:ss"）
 *  eg.dateResultFormatterStr 为 @"yyyy-MM-dd HH:mm:ss"，则选择器上显示为：2018 - 11 - 15 13 : 47 : 05
 */
@property (nonatomic, strong) NSString *dateResultFormatterStr;//24小时制  无法创建关于公元、星期、上下午类型

/**
 *  获取选中的date
 */
@property (nonatomic, strong, readonly) NSDate *currentDate;

/**
 *  获取选中的时间（时间格式为传入的dateResultFormatterStr，默认为"yyyy-MM-dd HH:mm:ss"）
 */
@property (nonatomic, strong, readonly) NSString *currentTime;

/**
 *  获取当前显示的选择器
 */
@property (nonatomic, strong, readonly) UIPickerView *currentPickerView;

/**
 *  maxDate 设置最大可选择时间
 *  如果年份格式为yy，则显示～99年；如果年份格式为yyyy，则显示+1000年
 *  默认为yyyy格式
 */
@property (nonatomic, strong) NSDate *maxDate;

/**
 *  minDate 设置最小可选择时间
 *  默认为当前时间
 */
@property (nonatomic, strong) NSDate *minDate;

/**
 *  selDate 设置当前选中时间
 *  默认当前时间为选中时间
 */
@property (nonatomic, strong) NSDate *selDate;

/**
 *  设置左右间距 默认20
 */
@property (nonatomic, assign) CGFloat spaceWidth;

/**
 *  设置选择器高度，未设置情况下默认200
 */
@property (nonatomic, assign) CGFloat pickerHeight;

/**
 *  自定义picker顶部操作view
 *
 *  @param customView 顶部操作view（默认尺寸左右贴边，高度40，底部贴picker顶部）
 *                    若设置frame，若按frame显示（底部位置不可改，底部贴picker顶部）
 *  @param cancelBtn  非必传，若传入则自动绑定协议事件（df_cancelSelectChoosePicker:）
 *                    若未传入，则需要自己进行管理
 *  @param sureBtn    非必传，若传入则自动绑定协议事件（df_didSelectChoosePickerWithTime:withDate:）
 *                    若未传入，则需要自己进行管理
 */
- (void)df_customSetTopActionView:(UIView *)customView withCancelBtn:(UIButton *)cancelBtn withSureBtn:(UIButton *)sureBtn;

/**
 *  展示
 */
- (void)show;
- (void)showFromController:(UIViewController *)fromController;

/**
 *  移除
 */
- (void)hide;


@end


@interface UIViewController (TopVC)

#pragma mark - ========= 获取当前的VC =================
- (UIViewController *)topViewController;

@end

