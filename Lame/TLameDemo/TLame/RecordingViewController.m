//
//  RecordingViewController.m
//  TLame
//
//  Created by YDJ on 14/12/19.
//  Copyright (c) 2014年 jingyoutimes. All rights reserved.
//

#import "RecordingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "lame.h"

@interface RecordingViewController ()<AVAudioRecorderDelegate>

///录音文件的路径
@property (nonatomic,copy)NSString * soundPath;
@property (nonatomic,strong)AVAudioRecorder *recorder;
@property (nonatomic)NSTimer * timer;

@property (nonatomic,strong)UILabel * timeLabel;

@end

@implementation RecordingViewController


- (void)detectionVoice
{
    [self.recorder updateMeters];
    
    
    //double lowPassResults = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));

   // NSLog(@"%f==%f===%f",[self.recorder peakPowerForChannel:0],[self.recorder averagePowerForChannel:0],lowPassResults);
   // NSLog(@"%f",self.recorder.currentTime);
    
    NSTimeInterval totalLength = self.recorder.currentTime;
    self.playLenth=totalLength;
    
    int hour=0, minute = 0, second = 0;
    
    second = (int)(totalLength);
    if (second >= 60) {
        int hIndex=second/(60*60);
        hour=hIndex;
        int index = (second-hIndex*60) / 60;
        minute = index;
        second = second - index*60-hIndex*60*60;
    }
    NSString * playLenth=[NSString stringWithFormat:@"%02d:%02d:%02d",hour,minute,second];
    
    self.timeLength=playLenth;
    
    self.timeLabel.text=self.timeLength;
    
}


- (void)pcmToMP3
{
    
  
    
    if (self.mp3Path.length==0)
    {
        NSString *mp3FilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/downloadFile.mp3"];
        self.mp3Path=mp3FilePath;
    }
    NSLog(@"%@",self.mp3Path);
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:self.mp3Path])
    {
        [fileManager removeItemAtPath:self.mp3Path error:nil];
    }
    
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([self.soundPath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([self.mp3Path cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer,(size_t)(2*sizeof(short int)),(size_t)PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);

        
        self.navigationItem.rightBarButtonItem.enabled=YES;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.soundPath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:self.soundPath error:nil];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
        
        UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:nil message:@"录制失败,请重新录制" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    @finally {
    
      //  NSLog(@"mp3转换完成");
    }

    
    
    
}

- (void)startRecording:(UIButton *)sender
{
    if (self.recorder.isRecording)
    {
        [sender setTitle:@"开始录音" forState:UIControlStateNormal];
        [self.recorder stop];
        
    }
    else{
        
        
        if (self.recorder==nil)
        {
            [self initRecord];
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.soundPath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:self.soundPath error:nil];
        }
        
        if ([self.recorder prepareToRecord])
        {
            [self.recorder record];
            [sender setTitle:@"停止录音" forState:UIControlStateNormal];
            
            self.timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(detectionVoice) userInfo:self repeats:YES];

            
        }
    }
   
    
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)rightBarButtonAction:(id)sender
{
    
    if ([self.delegate respondsToSelector:@selector(recordingViewController:didFinished:info:)])
    {
        [self.delegate recordingViewController:self didFinished:nil info:nil];
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    self.navigationController.navigationBar.translucent=NO;
    
    self.title=@"录音";
    
    _timeLabel =[[UILabel alloc] init];
    _timeLabel.backgroundColor=[UIColor clearColor];
    _timeLabel.font=[UIFont systemFontOfSize:13];
    self.timeLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:self.timeLabel];
    _timeLabel.frame=CGRectMake(0, 30, self.view.bounds.size.width, 30);
    
    self.timeLabel.text=@"00:00:00";
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction:)];
    self.navigationItem.rightBarButtonItem.enabled=NO;
    
    
    UIButton * recordButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [recordButton setTitle:@"开始录音" forState:UIControlStateNormal];
    [recordButton setFrame:CGRectMake(110, 80, 100, 40)];
    //[recordButton setBackgroundImage:[UIImage imageWithColor_Ext:[UIColor colorWithRed:124.0/255.0 green:166.0/255.0 blue:49.0/255.0 alpha:1]] forState:UIControlStateHighlighted];
   // [recordButton setBackgroundImage:[UIImage imageWithColor_Ext:[UIColor blackColor]] forState:UIControlStateNormal];
    recordButton.backgroundColor=[UIColor redColor];
    [recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    recordButton.tag=101;
    [self.view addSubview:recordButton];
    [recordButton addTarget:self action:@selector(startRecording:) forControlEvents:UIControlEventTouchUpInside];

    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction:)];
    self.navigationItem.rightBarButtonItem.enabled=NO;
    
    
    
}


- (void)initRecord
{
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    [session setActive:YES error:nil];

    ///路径
    NSString * path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _soundPath = [path stringByAppendingPathComponent:@"a.caf"];
    
    
    NSMutableDictionary *recordSetting = [NSMutableDictionary dictionary];
    /*
    NSLog(@"%@",self.soundPath);
    //录音设置
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM///kAudioFormatMPEG4AAC
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    //[recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    //[recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    */
    
    //录音格式 无法使用
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    //采样率
    [recordSetting setValue :[NSNumber numberWithFloat:11025.0] forKey: AVSampleRateKey];//44100.0
    //通道数
    [recordSetting setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
    //线性采样位数
    //[recordSettings setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];
    //音频质量,采样质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    
    
    
    NSURL * url=[NSURL fileURLWithPath:self.soundPath];
    //初始化
    _recorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:nil];
    //开启音量检测
    _recorder.meteringEnabled = YES;
    _recorder.delegate = self;
    
}


- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [self.timer invalidate];
    self.timer=nil;
    [self pcmToMP3];
    ///完成
    if (flag)
    {
        NSLog(@"完成...");
    }
    
    self.navigationItem.rightBarButtonItem.enabled=YES;
    
    
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    self.recorder=nil;
    [self.timer invalidate];
    self.timer=nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.soundPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.soundPath error:nil];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.mp3Path])
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.mp3Path error:nil];
    }
    
    UIButton * reButton=(UIButton *)[self.view viewWithTag:101];
    [reButton setTitle:@"开始录音" forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem.enabled=NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
