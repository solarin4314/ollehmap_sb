//
//  CCTVViewController.m
//  OllehMap
//
//  Created by 이제민 on 13. 10. 7..
//  Copyright (c) 2013년 이제민. All rights reserved.
//

#import "CCTVViewController.h"

@interface CCTVViewController ()

- (void) initComponentsMain;

- (void) renderNavigation;

@end

@implementation CCTVViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        _info = [[NSMutableDictionary alloc] init];
        _player = nil;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/cctv_detail"];
    
    // 백그라운드 진입 노티피케이션 등록
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self initComponentsMain];
}
- (void) didEnterBackground :(id)sender
{
    // 백그라운드 진입 노티피케이션 해제
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    // 창닫기
    //[[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
    [self.player.moviePlayer stop];
}
- (void) willEnterForeground :(id)sender
{
    [self.player.moviePlayer play];
}
- (void) initComponentsMain
{
    // 네비게이션바 렌더링
    [self renderNavigation];
}

- (void) renderNavigation
{
    // 네비게이션 뷰 생성
    UIView *vwNavigation = [[UIView alloc] initWithFrame:CGRectMake(0, OM_STARTY, 320, 37)];
    
    // 배경 이미지
    UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_bg.png"]];
    [vwNavigation addSubview:imgvwBack];
    
    
    // 버튼
    UIButton *btnPrev = [[UIButton alloc] initWithFrame:CGRectMake(7, 4, 47, 28)];
    [btnPrev setImage:[UIImage imageNamed:@"title_btn_close.png"] forState:UIControlStateNormal];
    [btnPrev addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    [vwNavigation addSubview:btnPrev];
    
    // 타이틀
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(61, (37-20)/2, 198, 20)];
    [lblTitle setFont:[UIFont systemFontOfSize:20]];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setText:@"CCTV"];
    [vwNavigation addSubview:lblTitle];
    
    
    // 네비게이션 뷰 삽입
    [self.view addSubview:vwNavigation];
    
}

- (void) onClose :(id)sender
{
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:YES];
}

- (void) addFavoriteCCTV :(id)sender
{
    // 즐겨찾기 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail/favorite"];
    // CCTV 이름 조합
    NSString *cctvName = nil;
    if ( [stringValueOfDictionary(_info, @"direction") isEqualToString:@""] )
    {
        cctvName = stringValueOfDictionary(_info, @"name");
    }
    else
    {
        cctvName = [NSString stringWithFormat:@"%@(%@)", stringValueOfDictionary(_info, @"name"), stringValueOfDictionary(_info, @"direction")];
    }
    // 즐겨찾기 추가
    DbHelper *dh = [[DbHelper alloc] init];
    NSMutableDictionary *fdic = [OMDatabaseConverter makeFavoriteDictionary:-1 sortOrder:-1 category:Favorite_Category_Local title1:cctvName title2:@"교통 > CCTV" title3:@"" iconType:Favorite_IconType_CCTV coord1x:[numberValueOfDiction(_info, @"x") doubleValue] coord1y:[numberValueOfDiction(_info, @"y") doubleValue] coord2x:0 coord2y:0 coord3x:0 coord3y:0 detailType:@"CCTV" detailID:stringValueOfDictionary(_info, @"id") shapeType:@"" fcNm:@"" idBgm:@"" rdCd:@""];
    if([dh favoriteValidCheck:fdic])
    {
        [dh cctvFavoriteAdd:fdic];
    }
    
}

- (void) showCCTV:(NSDictionary *)info
{
    //[OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"%@", info]];
    
    // 즐겨찾기 및 내부 용도로 info 저장
    for (NSString *key in [info allKeys])
    {
        [_info setObject:[info objectForKey:key] forKey:key];
    }
    
    // URL 생성하기
    
    // TimeStamp
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyyMMddKKmmss"];
    NSString *cctv_TimeStamp = [dateFormatter stringFromDate:[NSDate date]];
    
    // 네트워크망 : 3G = W, Wifi = L
    NSString *cctv_NetworkType = @"W";
    if ( [OllehMapStatus sharedOllehMapStatus].getNetworkStatus == OMReachabilityStatus_connected_WiFi )
        cctv_NetworkType = @"L";
    
    NSString *cctv_DeviceName = [[OllehMapStatus sharedOllehMapStatus] getDeviceModel];
    // , 문자열은제거하자.
    cctv_DeviceName = [cctv_DeviceName stringByReplacingOccurrencesOfString:@"," withString:@"."];
    
    NSString *deviceVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    // CCTV 정보호출을 위한 속성 조합
    NSString *cctv_UrlAttribute = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@"
                                   , cctv_TimeStamp
                                   //, @"2", @"00000000000"
                                   , @"0", @"ollehmapuser"
                                   //, @"iPhone 4G"
                                   , cctv_DeviceName
                                   , cctv_NetworkType
                                   , @"0"
                                   //, @"2.0.0"
                                   , deviceVersion
                                   , @"OllehMap"
                                   ];
    
    // 속성 암호화
    cctv_UrlAttribute = [cctv_UrlAttribute AES128EncryptWithKey:[NSString stringWithFormat:@"K-%@-T", @"1234567890ab"]];
    
    // CCTV URL 조합
    NSString *cctv_Url =[NSString stringWithFormat:@"%@?attr=%@&mac=%@"
                         , stringValueOfDictionary(info, @"streaming_url")
                         , cctv_UrlAttribute
                         , @"12-34-56-78-90-ab"
                         ];
    //cctv_Url = [cctv_Url stringByReplacingOccurrencesOfString:@"14.63.237.22" withString:@"14.63.244.62"];
    
    // ====================
    // [ 렌더링 시작 ]
    // ====================
    
    // 배경 통일
    //[self.view setBackgroundColor:convertHexToDecimalRGBA(@"27", @"26", @"26", 1.0)];
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, OM_STARTY+37, 320, self.view.frame.size.height - OM_STARTY - 37)];
    [backView setBackgroundColor:convertHexToDecimalRGBA(@"27", @"26", @"26", 1.0)];
    [self.view addSubview:backView];
    
    // 타이틀 박스
    UIView *cctvNameBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 58)];
    [cctvNameBox setBackgroundColor:convertHexToDecimalRGBA(@"D9", @"F4", @"FF", 1.0)];
    // MIK.geun :: 20121008 // 도로-지점명 순서교체
    // 타이틀 - 도로명
    UILabel *cctvRoadNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 11, 300, 17)];
    [cctvRoadNameLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [cctvRoadNameLabel setTextColor:[UIColor blackColor]];
    [cctvRoadNameLabel setBackgroundColor:[UIColor clearColor]];
    [cctvRoadNameLabel setText:stringValueOfDictionary(info, @"name")];
    [cctvNameBox addSubview:cctvRoadNameLabel];
    
    // 타이틀 - 지점명
    UILabel *cctvDeviceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 33, 300, 13)];
    [cctvDeviceNameLabel setFont:[UIFont systemFontOfSize:13]];
    [cctvDeviceNameLabel setTextColor:[UIColor blackColor]];
    [cctvDeviceNameLabel setBackgroundColor:[UIColor clearColor]];
    [cctvDeviceNameLabel setText:stringValueOfDictionary(info, @"lane")];
    [cctvNameBox addSubview:cctvDeviceNameLabel];
    
    // 타이틀 박스 삽입
    [backView addSubview:cctvNameBox];
    // 타이틀 박스 해제
    
    
    // 방향 박스
    NSString *direction = stringValueOfDictionary(info, @"direction");
    if ( direction.length > 0 )
    {
        UIView *cctvDirectionBox = [[UIView alloc] initWithFrame:CGRectMake(0, 58, 320, 32)];
        // 방향
        UILabel *cctvDirectionLabel  = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 12)];
        [cctvDirectionLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [cctvDirectionLabel setTextColor:[UIColor whiteColor]];
        [cctvDirectionLabel setBackgroundColor:[UIColor clearColor]];
        [cctvDirectionLabel setText:[NSString stringWithFormat:@"(%@)",direction ]];
        [cctvDirectionBox addSubview:cctvDirectionLabel];
        
        // 방향 박스 삽입
        [backView addSubview:cctvDirectionBox];
        // 방향 박스 해제
        
    }
    
    // 영상플레이어 박스
    UIView *cctvVideoPlayerBox = [[UIView alloc] initWithFrame:CGRectMake(0, 58+32, 320, 240)];
    {
        // 오디오 초기화
        AudioSessionInitialize(NULL, NULL, NULL, (__bridge void *)(self));
        // 카테고리 설정 - 레코딩
        UInt32 category = kAudioSessionCategory_AudioProcessing;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory , sizeof(category), &category);
        // 세션공유 설정 - 기존플레이어 유지
        UInt32 otherPlaying = 1;
        AudioSessionSetProperty (kAudioSessionProperty_OtherAudioIsPlaying,sizeof (otherPlaying),&otherPlaying);
        // 세션 활성화
        AudioSessionSetActive(YES);
    }
    // 영상플레이어
    
    MPMoviePlayerViewController *tempPlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:@""]];
	self.player = tempPlayer;
    
	self.player.moviePlayer.shouldAutoplay = YES;
	self.player.moviePlayer.repeatMode = YES;
	self.player.view.frame = CGRectMake(0, 0, 320, 240);
	self.player.view.userInteractionEnabled  = NO;
	self.player.moviePlayer.controlStyle = MPMovieControlStyleNone;
	[self.player.moviePlayer setFullscreen:NO animated:NO];
    [cctvVideoPlayerBox addSubview:self.player.view];
    [self.player.moviePlayer stop];
    [self.player.moviePlayer setContentURL:[NSURL URLWithString:cctv_Url]];
    [self.player.moviePlayer play];
    // 영상플레이어 박스 삽입
    [backView addSubview:cctvVideoPlayerBox];
    // 영상플레이어 박스 해제
    
    
    // 정보제공처 박스
    UIView *cctvInfoOfferBox = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - (OM_STARTY + 37 + 37 + 56), 320, 56)];
    [cctvInfoOfferBox setBackgroundColor:convertHexToDecimalRGBA(@"27", @"26", @"26", 1.0)];
    [cctvInfoOfferBox setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    // 정보제공처 - 제공처
    UILabel *cctvInfoOfferLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 300, 11)];
    [cctvInfoOfferLabel setFont:[UIFont boldSystemFontOfSize:11]];
    [cctvInfoOfferLabel setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f)];
    [cctvInfoOfferLabel setBackgroundColor:[UIColor clearColor]];
    [cctvInfoOfferLabel setText:[NSString stringWithFormat:@"%@ 제공", stringValueOfDictionary(info, @"offer_name")]];
    [cctvInfoOfferBox addSubview:cctvInfoOfferLabel];
    
    // 정보제공처 - 경고
    UILabel *cctvInfoCaution = [[UILabel alloc] initWithFrame:CGRectMake(10, 15+11+4, 300, 11)];
    [cctvInfoCaution setFont:[UIFont systemFontOfSize:11]];
    [cctvInfoCaution setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f)];
    [cctvInfoCaution setBackgroundColor:[UIColor clearColor]];
    [cctvInfoCaution setText:@"실제 상황과 5~10분 차이가 날수 있습니다."];
    [cctvInfoOfferBox addSubview:cctvInfoCaution];
    
    // 정보제공처 박스 삽입
    [backView addSubview:cctvInfoOfferBox];
    // 정보제공처 박스 해제
    
    
    // 즐겨찾기
    UIButton *cctvAddFavoriteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - (OM_STARTY + 37) - 37, 320, 37)];
    [cctvAddFavoriteButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [cctvAddFavoriteButton setImage:[UIImage imageNamed:@"info_btn_hotlist_01.png"] forState:UIControlStateNormal];
    [cctvAddFavoriteButton addTarget:self action:@selector(addFavoriteCCTV:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:cctvAddFavoriteButton];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
