//
//  RecordingViewController.h
//  TLame
//
//  Created by YDJ on 14/12/19.
//  Copyright (c) 2014年 jingyoutimes. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecordingDelegate;

/**
 *	录制音频
 */

@interface RecordingViewController : UIViewController

@property (nonatomic,weak)id <RecordingDelegate>delegate;

@property (nonatomic,copy)NSString * mp3filePath;///xx/medias
@property (nonatomic,copy)NSString * globalIdentifier;///
@property (nonatomic,copy)NSString * mp3Path;
@property (nonatomic,copy)NSString * timeLength;///时:分:秒
@property (nonatomic) NSTimeInterval playLenth;///总长度，秒

@end


@protocol RecordingDelegate <NSObject>

@optional
- (void)recordingViewController:(RecordingViewController *)recording didFinished:(NSArray *)result info:(NSDictionary *)info;

@end

