//
//  TrianglePoputView.m
//  ChatExtApp
//
//  Created by lixiaoming on 2021/5/26.
//

#import "TrianglePoputView.h"

@interface TrianglePoputView ()
@property (nonatomic, strong) UIView *bbView; /**< 真实的黑色部分 view */
@property (nonatomic, strong) UIColor *bgColor; /**< 背景颜色 */
@property (nonatomic, assign) CGPoint startPoint; /**< 三角形起始位置 */
@property (nonatomic, assign) CGPoint middlePoint; /**< 三角形中点位置 */
@property (nonatomic, assign) CGPoint endPoint; /**< 三角形结束位置 */
@end

@implementation TrianglePoputView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    self.startPoint = CGPointMake(self.bounds.size.width/2-2+45,5);
    self.middlePoint = CGPointMake(self.bounds.size.width/2+45,0);
    self.endPoint = CGPointMake(self.bounds.size.width/2+2+45,5);
    self.bgColor = [UIColor blackColor];
    self.bbView = [[UIView alloc] initWithFrame:CGRectMake(0, 5,self.bounds.size.width, self.bounds.size.height-10)];
    self.bbView.backgroundColor = [UIColor blackColor];
    self.bbView.alpha = 0.7;
    self.bbView.layer.cornerRadius = 8;
    [self addSubview:self.bbView];
    UILabel* lable1 = [[UILabel alloc] init];
    lable1.frame = CGRectMake(20, 20, self.bounds.size.width - 40, 20);
    lable1.font = [UIFont systemFontOfSize:14];
    lable1.text = @"获取学分的方式有:";
    lable1.textColor = [UIColor whiteColor];
    [self addSubview:lable1];
    UILabel* lable2 = [[UILabel alloc] init];
    lable2.frame = CGRectMake(20, 40, self.bounds.size.width - 40, 20);
    lable2.font = [UIFont systemFontOfSize:14];
    lable2.text = @"观看直播课 | 观看课程回放 | 完成在线测试";
    lable2.textColor = [UIColor whiteColor];
    [self addSubview:lable2];
    UILabel* lable3 = [[UILabel alloc] init];
    lable3.frame = CGRectMake(20, 80, self.bounds.size.width - 40, 20);
    lable3.font = [UIFont systemFontOfSize:11];
    lable3.text = @"具体细则请访问  “ 学习中心 > 个人中心 “ ";
    lable3.textColor = [UIColor whiteColor];
    lable3.alpha = 0.8;
    [self addSubview:lable3];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    // 获取当前上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 0.8);
    CGPoint sPoints[3]; //坐标点
    sPoints[0] = self.startPoint;
    sPoints[1] = self.middlePoint;
    sPoints[2] = self.endPoint;
    CGContextAddLines(context,sPoints, 3);//添加线
        CGContextClosePath(context);//封起来
        CGContextDrawPath(context, kCGPathFillStroke);
}


@end
