//
//  SearchRouteDialogViewController.m
//  OllehMap
//
//  Created by 이제민 on 13. 10. 8..
//  Copyright (c) 2013년 이제민. All rights reserved.
//

#import "SearchRouteDialogViewController.h"

@interface SearchRouteDialogViewController ()

@end

@implementation SearchRouteDialogViewController

- (id) init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        
        int height = IS_4_INCH ? 568 : 480;
        
        _vwSearchRouteContainer = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
        
        //_vwSearchRouteContainer = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [_vwSearchRouteContainer setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.3f]];
        //[_vwSearchRouteContainer addTarget:self action:@selector(onTouchBackground:) forControlEvents:UIControlEventTouchUpInside];
        
        // 검색 다이얼로그 그룹
        _vwSearchRouteDialog = [[UIView alloc] initWithFrame:CGRectMake(116/2, 248/2, 410/2, 458/2)];
        _imgvwSearchRouteDialogBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 410/2, 458/2)];
        
        // 출발지
        _lblStart = [[UILabel alloc] initWithFrame:CGRectMake(4/2 + 70/2, 30/2, 270/2, 30/2)];
        [_lblStart setFont:[UIFont systemFontOfSize:15]];
        [_lblStart setBackgroundColor:[UIColor clearColor]];
        
        // 경유지앞이미지
        _imgvwVisitIcon = [[UIImageView alloc] initWithFrame:CGRectMake(4/2 + 10, 14, 20, 20)];
        
        // 경유지
        _lblVisit = [[UILabel alloc] initWithFrame:CGRectMake(4/2 + 70/2, 30/2, 270/2, 30/2)];
        [_lblVisit setFont:[UIFont systemFontOfSize:15]];
        [_lblVisit setBackgroundColor:[UIColor clearColor]];
        
        _visitButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 402/2, 90/2)];
        [_visitButton addTarget:self action:@selector(touchVisit:) forControlEvents:UIControlEventTouchUpInside];
        [_visitButton setBackgroundImage:[UIImage imageNamed:@"poi_busstop_list_bg_pressed.png"] forState:UIControlStateHighlighted];
        
        
        // 플마 버튼
        _btnVisitAddRemoveButton = [[UIImageView alloc] initWithFrame:CGRectMake(4/2 + 352/2, 30/2, 30/2, 30/2)];
        //[_btnVisitAddRemoveButton addTarget:self action:@selector(onVisitAddRemove:) forControlEvents:UIControlEventTouchUpInside];
        //[_btnVisitAddRemoveButton setImage:[UIImage imageNamed:@"popup_list_p_btn.png"]];
        [self visitIconState:YES];
        
        // 도착지
        _lblDest = [[UILabel alloc] initWithFrame:CGRectMake(4/2 + 70/2, 30/2, 270/2, 30/2)];
        [_lblDest setFont:[UIFont systemFontOfSize:15]];
        [_lblDest setBackgroundColor:[UIColor clearColor]];
        
        // 버튼
        _btnReset = [[UIButton alloc] initWithFrame:CGRectMake(24/2, 364/2, 176/2, 64/2)];
        [_btnReset addTarget:self action:@selector(onReset:) forControlEvents:UIControlEventTouchUpInside];
        [_btnReset setImage:[UIImage imageNamed:@"popup_btn_reset_default.png"] forState:UIControlStateNormal];
        [_btnReset setImage:[UIImage imageNamed:@"popup_btn_reset_pressed.png"] forState:UIControlStateHighlighted];
        _btnRoute = [[UIButton alloc] initWithFrame:CGRectMake(210/2, 364/2, 176/2, 64/2)];
        [_btnRoute addTarget:self action:@selector(onRoute:) forControlEvents:UIControlEventTouchUpInside];
        [_btnRoute setImage:[UIImage imageNamed:@"popup_btn_route_default.png"] forState:UIControlStateNormal];
        [_btnRoute setImage:[UIImage imageNamed:@"popup_btn_route_pressed.png"] forState:UIControlStateHighlighted];
        [_btnRoute setImage:[UIImage imageNamed:@"popup_btn_route_disabled.png"] forState:UIControlStateDisabled];
        
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


// ===============================
// [ 길찾기 다이얼로그 호출 메소드 ]
// ===============================

static SearchRouteDialogViewController *_Instance = nil;
+ (SearchRouteDialogViewController *) sharedSearchRouteDialog
{
    if (_Instance == nil)
    {
        //_Instance = [[SearchRouteDialogViewController alloc] initWithNibName:@"SearchRouteDialogViewController" bundle:nil];
        _Instance = [[SearchRouteDialogViewController alloc] init];
    }
    return _Instance;
}

- (void) showSearchRouteDialog
{
    [self showSearchRouteDialogWithAnalytics:YES];
}

- (void) showSearchRouteDialogWithAnalytics :(BOOL)analytics
{
    //[OllehMapStatus sharedOllehMapStatus].currentMapLocationMode = MapLocationMode_None;
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    [[MapContainer sharedMapContainer_Main].kmap removeAllRouteOverlay];
    
    // 테마 클리어
    [[ThemeCommon sharedThemeCommon] clearThemeSearchResult];
    
    if (analytics)
    {
        // 버스 정류장/노선도 처리를 위한 배열 초기화
        [[OllehMapStatus sharedOllehMapStatus].pushDataBusNumberArray removeAllObjects];
        [[OllehMapStatus sharedOllehMapStatus].pushDataBusStationArray removeAllObjects];
        
        // 무조건 현재 뷰를 메인맵으로 이동처리한다.
        [[OMNavigationController sharedNavigationController] popToRootViewControllerAnimated:YES];
        //[[MapContainer sharedMapContainer_Main].kmap removeAllOverlays];
        [[MapContainer sharedMapContainer_Main].kmap removeAllOverlaysWithoutTraffic];
        [[MapContainer sharedMapContainer_Main].kmap selectPOIOverlay:nil];
    }
    
    NSLog(@"%@", [OMNavigationController sharedNavigationController].viewControllers);
    
    // 메인맵 뷰컨트롤러 가져온다.
    UIViewController *vc = [[OMNavigationController sharedNavigationController].viewControllers lastObject];
    
    
    if ([vc isKindOfClass:[MainViewController class]])
    {
        // 메인맵 뷰가 맞다면 항상 노멀스크린으로 강제한다.
        MainViewController *mmvc = (MainViewController *)vc;
        [mmvc toggleScreenMode:MapScreenMode_NORMAL :NO];
        // 실시간 정보 활성화 되어 있을경우 해제힌다.
        [mmvc clearRealtimeTrafficTimeTableForce];
        // 테마버튼 비활성화처리한다.
        mmvc.btnBottomTheme.selected = mc.kmap.theme;
        
        // 다이얼로그 뜨면 무조건 지우기버튼 삭제
        [mmvc.eraseBtn setHidden:YES];
        
        
    }
    
    [self resetDialog];
    [vc.view addSubview:_vwSearchRouteContainer];
    
    // 통계처리
    if (analytics)
        [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/find_route"];
}


// 데이터에 맞춰서 UI초기화
- (void) resetDialog
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // SearchRoute 컨테이너 클리어
    for (UIView *subview in _vwSearchRouteContainer.subviews)
    {
        [subview removeFromSuperview];
    }
    [_vwSearchRouteContainer removeFromSuperview];
    
    // 컨테이너에 다이이얼로그 삽입
    [_vwSearchRouteContainer addSubview:_vwSearchRouteDialog];
    
    // MIK.geun :: 20120802 // 무조건 꼬리말 달린상태로 팝업 노출한다. 단, 메인지도에서도 항상 노멀스크린으로 강제하도록 한다.
    [_imgvwSearchRouteDialogBackground setImage:[UIImage imageNamed:@"popup_bg.png"]];
    
    [_vwSearchRouteDialog addSubview:_imgvwSearchRouteDialogBackground];
    
    // 타이틀 렌더링
    {
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 410/2, 62/2)];
        
        UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(4/2 + 20/2, 16/2, 310/2, 16)];
        [titleLbl setFont:[UIFont systemFontOfSize:16]];
        [titleLbl setText:@"길찾기"];
        [titleLbl setTextColor:convertHexToDecimalRGBA(@"ff", @"51", @"5e", 1.0)];
        [titleView addSubview:titleLbl];
       
        
        UIButton *titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(4/2 + 348/2, 10/2, 40/2, 40/2)];
        [titleBtn setImage:[UIImage imageNamed:@"btn_close.png"] forState:UIControlStateNormal];
        [titleView addSubview:titleBtn];
        [titleBtn addTarget:self action:@selector(onTouchBackground:) forControlEvents:UIControlEventTouchUpInside];
   
        
        UIImageView *titleUnderLine = [[UIImageView alloc] initWithFrame:CGRectMake(4/2, 60/2, 402/2, 2/2)];
        [titleUnderLine setImage:[UIImage imageNamed:@"popup_title_line.png"]];
        [titleView addSubview:titleUnderLine];
  
        
        [_vwSearchRouteDialog addSubview:titleView];
  
    }
    
    // 출발지 초기화
    if (oms.searchResultRouteStart.used && !oms.searchResultRouteStart.isCurrentLocation)
    {
        [_lblStart setText:oms.searchResultRouteStart.strLocationName];
        //[self pinRouteStartPOIOverlay];
    }
    else
    {
        MapContainer *mc = [MapContainer sharedMapContainer_Main];
        
        // 출발지는 없을 경우 자동으로 내 위치로 처리
        [oms.searchResultRouteStart reset];
        [oms.searchResultRouteStart setUsed:YES];
        [oms.searchResultRouteStart setIsCurrentLocation:YES];
        [oms.searchResultRouteStart setStrLocationName:NSLocalizedString(@"Body_SR_AutoMyLoc_Start", @"")];
        // 내위치 서비스 비활성화 되어 있을 경우 "기본위치"를 사용하자..
        if ( [MapContainer CheckLocationServiceWithoutAlert] )
            [oms.searchResultRouteStart setCoordLocationPoint:[mc.kmap getUserLocation]];
        else
            [oms.searchResultRouteStart setCoordLocationPoint:OM_DefaultCoord];
        
        // 출발지 라벨 처리
        [_lblStart setText:oms.searchResultRouteStart.strLocationName];
    }
    // 출발지 렌더링
    {
        // 셀 생성
        UIControl *vwCell = [[UIControl alloc] initWithFrame:CGRectMake(4/2, 62/2, 402/2, 90/2)];
        [vwCell setBackgroundColor:convertHexToDecimalRGBA(@"f4", @"f4", @"f4", 1)];
        [vwCell addTarget:self action:@selector(touchStart:) forControlEvents:UIControlEventTouchUpInside];
        [vwCell addTarget:self action:@selector(onCellDown:) forControlEvents:UIControlEventTouchDown];
        [vwCell addTarget:self action:@selector(onCellUp:) forControlEvents:UIControlEventTouchUpOutside];
        // 아이콘
        UIImageView *imgvwIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_list_s_icon.png"]];
        [imgvwIcon setFrame:CGRectMake(4/2 + 10, 14, 20, 20)];
        [vwCell addSubview:imgvwIcon];
       
        
        // 키워드
        [vwCell addSubview:_lblStart];
        // 버튼
        UIButton *btnArrow = [[UIButton alloc] initWithFrame:CGRectMake(4/2 + 352/2, 30/2, 15, 15)];
        [btnArrow setImage:[UIImage imageNamed:@"popup_arrow_icon.png"] forState:UIControlStateNormal];
        [btnArrow addTarget:self action:@selector(touchStart:) forControlEvents:UIControlEventTouchUpInside];
        [vwCell addSubview:btnArrow];
       
        //셀 삽입
        [_vwSearchRouteDialog addSubview:vwCell];
       
        
    }
    
    // 두번째 라인
    {
        UIImageView *vwLine = [[UIImageView alloc] initWithFrame:CGRectMake(4/2, 62/2 + 90/2, 402/2, 4/2)];
        [vwLine setImage:[UIImage imageNamed:@"popup_list_line.png"]];
        [_vwSearchRouteDialog addSubview:vwLine];
        
    }
    
    
    // 경유지 초기화
    if (oms.searchResultRouteVisit.used)
    {
        [_visitButton setSelected:YES];
        [_lblVisit setTextColor:[UIColor blackColor]];
        [_lblVisit setText:oms.searchResultRouteVisit.strLocationName];
        [self visitIconState:NO];
        //[_btnVisitAddRemoveButton setImage:[UIImage imageNamed:@"popup_list_m_btn.png"]];
        [_imgvwVisitIcon setImage:[UIImage imageNamed:@"popup_list_v_icon.png"]];
    }
    else
    {
        [_visitButton setSelected:NO];
        [_lblVisit setTextColor:convertHexToDecimalRGBA(@"aa", @"aa", @"aa", 1.0f)];
        [_lblVisit setText:NSLocalizedString(@"Body_SR_Require_Visit", @"")];
        [self visitIconState:YES];
        //[_btnVisitAddRemoveButton setImage:[UIImage imageNamed:@"popup_list_p_btn.png"]];
        [_imgvwVisitIcon setImage:[UIImage imageNamed:@"popup_list_v_icon_disabled.png"]];
    }
    
    
    
    // 경유지 렌더링
    {
        // 셀 생성
        UIControl *vwCell = [[UIControl alloc] initWithFrame:CGRectMake(4/2, 62/2 + 90/2 + 4/2, 402/2, 90/2)];
        [vwCell setBackgroundColor:convertHexToDecimalRGBA(@"f4", @"f4", @"f4", 1)];
        //[vwCell addTarget:self action:@selector(touchVisit:) forControlEvents:UIControlEventTouchUpInside];
        //[vwCell addTarget:self action:@selector(onCellDown:) forControlEvents:UIControlEventTouchDown];
        //[vwCell addTarget:self action:@selector(onCellUp:) forControlEvents:UIControlEventTouchUpOutside]
        
        // 버튼
        [vwCell addSubview:_visitButton];
        
        // 아이콘
        [vwCell addSubview:_imgvwVisitIcon];
        // 키워드
        [vwCell addSubview:_lblVisit];
        // 이미지
        [vwCell addSubview:_btnVisitAddRemoveButton];

        //셀 삽입
        [_vwSearchRouteDialog addSubview:vwCell];
       
    }
    
    // 세번째 라인
    {
        UIImageView *vwLine = [[UIImageView alloc] initWithFrame:CGRectMake(4/2, 62/2 + 90/2 + 4/2 + 90/2, 402/2, 4/2)];
        [vwLine setImage:[UIImage imageNamed:@"popup_list_line.png"]];
        [_vwSearchRouteDialog addSubview:vwLine];
       
    }
    
    // 도착지 초기화
    if (oms.searchResultRouteDest.used)
    {
        [_lblDest setText:oms.searchResultRouteDest.strLocationName];
    }
    else
    {
        [_lblDest setText:NSLocalizedString(@"Body_SR_Require_Dest", @"")];
    }
    // 도착지 렌더링
    {
        // 셀 생성
        UIControl *vwCell = [[UIControl alloc] initWithFrame:CGRectMake(4/2, 62/2 + 90/2 + 4/2 + 90/2 + 4/2, 402/2, 90/2)];
        [vwCell setBackgroundColor:convertHexToDecimalRGBA(@"f4", @"f4", @"f4", 1)];
        [vwCell addTarget:self action:@selector(touchDest:) forControlEvents:UIControlEventTouchUpInside];
        [vwCell addTarget:self action:@selector(onCellDown:) forControlEvents:UIControlEventTouchDown];
        [vwCell addTarget:self action:@selector(onCellUp:) forControlEvents:UIControlEventTouchUpOutside];
        // 아이콘
        UIImageView *imgvwIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_list_g_icon.png"]];
        [imgvwIcon setFrame:CGRectMake(4/2 + 10, 14, 20, 20)];
        [vwCell addSubview:imgvwIcon];
    
        
        // 키워드
        [vwCell addSubview:_lblDest];
        // 버튼
        UIButton *btnArrow = [[UIButton alloc] initWithFrame:CGRectMake(4/2 + 352/2, 30/2, 15, 15)];
        [btnArrow setImage:[UIImage imageNamed:@"popup_arrow_icon.png"] forState:UIControlStateNormal];
        [btnArrow addTarget:self action:@selector(touchDest:) forControlEvents:UIControlEventTouchUpInside];
        [vwCell addSubview:btnArrow];
    
        //셀 삽입
        [_vwSearchRouteDialog addSubview:vwCell];
       
    }
    
    // 네번째 라인
    {
        UIImageView *vwLine = [[UIImageView alloc] initWithFrame:CGRectMake(4/2, 62/2 + 90/2 + 4/2 + 90/2 + 4/2 + 90/2, 402/2, 4/2)];
        [vwLine setImage:[UIImage imageNamed:@"popup_list_line.png"]];
        [_vwSearchRouteDialog addSubview:vwLine];
   
    }
    
    // 초기화 버튼 초기화
    [_vwSearchRouteDialog addSubview:_btnReset];
    
    // 경로탐색 버튼 초기화
    [_vwSearchRouteDialog addSubview:_btnRoute];
    
    // 경로탐색 "시작"-"도착" 정보가 둘다 존재할경우에만 버튼활성화 처리함.
    [_btnRoute setEnabled:oms.searchResultRouteStart.used && oms.searchResultRouteDest.used];
    
    // 네비관련
    MainViewController *mmvc = [[OMNavigationController sharedNavigationController].viewControllers lastObject];
    
    if(oms.searchResultRouteStart.used && !oms.searchResultRouteStart.isCurrentLocation)
    {
        [mmvc pinRouteStartPOIOverlay];
    }
    if (oms.searchResultRouteDest.used  && !oms.searchResultRouteDest.isCurrentLocation)
    {
        [mmvc pinRouteDestPOIOverlay];
    }
    if (oms.searchResultRouteVisit.used && !oms.searchResultRouteVisit.isCurrentLocation)
    {
        [mmvc pinRouteVisitPOIOverlay];
    }
}

- (void) closeSearchRouteDialog
{
    for (UIView *subview in _vwSearchRouteContainer.subviews)
    {
        [subview removeFromSuperview];
    }
    if ( _vwSearchRouteContainer.superview )
        [_vwSearchRouteContainer removeFromSuperview];
}

// *******************************



// ======================
// [ 길찾기 Interaction ]
// ======================

- (void) openSearchViewController
{
    
    // 기존화면이 검색관련 화면일 경우 미리 제거함 (검색화면 중복방지)
    OMNavigationController *nc = [OMNavigationController sharedNavigationController];
    for (int i = (int)nc.viewControllers.count-1; i >= 0; i--)
    {
        UIViewController *vc = [nc.viewControllers objectAtIndexGC:i];
        // 검색 & 검색결과 & 음성검색결과 뷰컨트롤러를 모두 제거한다.
        
        if (   ![vc isKindOfClass:[SearchResultViewController class]]
            && ![vc isKindOfClass:[SearchViewController class]]
            )
        {
            [nc popToRootViewControllerAnimated:YES];
            
            
            break;
        }
    }
    
    // 검색뷰 컨트롤러 호출
    UIStoryboard *myBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SearchViewController *svc = [myBoard instantiateViewControllerWithIdentifier:@"SearchView"];
    //[[OMNavigationController sharedNavigationController] pushViewController:svc animated:NO];
    //[svc release];
    
    [[OMNavigationController sharedNavigationController] pushViewController:svc animated:YES];
    
    
}

- (void) touchStart:(id)sender
{
    // 현재 다이얼로그는 해제..
    // [_vwSearchRouteContainer removeFromSuperview];
    
    if ([sender isKindOfClass:[UIControl class]] )
    {
        [((UIControl*)sender) setBackgroundColor:[UIColor whiteColor]];
    }
    
    // 출발지 검색화면 옵션 설정
    [[OllehMapStatus sharedOllehMapStatus] setCurrentActionType: ActionType_SEARCHROUTE];
    [[OllehMapStatus sharedOllehMapStatus] setCurrentSearchTargetType: SearchTargetType_START];
    
    // 검색화면 호출
    [self openSearchViewController];
}
- (void) touchVisit:(id)sender
{
    
//    if ([sender isKindOfClass:[UIControl class]] )
//    {
//        [((UIControl*)sender) setBackgroundColor:[UIColor whiteColor]];
//    }
    
    if(_visitButton.selected)
    {
        [self visitIconState:YES];
        
        [[OllehMapStatus sharedOllehMapStatus].searchResultRouteVisit reset];
        [self showSearchRouteDialogWithAnalytics:NO];
    }
    else
    {
    // 현재 다이얼로그는 해제..
    //[_vwSearchRouteContainer removeFromSuperview];
    // 경유지 검색화면 옵션 설정
    [[OllehMapStatus sharedOllehMapStatus] setCurrentActionType: ActionType_SEARCHROUTE];
    [[OllehMapStatus sharedOllehMapStatus] setCurrentSearchTargetType: SearchTargetType_VISIT];
    
    // 검색화면 호출
    [self openSearchViewController];
    }
    
    // 경유지 추가 횟수 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/find_route_add_via"];
    
}
- (void) touchDest:(id)sender
{
    
    if ([sender isKindOfClass:[UIControl class]] )
    {
        [((UIControl*)sender) setBackgroundColor:[UIColor whiteColor]];
    }
    
    // 현재 다이얼로그는 해제..
    // [_vwSearchRouteContainer removeFromSuperview];
    
    // 도착지 검색화면 옵션 설정
    [[OllehMapStatus sharedOllehMapStatus] setCurrentActionType: ActionType_SEARCHROUTE];
    [[OllehMapStatus sharedOllehMapStatus] setCurrentSearchTargetType: SearchTargetType_DEST];
    
    // 검색화면 호출
    [self openSearchViewController];
    
}
- (void) onReset:(id)sender
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 데이터 초기화
    [oms.searchResultRouteStart reset];
    [oms.searchResultRouteVisit reset];
    [oms.searchResultRouteDest reset];
    
    // 검색결과 초기화 (어짜피 검색하면 전부 초기화되겠지만 일단 메모리 확보차원에서라도 해보자..)
    [oms.searchRouteData reset];
    
    // Route POI 제거
    
    [[MapContainer sharedMapContainer_Main].kmap removeAllRouteOverlay];
    
    // 화면에서 제거했다가 재생성
    //   [self.view removeFromSuperview];
    [self showSearchRouteDialogWithAnalytics:NO];
    
}
- (void) onRoute:(id)sender
{
    // 길찾기 검색전 기존 검색 데이터 클리어
    [[OllehMapStatus sharedOllehMapStatus].searchRouteData reset];
    
    [[SearchRouteExecuter sharedSearchRouteExecuter] searchRoute_Car: SearchRoute_Car_SearchType_RealTime];
}

- (void) onCellDown:(id)sender
{
    UIControl *cell = (UIControl*)sender;
    
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"poi_busstop_list_bg_pressed.png"]];
    cell .backgroundColor = backgroundColor;
    
}
- (void) onCellUp:(id)sender
{
    UIControl *cell = (UIControl*)sender;
    [cell setBackgroundColor:convertHexToDecimalRGBA(@"f4", @"f4", @"f4", 1.0f)];
}

- (void) onTouchBackground:(id)sender
{
    [self closeSearchRouteDialog];
}

- (void) visitIconState:(BOOL)plus
{
                                                if(plus)
                                                    [_btnVisitAddRemoveButton setImage:[UIImage imageNamed:@"popup_list_p_btn.png"]];
                                                else
                                                    [_btnVisitAddRemoveButton setImage:[UIImage imageNamed:@"popup_list_m_btn.png"]];
}
// **********************

@end
