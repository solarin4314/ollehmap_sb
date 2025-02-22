//
//  CommonMapViewController.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 4..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "CommonMapViewController.h"

#import "MainViewController.h"
#import "SearchRouteResultMapViewController.h"

@interface CommonMapViewController ()

@end

@implementation CommonMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _vwMapViewOptionContainer = [[UIControl alloc]
                                 initWithFrame:CGRectMake(0, OM_STARTY,
                                                          [UIScreen mainScreen].bounds.size.width,
                                                          [UIScreen mainScreen].bounds.size.height - OM_STARTY)];
    
    // Toggle In-Call StatusBar
    // [_vwMapViewOptionContainer setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    
    [_vwMapViewOptionContainer setBackgroundColor:convertHexToDecimalRGBA(@"00", @"00", @"00", 0.7)];
    //[_vwMapViewOptionContainer addTarget:self action:@selector(onOptionViewCloseButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 현재 화면에 대한 액션타입과 검색관련 플래그 설정
    [[OllehMapStatus sharedOllehMapStatus] setCurrentActionType: ActionType_MAP];
    [[OllehMapStatus sharedOllehMapStatus] setCurrentSearchTargetType: SearchTargetType_NONE];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}


// =======================================
// [ 지도옵션 메소드  ]
// =======================================
- (void) showMapTrafficOptionView :(BOOL)show currentMapContainer:(MapContainer *)currentMapContainer currentMapViewController:(CommonMapViewController *)currentMapViewController
{
    [self showMapTrafficOptionView:show currentMapContainer:currentMapContainer currentMapViewController:currentMapViewController trafficOptionEnabled:YES];
}
- (void) showMapTrafficOptionView:(BOOL)show currentMapContainer:(MapContainer *)currentMapContainer currentMapViewController:(CommonMapViewController *)currentMapViewController trafficOptionEnabled:(bool)trafficOptionEnabled
{
    //OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 지도교통옵션 뷰 클리어
    for (UIView* subview in _vwMapViewOptionContainer.subviews)
    {
        [subview removeFromSuperview];
    }
    
    // 지도교통옵션 뷰 디스플레이
    if (show)
    {
        // 옵션팝업 생성
        CGRect optionPopupViewFrame = CGRectMake(88/2, 264/2 , 470/2, 436/2);
        
        UIView *optionPopupView = [[UIView alloc] initWithFrame:optionPopupViewFrame];
        [_vwMapViewOptionContainer addSubview:optionPopupView];
        
        // 옵션팝업 배경처리
        UIImageView *optionPopupBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_option_bg.png"]];
        [optionPopupBackgroundView setFrame:CGRectMake(0, 0, optionPopupBackgroundView.image.size.width, optionPopupBackgroundView.image.size.height)];
        [optionPopupView addSubview:optionPopupBackgroundView];
        
        // 타이틀부분
        // 타이틀 렌더링
        {
            UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 470/2, 62/2)];
            
            UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(4/2 + 20/2, 16/2, 310/2, 16)];
            [titleLbl setFont:[UIFont systemFontOfSize:16]];
            [titleLbl setText:@"특화지도"];
            [titleLbl setTextColor:convertHexToDecimalRGBA(@"ff", @"51", @"5e", 1.0)];
            [titleView addSubview:titleLbl];
           
            
            UIButton *titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(4/2 + 408/2, 10/2, 40/2, 40/2)];
            [titleBtn setImage:[UIImage imageNamed:@"btn_close.png"] forState:UIControlStateNormal];
            [titleView addSubview:titleBtn];
            [titleBtn addTarget:self action:@selector(onOptionViewCloseButton:) forControlEvents:UIControlEventTouchUpInside];
      
            
            UIImageView *titleUnderLine = [[UIImageView alloc] initWithFrame:CGRectMake(4/2, 60/2, 462/2, 2/2)];
            [titleUnderLine setImage:[UIImage imageNamed:@"popup_title_line.png"]];
            [titleView addSubview:titleUnderLine];
           
            
            [optionPopupView addSubview:titleView];
           
        }
        
        
        // 교통정보 사용여부
        bool useTrafficInfo = currentMapContainer.kmap.trafficInfo;
        bool useTrafficCCTV = currentMapContainer.kmap.trafficCCTV;
        bool useTrafficBusStation = currentMapContainer.kmap.trafficBusStation;
        bool useTrafficSubwayStation = currentMapContainer.kmap.trafficSubwayStation;
        bool useTrafficAddress = currentMapContainer.kmap.CadastralInfo;
        
        // 지적도 버튼
        UIButton *trafficAddressBtn = [[UIButton alloc] initWithFrame:CGRectMake(4/2 + 168/2, 62/2 + 212/2, 126/2, 126/2)];
        
        [trafficAddressBtn setImage:[UIImage imageNamed:@"map_option_btn05_off.png"] forState:UIControlStateNormal];
        [trafficAddressBtn setImage:[UIImage imageNamed:@"map_option_btn05_on.png"] forState:UIControlStateSelected];
        [trafficAddressBtn setImage:[UIImage imageNamed:@"map_option_btn05_on.png"] forState:UIControlStateHighlighted];
        [trafficAddressBtn addTarget:self action:@selector(onOPtionViewUseTrafficAddress:) forControlEvents:UIControlEventTouchUpInside];
        [trafficAddressBtn setSelected:useTrafficAddress];
        
        // 길찾기에선 지적도 OFF
        [trafficAddressBtn setEnabled:trafficOptionEnabled];
        
        [optionPopupView addSubview:trafficAddressBtn];
        
        // 교통량 사용 버튼
        UIButton *trafficInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(4/2 + 24/2, 62/2 + 212/2,126/2, 126/2)];
        [trafficInfoButton setImage:[UIImage imageNamed:@"map_option_btn01_off.png"] forState:UIControlStateNormal];
        [trafficInfoButton setImage:[UIImage imageNamed:@"map_option_btn01_on.png"] forState:UIControlStateSelected];
        [trafficInfoButton setImage:[UIImage imageNamed:@"map_option_btn01_on.png"] forState:UIControlStateHighlighted];
        [trafficInfoButton addTarget:self action:@selector(onOptionViewUseTrafficInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        // 길찾기에선 실시간교통 OFF
        //[trafficInfoButton setEnabled:trafficOptionEnabled];
        [trafficInfoButton setSelected:useTrafficInfo];
        [optionPopupView addSubview:trafficInfoButton];
        
        // CCTV 버튼
        UIButton *trafficCCTVButton = [[UIButton alloc] initWithFrame:CGRectMake(4/2 + 24/2, 62/2 + 28/2, 126/2, 126/2)];
        
        [trafficCCTVButton setImage:[UIImage imageNamed:@"map_option_btn02_off.png"] forState:UIControlStateNormal];
        [trafficCCTVButton setImage:[UIImage imageNamed:@"map_option_btn02_on.png"] forState:UIControlStateSelected];
        [trafficCCTVButton setImage:[UIImage imageNamed:@"map_option_btn02_on.png"] forState:UIControlStateHighlighted];
        //[trafficCCTVButton setImage:[UIImage imageNamed:@"map_option_btn02_off.png"] forState:UIControlStateDisabled];
        [trafficCCTVButton addTarget:self action:@selector(onOptionViewUseTrafficCCTV:) forControlEvents:UIControlEventTouchUpInside];
        
        // 길찾기에선 cctv off
        [trafficCCTVButton setEnabled:trafficOptionEnabled];
        [trafficCCTVButton setSelected:useTrafficCCTV];
        [optionPopupView addSubview:trafficCCTVButton];
        
        // 버스정류장 버튼
        UIButton *trafficBusStationButton = [[UIButton alloc] initWithFrame:CGRectMake(4/2 + 168/2, 62/2 + 28/2, 126/2, 126/2)];
        [trafficBusStationButton setImage:[UIImage imageNamed:@"map_option_btn03_off.png"] forState:UIControlStateNormal];
        [trafficBusStationButton setImage:[UIImage imageNamed:@"map_option_btn03_on.png"] forState:UIControlStateSelected];
        [trafficBusStationButton setImage:[UIImage imageNamed:@"map_option_btn03_on.png"] forState:UIControlStateHighlighted];
        //[trafficBusStationButton setImage:[UIImage imageNamed:@"map_option_btn03_off.png"] forState:UIControlStateDisabled];
        [trafficBusStationButton addTarget:self action:@selector(onOptionViewUseTrafficBusStation:) forControlEvents:UIControlEventTouchUpInside];
        
        // 길찾기에선 버스정류장 off
        [trafficBusStationButton setEnabled:trafficOptionEnabled];
        [trafficBusStationButton setSelected:useTrafficBusStation];
        [optionPopupView addSubview:trafficBusStationButton];
        
        // 지하철역 버튼
        UIButton *trafficSubwayStationButton = [[UIButton alloc] initWithFrame:CGRectMake(4/2 + 312/2, 62/2 + 28/2, 126/2, 126/2)];
        [trafficSubwayStationButton setImage:[UIImage imageNamed:@"map_option_btn04_off.png"] forState:UIControlStateNormal];
        [trafficSubwayStationButton setImage:[UIImage imageNamed:@"map_option_btn04_on.png"] forState:UIControlStateSelected];
        [trafficSubwayStationButton setImage:[UIImage imageNamed:@"map_option_btn04_on.png"] forState:UIControlStateHighlighted];
        //[trafficSubwayStationButton setImage:[UIImage imageNamed:@"map_option_btn04_off.png"] forState:UIControlStateDisabled];
        [trafficSubwayStationButton addTarget:self action:@selector(onOptionViewUseTrafficSubwayStation:) forControlEvents:UIControlEventTouchUpInside];
        
        // 길찾기에선 지하철역 off
        [trafficSubwayStationButton setEnabled:trafficOptionEnabled];
        [trafficSubwayStationButton setSelected:useTrafficSubwayStation];
        [optionPopupView addSubview:trafficSubwayStationButton];
        
        // 지도교통옵션 컨테이너 삽입
        [_vwMapViewOptionContainer addSubview:optionPopupView];
        [currentMapViewController.view addSubview:_vwMapViewOptionContainer];
        
    }
    else
    {
        // 뷰 숨김처리
        [_vwMapViewOptionContainer removeFromSuperview];
    }
}
- (void) onOptionViewCloseButton :(id)sender
{
    [self showMapTrafficOptionView:NO currentMapContainer:nil currentMapViewController:nil];
}
// 지적도 보기 메서드
- (void) onOPtionViewUseTrafficAddress:(id)sender
{
}
- (void) onOptionViewUseTrafficInfo :(id)sender
{
    // 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/main/traffic_info"];
    // 상세구현은 각 맵뷰컨트롤러에서 처리한다.
}
- (void) onOptionViewUseTrafficCCTV:(id)sender
{
    // 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/traffictheme/cctv"];
    
    // 상세구현은 각 맵뷰컨트롤러에서 처리한다.
}
- (void) onOptionViewUseTrafficBusStation:(id)sender
{
    // 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/traffictheme/busstation"];
    // 상세구현은 각 맵뷰컨트롤러에서 처리한다.
}
- (void) onOptionViewUseTrafficSubwayStation:(id)sender
{
    // 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/traffictheme/subwaystation"];
    // 상세구현은 각 맵뷰컨트롤러에서 처리한다.
}
// ***************************************


// =======================================
// [ 공통 보조 메소드 시작 ]
// =======================================

// ***************************************

@end
