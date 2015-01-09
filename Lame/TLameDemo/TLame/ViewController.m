//
//  ViewController.m
//  TLame
//
//  Created by YDJ on 14/12/19.
//  Copyright (c) 2014年 jingyoutimes. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "RecordingViewController.h"

@interface ViewController ()<RecordingDelegate>

@end

@implementation ViewController


- (IBAction)DOWNACTION:(id)sender {
    
    RecordingViewController *record=[[RecordingViewController alloc] init];
    record.delegate=self;
    
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:record];
    
    [self presentViewController:nav animated:YES completion:nil];
    
    
    
}

- (void)recordingViewController:(RecordingViewController *)recording didFinished:(NSArray *)result info:(NSDictionary *)info{
    
    [recording dismissViewControllerAnimated:YES completion:nil];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
