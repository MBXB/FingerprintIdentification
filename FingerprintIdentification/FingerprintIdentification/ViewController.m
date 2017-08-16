//
//  ViewController.m
//  FingerprintIdentification
//
//  Created by 毕向北 on 2017/8/16.
//  Copyright © 2017年 MBXB-bifujian. All rights reserved.
//

#import "ViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}
- (void)setUpUI{
    //添加一个按钮
    UIButton *buttonBtn = [[UIButton alloc]initWithFrame:CGRectMake(130, 200, 100, 100)];
    buttonBtn.backgroundColor = [UIColor orangeColor];
    [buttonBtn setTitle:@"指纹识别" forState:UIControlStateNormal];
    [self.view addSubview:buttonBtn];
    //添加点击方法
    [buttonBtn addTarget:self action:@selector(buttonBtnClick) forControlEvents:UIControlEventTouchUpInside];
}
- (void)buttonBtnClick{
    [self FingerprintIdentification];
}
//指纹识别代码
- (void)FingerprintIdentification{
    //1.判断iOS8及以后的版本
    if([UIDevice currentDevice].systemVersion.doubleValue >= 8.0){
        //从iPhone5S开始,出现指纹识别技术,所以说在此处可以进一步判断是否是5S以后机型
        //2.创建本地验证上下文对象-->这里导入框架LocalAuthentication
        LAContext *context = [LAContext new];
        // 3.判断能否使用指纹识别
        //Evaluate: 评估
        //Policy: 策略
        //LAPolicyDeviceOwnerAuthenticationWithBiometrics: 设备拥有者授权 用 生物识别技术
        if([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]){
            //4.在可以使用的前提下就会调用
            //localizedReason本地原因alert显示
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"请允许设备指纹识别" reply:^(BOOL success, NSError * _Nullable error) {
                if (success) {
                    //此处记得在主线程中更新UI
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"  提示  " message:@" 识别成功 " preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action){
                        }];
                        [ac addAction:confirm];
                        [self presentViewController:ac animated:true completion:^{
                        }];
                        ac = nil;
                    });
                }
                //不需要统计用户取消
                if(error.code != -2){
                    //  指纹识别Touch ID提供3+2 = 5次指纹识别机会----->3次识别失败后，指纹验证框消失(会报错code = -1)然后点击指纹会再次弹框可验证两次，如果五次指纹识别全部错误，就需要手动输入数字密码，数字密码可以输入6次，如果6次输入密码错误，系统停止验证，等待验证时间后会提供再次验证的机会,正确及验证成功(1次),错误则时间累加等待验证,以此类推. (iOS10不一样, 5次之后有问题: 需要进入设置中 -- TouchID与密码, 输入一次密码, 就可以解开)
                    //Code=-2 "Canceled by user
                    //Code=-1 "Application retry limit exceeded."
                    //Code=-8 "Biometry is locked out."
                    NSLog(@"error: %@", error);
                    //有的情况, 需要对错误的次数做累计, 此时就需要排除用户取消

                }
                
                
            }];
        }else{
            NSLog(@"请确保(5S以上机型),TouchID未打开");

        }

    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
