//
//  ContactViewController.m
//  OllehMap
//
//  Created by 이제민 on 13. 10. 1..
//  Copyright (c) 2013년 이제민. All rights reserved.
//

#import "ContactViewController.h"
#import "ServerConnector.h"
#import "MapContainer.h"
#import "MainViewController.h"

@implementation OMControlContact

@synthesize addresses = _addresses;
@synthesize name = _name;

@end


@interface ContactViewController ()

// ================
// [ 초기화 메소드 ]
// ================
- (void) initComponent;
// ****************

// =====================
// [ 공통 렌더링 메소드 ]
// =====================
- (void) renderContact;
- (void) renderMultiAddressSelector :(NSString*)name :(NSArray*)addresses;
- (void) renderMultiSearchResultSelector :(BOOL)isAddress :(BOOL)isNewAddress;
- (void) onCellDown :(id)sender;
- (void) onCellUp:(id)sender;

// *********************

// =====================
// [ 연락처 제어 메소드 ]
// =====================
- (void) searchPersonAddress :(ABRecordRef)ref;
- (void) search :(NSString *)personName :(NSString*)personAddress;
- (void) didFinishSearch :(id)request;
// *********************

// ==============================
// [ 네비게이션 메소드 - private ]
// ==============================
- (void) onClose :(id)sender;
- (void) onCloseAddressList :(id)sender;
- (void) onSelectAddress :(id)sender;
- (void) onSelectSearchResult :(id)sender;
// ******************************

// =====================================================
// [ ABPeoplePickerNavigationController Delegate 메소드 ]
// =====================================================
- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person;
- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier;
// *****************************************************

@end

@implementation ContactViewController


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
    [self initComponent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ===============
// 클래스 메소드
// ===============
+ (BOOL) checkAddressBookAuth
{
    if ( [ContactViewController checkAddressBookAuthWithoutMessage]  )
    {
        return YES;
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :@"올레 map이 연락처에 접근할 수 있는 권한이 없습니다."];
        return NO;
    }
}
+ (BOOL) checkAddressBookAuthWithoutMessage
{
    
    // 주소록 데이터 접근
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if ( version >= 6.0  ) // Version 6.0 이상부터는 연락처 접근시 승인여부를 확인해야 한다. (**예약)
    {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        // 접근권한 변수 생성
        __block BOOL accessGranted = NO;
        
        //  iOS 6 에만 존재하는 메소드 호출해야 한다. 혹시나 해서 널체크 해보고~
        if (ABAddressBookRequestAccessWithCompletion != NULL)
        {
            // 세마포어 생성
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            // 연락처 접근권한 받아오는 메세지박스 띄우는 메소드 호출
            ABAddressBookRequestAccessWithCompletion(addressBook,
                                                     ^(bool granted, CFErrorRef error) {
                                                         accessGranted = granted; // 사용자가 선택한 권한을 넘겨주도록
                                                         dispatch_semaphore_signal(sema); // 세마포어 락을 해제하는 시그널 전송
                                                     } );
            // 해제 명령이 들어오기 전까지 무한 대기하도록 한다.
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            // 세마포어 해제
            dispatch_release(sema);
        }
        
        if ( accessGranted == NO )
        {
            // 사용자가 접근권한을 제한한 경우
            return NO;
        }
        else
        {
            // 사용자가 접근 권한을 허용한 경우라도 다시 한번 권한이 있는지 체크한다.
            CFIndex addressbookAuth = ABAddressBookGetAuthorizationStatus();
            if ( addressbookAuth != kABAuthorizationStatusAuthorized )
            {
                return NO;
            }
        }
    }
    
    // 이단계까지 문제가 없었다면 연락처 사용가능하도록 리턴
    return YES;
}
// ****************

// ================
// [ 초기화 메소드 ]
// ================

- (void) initComponent
{
    // 다중 주소 선택 화면 초기화
    _vwMultiAddressSelector = [[UIView alloc]
                               initWithFrame:CGRectMake(0, OM_STARTY,
                                                        [[UIScreen mainScreen] bounds].size.width,
                                                        self.view.frame.size.height - OM_STARTY)];
    [_vwMultiAddressSelector setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
    
    // 연락처 렌더링
    [self renderContact];
}

// ****************


// =====================
// [ 공통 렌더링 메소드 ]
// =====================

- (void) renderContact
{
    // 주소록 카운트 처리
    //CFIndex peopleCount = ABAddressBookGetPersonCount(_addressbook);
    
    // IOS 버전별로 주소록 생성이 달라짐.
    ABAddressBookRef addressbook = NULL;
    if ( [[[UIDevice currentDevice] systemVersion ] floatValue] < 6.0 )
        addressbook = ABAddressBookCreate();
    else
        addressbook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    CFIndex peopleCount = ABAddressBookGetPersonCount(addressbook);
    CFRelease(addressbook);
    
    // 연락처가 하나도 없을 경우
    if (peopleCount <= 0)
    {
        [self renderNavigation];
        
        UIView *vwEmpty = [[UIView alloc] initWithFrame:CGRectMake(0, 37+46, 320, 470-37-46)];
        [vwEmpty setBackgroundColor:[UIColor whiteColor]];
        
        UILabel *lblEmpty = [[UILabel alloc] initWithFrame:CGRectMake(0, 166, 320, 15)];
        [lblEmpty setFont:[UIFont systemFontOfSize:15]];
        [lblEmpty setTextAlignment:NSTextAlignmentCenter];
        [lblEmpty setText:NSLocalizedString(@"Body_Search_Contact_Empty", @"")];
        [vwEmpty addSubview:lblEmpty];
        
        
        [self.view addSubview:vwEmpty];
        
    }
    // 연락처 존재할 경우
    else
    {
        _peoplePicker = [[OmPeoplePickerNavigationControllerViewController alloc] init];
        // ios7에서 네비바 가리면 검색버튼이 안생겨
        //[_peoplePicker setNavigationBarHidden:YES];
        [_peoplePicker setPeoplePickerDelegate:self];

        [self.view addSubview:_peoplePicker.view];

    }
    
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
    [btnPrev setImage:[UIImage imageNamed:@"title_bt_before.png"] forState:UIControlStateNormal];
    [btnPrev addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    [vwNavigation addSubview:btnPrev];
    
    // 타이틀
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(61, (37-20)/2, 198, 20)];
    [lblTitle setFont:[UIFont systemFontOfSize:20]];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setText:@"연락처"];
    [vwNavigation addSubview:lblTitle];
    
    
    // 네비게이션 뷰 삽입
    [self.view addSubview:vwNavigation];
    
}
- (void) renderMultiAddressSelector:(NSString*)name :(NSArray *)addresses
{
    //  딤드화면 클리어
    for (UIView *subview in _vwMultiAddressSelector.subviews)
    {
        [subview removeFromSuperview];
    }
    
    // 팝업 리스트 뷰 배경
    UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_bg.png"]];
    
    // 팝업 리스트 뷰 생성
    UIView *vwMultiPOISelector = [[UIView alloc]
                                  initWithFrame:CGRectMake(116/2,202/2,410/2,
                                                           552/2)];
    
    [imgvwBack setFrame:CGRectMake(0, 0, 410/2, 552/2)];
    [vwMultiPOISelector addSubview:imgvwBack];
    
    // 타이틀 렌더링
    {
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 410/2, 62/2)];
        
        UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(4/2 + 20/2, 16/2, 310/2, 16)];
        [titleLbl setFont:[UIFont systemFontOfSize:16]];
        [titleLbl setText:@"연락처"];
        [titleLbl setTextColor:convertHexToDecimalRGBA(@"ff", @"51", @"5e", 1.0)];
        [titleView addSubview:titleLbl];
        
        UIButton *titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(4/2 + 348/2, 10/2, 40/2, 40/2)];
        [titleBtn setImage:[UIImage imageNamed:@"btn_close.png"] forState:UIControlStateNormal];
        [titleView addSubview:titleBtn];
        [titleBtn addTarget:self action:@selector(onCloseAddressList:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *titleUnderLine = [[UIImageView alloc] initWithFrame:CGRectMake(4/2, 60/2, 402/2, 2/2)];
        [titleUnderLine setImage:[UIImage imageNamed:@"popup_title_line.png"]];
        [titleView addSubview:titleUnderLine];
        
        [vwMultiPOISelector addSubview:titleView];
    }
    
    
    // 사용자 이름 노출
    UILabel *lblContactUserName = [[UILabel alloc] initWithFrame:CGRectMake(4/2, 62/2, 402/2, 90/2)];
    [lblContactUserName setFont:[UIFont boldSystemFontOfSize:15]];
    [lblContactUserName setTextColor:[UIColor blackColor]];
    [lblContactUserName setBackgroundColor:convertHexToDecimalRGBA(@"d8", @"d8", @"d8", 1.0)];
    [lblContactUserName setLineBreakMode:NSLineBreakByTruncatingTail];
    [lblContactUserName setTextAlignment:NSTextAlignmentCenter];
    [lblContactUserName setText:name];
    [vwMultiPOISelector addSubview:lblContactUserName];
    
    UIImageView *userNameUnderLine = [[UIImageView alloc] initWithFrame:CGRectMake(4/2, 62/2 + 90/2, 402/2, 4/2)];
    [userNameUnderLine setImage:[UIImage imageNamed:@"popup_list_line.png"]];
    [vwMultiPOISelector addSubview:userNameUnderLine];
    
    // 리스트 스크롤뷰 컨텐츠 높이
    float listContentsHeight = 0.0f;
    
    // 스크롤뷰 생성
    OMScrollView *svwList = [[OMScrollView alloc] initWithFrame:CGRectMake(0, 62/2 + 90/2 + 4/2, 402/2, (270+12)/2)];
    [svwList setDelegate:self];
    [svwList setScrollType:2];
    
    for (int i=0, maxi=(int)addresses.count; i<maxi; i++)
    {
        NSString *address = [addresses objectAtIndexGC:i];
        
        // POI 뷰 생성
        CGRect rectCell = CGRectMake(4/2, listContentsHeight, svwList.frame.size.width, 90/2);
        OMControlContact *vwCell = [[OMControlContact alloc] initWithFrame:rectCell];
        [vwCell setBackgroundColor:convertHexToDecimalRGBA(@"f4", @"f4", @"f4", 1.0)];
        [vwCell setTag:i];
        [vwCell addTarget:self action:@selector(onSelectAddress:) forControlEvents:UIControlEventTouchUpInside];
        [vwCell addTarget:self action:@selector(onCellDown:) forControlEvents:UIControlEventTouchDown];
        [vwCell addTarget:self action:@selector(onCellUp:) forControlEvents:UIControlEventTouchUpOutside];
        [vwCell setName:name];
        [vwCell setAddresses:addresses];
        
        // 라벨
        CGRect rectName = CGRectMake(80/2, 33/2, 310/2, 28/2);
        UILabel *lblName =[[UILabel alloc] initWithFrame:rectName];
        [lblName setFont:[UIFont systemFontOfSize:14]];
        [lblName setTextColor:[UIColor blackColor]];
        [lblName setBackgroundColor:[UIColor clearColor]];
        [lblName setTextAlignment:NSTextAlignmentLeft];
        [lblName setLineBreakMode:NSLineBreakByClipping];
        [lblName setText:address];
        
        // 라벨 텍스트에 최적화정보
        LabelResizeInfo labelNameResizeInfo = getLabelResizeInfo(lblName, 310/2);
        // 라벨 사이즈에 따른 라벨 높이 수정
        if (labelNameResizeInfo.numberOfLines > 1)
        {
            rectName.origin.y = labelNameResizeInfo.origin.y = 20/2;
            rectName.size = labelNameResizeInfo.newSize;
        }
        else
        {
            rectName.origin.y = labelNameResizeInfo.origin.y = 32/2;
            rectName.size = labelNameResizeInfo.newSize;
        }
        // 라벨 텍스트 변경사항 반영
        setLabelResizeWithLabelResizeInfo(lblName, labelNameResizeInfo);
        
        [vwCell addSubview:lblName];

        
        // 라벨에 따른 뷰 사이즈 수정
        if ( labelNameResizeInfo.numberOfLines > 1)
            rectCell.size.height = rectName.size.height + 20/2 + 20/2;
        else
            rectCell.size.height = rectName.size.height + 32/2 + 30/2;
        
        // 인덱스 아이콘
        UIImageView *imgvwIndexIconBalloon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_b_marker_poi.png"]];
        CGRect rectIndexIconBalloon = CGRectMake(20/2, 14/2, imgvwIndexIconBalloon.image.size.width, imgvwIndexIconBalloon.image.size.height);
        
        // 인덱스 아이콘도 텍스트 라벨 높이에 맞춰 높낮이가 달라진다.
        if ( labelNameResizeInfo.numberOfLines > 1 ) rectIndexIconBalloon.origin.y = 20/2;
        else  rectIndexIconBalloon.origin.y = 16/2;
        [imgvwIndexIconBalloon setFrame:rectIndexIconBalloon];
        
        [vwCell addSubview:imgvwIndexIconBalloon];
        
        // POI 뷰 삽입
        [vwCell setFrame:rectCell];
        [svwList addSubview:vwCell];
        listContentsHeight += rectCell.size.height;
        
        // 라인 삽입
        UIImageView *vwLine = [[UIImageView alloc] initWithFrame:CGRectMake(4/2, listContentsHeight, svwList.frame.size.width, 4/2)];
        [vwLine setImage:[UIImage imageNamed:@"popup_list_line.png"]];
        [svwList addSubview:vwLine];
        listContentsHeight += 2;
    }
    [svwList setContentSize:CGSizeMake(svwList.frame.size.width, listContentsHeight)];
    [vwMultiPOISelector addSubview:svwList];
    
    // 닫기 버튼
    UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(116/2, 460/2, 176/2, 64/2)];
    [btnClose setImage:[UIImage imageNamed:@"popup_btn_cancel.png"] forState:UIControlStateNormal];
    [btnClose setImage:[UIImage imageNamed:@"popup_btn_cancel_pressed.png"] forState:UIControlStateHighlighted];
    [btnClose addTarget:self action:@selector(onCloseAddressList:) forControlEvents:UIControlEventTouchUpInside];
    [vwMultiPOISelector addSubview:btnClose];
    
    // 팝업 리스트 뷰 삽입
    [_vwMultiAddressSelector addSubview:vwMultiPOISelector];
    
    
    // 주소가 2개 이상일때 목록화면 노출
    [self.view addSubview:_vwMultiAddressSelector];
}

- (void) renderMultiSearchResultSelector:(BOOL)isAddress :(BOOL)isNewAddress
{
    //  딤드화면 클리어
    for (UIView *subview in _vwMultiAddressSelector.subviews)
    {
        [subview removeFromSuperview];
    }
    
    // 팝업 리스트 뷰 배경
    UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_bg.png"]];
    
    // 팝업 리스트 뷰 생성
    UIView *vwMultiPOISelector = [[UIView alloc]
                                  initWithFrame:CGRectMake(116/2,202/2,410/2,
                                                           552/2)];
    
    [imgvwBack setFrame:CGRectMake(0, 0, 410/2, 552/2)];
    [vwMultiPOISelector addSubview:imgvwBack];

    
    // 타이틀 렌더링
    {
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 410/2, 62/2)];
        
        UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(4/2 + 20/2, 16/2, 310/2, 16)];
        [titleLbl setFont:[UIFont systemFontOfSize:16]];
        [titleLbl setText:@"연락처"];
        [titleLbl setTextColor:convertHexToDecimalRGBA(@"ff", @"51", @"5e", 1.0)];
        [titleView addSubview:titleLbl];
        
        UIButton *titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(4/2 + 348/2, 10/2, 40/2, 40/2)];
        [titleBtn setImage:[UIImage imageNamed:@"btn_close.png"] forState:UIControlStateNormal];
        [titleView addSubview:titleBtn];
        [titleBtn addTarget:self action:@selector(onCloseAddressList:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *titleUnderLine = [[UIImageView alloc] initWithFrame:CGRectMake(4/2, 60/2, 402/2, 2/2)];
        [titleUnderLine setImage:[UIImage imageNamed:@"popup_title_line.png"]];
        [titleView addSubview:titleUnderLine];
        
        [vwMultiPOISelector addSubview:titleView];
    }
    
    
    // 사용자 이름 노출
    UILabel *lblContactUserName = [[UILabel alloc] initWithFrame:CGRectMake(4/2, 62/2, 402/2, 90/2)];
    [lblContactUserName setFont:[UIFont boldSystemFontOfSize:15]];
    [lblContactUserName setTextColor:[UIColor blackColor]];
    [lblContactUserName setBackgroundColor:convertHexToDecimalRGBA(@"d8", @"d8", @"d8", 1.0)];
    [lblContactUserName setLineBreakMode:NSLineBreakByTruncatingTail];
    [lblContactUserName setTextAlignment:NSTextAlignmentCenter];
    [lblContactUserName setText:[OllehMapStatus sharedOllehMapStatus].keyword];
    [vwMultiPOISelector addSubview:lblContactUserName];
    
    UIImageView *userNameUnderLine = [[UIImageView alloc] initWithFrame:CGRectMake(4/2, 62/2 + 90/2, 402/2, 4/2)];
    [userNameUnderLine setImage:[UIImage imageNamed:@"popup_list_line.png"]];
    [vwMultiPOISelector addSubview:userNameUnderLine];
    
    
    // 리스트 스크롤뷰 컨텐츠 높이
    float listContentsHeight = 0.0f;
    
    // 스크롤뷰 생성
    OMScrollView *svwList = [[OMScrollView alloc] initWithFrame:CGRectMake(0, 62/2 + 90/2 + 4/2, 402/2, (270+12)/2)];
    [svwList setDelegate:self];
    [svwList setScrollType:2];
    
    NSArray *searchResultList = nil;
    if ( isAddress && isNewAddress) searchResultList = [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataNewAddress"];
    else if (isAddress) searchResultList = [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataAddress"];
    else searchResultList = [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataPlace"];
    
    for (int i=0, maxi=(int)searchResultList.count; i<maxi; i++)
    {
        // 검색결과 하나씩 가져온다.
        NSDictionary *poiDic = [searchResultList objectAtIndexGC:i];
        
        if (isAddress)
        {
            NSLog(@"연락처 - 주소 검색");
            // 솔성 가져오기
            NSString *strName = nil;
            if ( isNewAddress ) strName = [NSString stringWithFormat:@"%@", stringValueOfDictionary(poiDic, @"NEW_ADDR")];
            else strName = [NSString stringWithFormat:@"%@", stringValueOfDictionary(poiDic, @"ADDRESS")];
            NSString *strAddr = nil;
            if ( isNewAddress ) strAddr = [NSString stringWithFormat:@"%@", stringValueOfDictionary(poiDic, @"NEW_ADDR")];
            else strAddr = [NSString stringWithFormat:@"%@", stringValueOfDictionary(poiDic, @"ADDRESS")];
            
            // POI 뷰 생성
            CGRect rectCell = CGRectMake(4/2, listContentsHeight, svwList.frame.size.width, 90/2);
            OMControlContact *vwCell = [[OMControlContact alloc] initWithFrame:rectCell];
            [vwCell setBackgroundColor:convertHexToDecimalRGBA(@"f4", @"f4", @"f4", 1.0)];
            vwCell.isAddress = isAddress;
            vwCell.isNewAddress = isNewAddress;
            [vwCell setTag:i];
            [vwCell addTarget:self action:@selector(onSelectSearchResult:) forControlEvents:UIControlEventTouchUpInside];
            [vwCell addTarget:self action:@selector(onCellDown:) forControlEvents:UIControlEventTouchDown];
            [vwCell addTarget:self action:@selector(onCellUp:) forControlEvents:UIControlEventTouchUpOutside];
            [vwCell setName:strName];
            [vwCell setAddresses:searchResultList];
            
            // 라벨
            CGRect rectName = CGRectMake(80/2, 33/2, 310/2, 28/2); // 한줄 기준
            UILabel *lblName =[[UILabel alloc] initWithFrame:rectName];
            [lblName setFont:[UIFont systemFontOfSize:28/2]];
            [lblName setTextColor:[UIColor blackColor]];
            [lblName setBackgroundColor:[UIColor clearColor]];
            [lblName setTextAlignment:NSTextAlignmentLeft];
            [lblName setLineBreakMode:NSLineBreakByClipping];
            [lblName setText:strAddr];
            
            // 라벨 텍스트에 최적화정보
            LabelResizeInfo labelNameResizeInfo = getLabelResizeInfo(lblName, 310/2);
            // 라벨 사이즈에 따른 라벨 높이 수정
            if (labelNameResizeInfo.numberOfLines > 1)
            {
                rectName.origin.y = labelNameResizeInfo.origin.y = 20/2;
                rectName.size = labelNameResizeInfo.newSize;
            }
            else
            {
                rectName.origin.y = labelNameResizeInfo.origin.y = 32/2;
                rectName.size = labelNameResizeInfo.newSize;
            }
            // 라벨 텍스트 변경사항 반영
            setLabelResizeWithLabelResizeInfo(lblName, labelNameResizeInfo);
            
            [lblName setFrame:rectName];
            [vwCell addSubview:lblName];
            
            // 라벨에 따른 뷰 사이즈 수정
            if ( labelNameResizeInfo.numberOfLines > 1 )
                rectCell.size.height = rectName.size.height + 20/2 + 20/2;
            else
                rectCell.size.height = rectName.size.height + 32/2 + 30/2;
            
            // 인덱스 아이콘 풍선
            UIImageView *imgvwIndexIconBalloon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_b_marker_poi.png"]];
            CGRect rectIndexIconBalloon = CGRectMake(20/2, 14/2, imgvwIndexIconBalloon.image.size.width, imgvwIndexIconBalloon.image.size.height);
            
            // 라벨 높이에 따른 아이콘 위치 변경
            if ( labelNameResizeInfo.numberOfLines > 1 )
                rectIndexIconBalloon.origin.y = 20/2;   // 원래 18/2
            else
                rectIndexIconBalloon.origin.y = 16/2;   // 원래 14/2
            
            [imgvwIndexIconBalloon setFrame:rectIndexIconBalloon];
            [vwCell addSubview:imgvwIndexIconBalloon];
            
            // POI 뷰 삽입
            [vwCell setFrame:rectCell];
            [svwList addSubview:vwCell];
            listContentsHeight += rectCell.size.height;
            
        }
        // 장소검색 결과인 경우
        else
        {
            NSLog(@"연락처 - 장소 검색");
            // 솔성 가져오기
            NSString *strName = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"NAME"]];
            NSString *strAddr = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"ADDR"]];
            
            // POI 뷰 생성
            CGRect rectCell = CGRectMake(0, listContentsHeight, svwList.frame.size.width, 90/2);
            OMControlContact *vwCell = [[OMControlContact alloc] initWithFrame:rectCell];
            [vwCell setBackgroundColor:convertHexToDecimalRGBA(@"f4", @"f4", @"f4", 1.0)];
            vwCell.isAddress = isAddress;
            vwCell.isNewAddress = isNewAddress;
            [vwCell setTag:i];
            [vwCell addTarget:self action:@selector(onSelectSearchResult:) forControlEvents:UIControlEventTouchUpInside];
            [vwCell addTarget:self action:@selector(onCellDown:) forControlEvents:UIControlEventTouchDown];
            [vwCell addTarget:self action:@selector(onCellUp:) forControlEvents:UIControlEventTouchUpOutside];
            [vwCell setName:strName];
            [vwCell setAddresses:searchResultList];
            
            // 라벨 (장소)
            CGRect rectName = CGRectMake(80/2, 20/2, 310/2, 28/2);
            UILabel *lblName =[[UILabel alloc] initWithFrame:rectName];
            [lblName setFont:[UIFont boldSystemFontOfSize:28/2]];
            [lblName setTextColor:[UIColor blackColor]];
            [lblName setBackgroundColor:[UIColor clearColor]];
            [lblName setTextAlignment:NSTextAlignmentLeft];
            [lblName setLineBreakMode:NSLineBreakByTruncatingTail];
            [lblName setText:[NSString stringWithFormat:@"%@", strName]];
            [vwCell addSubview:lblName];
            
            // 라벨 (주소)
            CGRect rectAddress = CGRectMake(80/2, 56/2, 310/2, 28/2);
            UILabel *lblAddress =[[UILabel alloc] initWithFrame:rectAddress];
            [lblAddress setFont:[UIFont systemFontOfSize:28/2]];
            [lblAddress setTextColor:[UIColor blackColor]];
            [lblAddress setBackgroundColor:[UIColor clearColor]];
            [lblAddress setTextAlignment:NSTextAlignmentLeft];
            [lblAddress setLineBreakMode:NSLineBreakByClipping];
            [lblAddress setText:[NSString stringWithFormat:@"%@", strAddr]];
            [lblAddress setNumberOfLines:999];
            rectAddress.size = [lblAddress.text sizeWithFont:lblAddress.font constrainedToSize:CGSizeMake(rectAddress.size.width, FLT_MAX) lineBreakMode:lblAddress.lineBreakMode];
            
            // 라벨 높이 조정
            if (rectAddress.size.height < 28/2) rectAddress.size.height = 28/2;
            
            [lblAddress setFrame:rectAddress];
            [vwCell addSubview:lblAddress];
            
            
            // 라벨에 따른 뷰 사이즈 수정
            rectCell.size.height = rectName.size.height + 8/2 + rectAddress.size.height + 20/2 + 20/2;
            
            // 인덱스 아이콘 풍선
            UIImageView *imgvwIndexIconBalloon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_b_marker_poi.png"]];
            CGRect rectIndexIconBalloon = CGRectMake(20/2, 14/2, imgvwIndexIconBalloon.image.size.width, imgvwIndexIconBalloon.image.size.height);
            [imgvwIndexIconBalloon setFrame:rectIndexIconBalloon];
            [vwCell addSubview:imgvwIndexIconBalloon];
            
            // POI 뷰 삽입
            [vwCell setFrame:rectCell];
            [svwList addSubview:vwCell];
            listContentsHeight += rectCell.size.height;
            
        }
        
        // 라인 삽입
        UIImageView *vwLine = [[UIImageView alloc] initWithFrame:CGRectMake(4/2, listContentsHeight, svwList.frame.size.width, 4/2)];
        [vwLine setImage:[UIImage imageNamed:@"popup_list_line.png"]];
        [svwList addSubview:vwLine];
        listContentsHeight += 2;
    }
    [svwList setContentSize:CGSizeMake(svwList.frame.size.width, listContentsHeight)];
    [vwMultiPOISelector addSubview:svwList];
    
    // 닫기 버튼
    UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(116/2, 460/2, 176/2, 64/2)];
    [btnClose setImage:[UIImage imageNamed:@"popup_btn_cancel.png"] forState:UIControlStateNormal];
    [btnClose setImage:[UIImage imageNamed:@"popup_btn_cancel_pressed.png"] forState:UIControlStateHighlighted];
    [btnClose addTarget:self action:@selector(onCloseAddressList:) forControlEvents:UIControlEventTouchUpInside];
    [vwMultiPOISelector addSubview:btnClose];
    
    // 팝업 리스트 뷰 삽입
    [_vwMultiAddressSelector addSubview:vwMultiPOISelector];
    
    
    // 주소가 2개 이상일때 목록화면 노출
    [self.view addSubview:_vwMultiAddressSelector];
}

- (void) onCellDown :(id)sender
{
    UIControl *cell = (UIControl*)sender;
    
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"poi_busstop_list_bg_pressed.png"]];
    cell .backgroundColor = backgroundColor;
    //[cell setBackgroundColor:convertHexToDecimalRGBA(@"D9", @"F4", @"FF", 1.0)];
}
- (void) onCellUp:(id)sender
{
    UIControl *cell = (UIControl*)sender;
    [cell setBackgroundColor:convertHexToDecimalRGBA(@"f4", @"f4", @"f4", 1.0f)];
    //[cell setBackgroundColor:[UIColor whiteColor]];
}

// *********************

// =====================
// [ 연락처 제어 메소드 ]
// =====================


- (void) searchPersonAddress :(ABRecordRef)ref
{
    CFStringRef firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
    CFStringRef lastName = ABRecordCopyValue(ref, kABPersonLastNameProperty);
    //NSNumber *recordId = [NSNumber numberWithInteger: ABRecordGetRecordID(ref)];
    
    NSMutableArray *phoneAddressStringList = [NSMutableArray array];
    
    // 주소 구조체 및 카테고리 추출
    ABMultiValueRef phoneAddress = (ABMultiValueRef)ABRecordCopyValue(ref, kABPersonAddressProperty);
    for (CFIndex j = 0, maxj = ABMultiValueGetCount(phoneAddress); j < maxj; j++)
    {
        //CFStringRef label = ABMultiValueCopyLabelAtIndex(phoneAddress, j);
        CFTypeRef tempRef = ABMultiValueCopyValueAtIndex(phoneAddress, j);
        
        
        if (tempRef != nil)
        {
            NSMutableString *phoneAddressString = [NSMutableString string];
            
            NSDictionary *addressDic = (__bridge NSDictionary*)tempRef;
            //NSLog(@"%@", addressDic);
            
            if ([[addressDic allKeys] containsObject:@"State"] )
                [phoneAddressString appendFormat:@"%@ ", [addressDic objectForKeyGC:@"State"]]; // 서울시
            if ([[addressDic allKeys] containsObject:@"City"] )
                [phoneAddressString appendFormat:@"%@ ", [addressDic objectForKeyGC:@"City"]]; // 00구
            
            if ([[addressDic allKeys] containsObject:@"Street"] )
            {
                NSArray *streets = [[addressDic objectForKeyGC:@"Street"] componentsSeparatedByString:@"\n"];
                if ( streets.count > 0 )
                    for (NSString *street in streets)
                        [phoneAddressString appendFormat:@"%@ ", street]; // 00동 00번지
                else
                    [phoneAddressString appendFormat:@"%@ ", [addressDic objectForKeyGC:@"Street"]]; // 00동 00번지
            }
            
            //[phoneAddressString appendFormat:@"%@ ", [addressDic objectForKeyGC:@"Country"]];
            //[phoneAddressString appendFormat:@"%@ ", [addressDic objectForKeyGC:@"CountryCode"]];
            
            [phoneAddressStringList addObject: [phoneAddressString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ];
            
            //NSLog(@"이름 : %@ %@/ 주소 : %@", (NSString*)firstName, (NSString*)lastName, phoneAddressString);
        }
        
        //if (label) CFRelease(label);
        if (tempRef) CFRelease(tempRef);
    }
    CFRelease(phoneAddress);
    
    if (phoneAddressStringList.count <= 0)
    {
        [OMMessageBox showAlertMessage:@"" :@"주소가 없습니다."];
    }
    else if (phoneAddressStringList.count == 1)
    {
        
        NSMutableString *name = [NSMutableString string];
        if (lastName != nil) [name appendFormat:@"%@", (__bridge NSString*)lastName];
        if (firstName != nil) [name appendFormat:@" %@", (__bridge NSString*)firstName];
        NSString *name2 = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *addres = [phoneAddressStringList objectAtIndexGC:0];
        
        [self search:name2 :addres];
    }
    else if (phoneAddressStringList.count >= 2)
    {
        NSMutableString *name = [NSMutableString string];
        if (lastName != nil) [name appendFormat:@"%@", (__bridge NSString*)lastName];
        if (firstName != nil) [name appendFormat:@" %@", (__bridge NSString*)firstName];
        NSString *name2 = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [self renderMultiAddressSelector:name2 :phoneAddressStringList];
    }
    else
    {
    }
    
    if (firstName != nil) CFRelease(firstName);
    if (lastName != nil) CFRelease(lastName);
    
}

- (void) search :(NSString *)personName :(NSString*)personAddress;
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    //oms.keyword = personName;
    oms.keyword = personAddress;
    
    [oms resetLocalSearchDictionary:@"Place"];
    [oms resetLocalSearchDictionary:@"Address"];
    [oms resetLocalSearchDictionary:@"NewAddress"];
    [oms resetLocalSearchDictionary:@"PublicBusStation"];
    [oms resetLocalSearchDictionary:@"PublicBusNumber"];
    [oms resetLocalSearchDictionary:@"PublicSubwayStation"];
    
    // 주소검색 실행
    Coord searchCrd = [MapContainer sharedMapContainer_Main].kmap.centerCoordinate;
    [[ServerConnector sharedServerConnection] requestSearchPlaceAndAddress:self action:@selector(didFinishSearch:) key:personAddress mapX:searchCrd.x mapY:searchCrd.y s:@"an" sr:@"RANK" p_startPage:0 a_startPage:0 n_startPage:0 indexCount:5 option:1];
}

- (void) didFinishSearch :(id)request
{
    
    // 검색결과를 받아서 처리한다.
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        @try
        {
            OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
            
            // 주소검색결과
            if ( [[request userString] isEqualToString:@"an"] )
            {
                // 검색결과 카운트 계산
                int countNewAddress = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountNewAddress"] intValue];
                int countAddress = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountAddress"] intValue];
                
                // 새주소 검색결과가 한개일 경우
                if ( countNewAddress == 1)
                {
                    // 지도화면 전환
                    NSMutableDictionary *dicAddress = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataNewAddress"] objectAtIndexGC:0];
                    
                    Coord poiCrd = CoordMake([[dicAddress objectForKeyGC:@"X"] doubleValue], [[dicAddress objectForKeyGC:@"Y"] doubleValue]);
                    NSString *addressName = [dicAddress objectForKeyGC:@"NEW_ADDR"];
                    
                    [oms.searchResult reset]; // 검색결과 리셋
                    [oms.searchResult setUsed:YES];
                    [oms.searchResult setIsCurrentLocation:NO];
                    //[oms.searchResult setStrLocationName:oms.keyword];
                    [oms.searchResult setStrLocationName:addressName];
                    [oms.searchResult setStrLocationAddress:addressName];
                    [oms.searchResult setCoordLocationPoint:poiCrd];
                    [oms.searchResult setStrID:@""];
                    [oms.searchResult setStrType:@"ADDR"];
                    [oms.searchResult setIndex:0];
                    
                    [MainViewController markingSinglePOI_RenderType:MapRenderType_SearchResult_SinglePOI category:MainMap_SinglePOI_Type_Normal animated:YES];
                }
                // 새주소 검색결과가 여러개 있을 경우
                else if ( countNewAddress > 1)
                {
                    // 새주소의 경우 완전 동일한 주소는 존재하지 않는다는 가정하에 목록을 다 보여주도록 한다.
                    // 여러개 주소 렌더링
                    [self renderMultiSearchResultSelector:YES:YES];
                }
                // 주소 검색결과가 한개일경우
                else if (countAddress == 1 )
                {
                    // 지도화면 전환
                    NSMutableDictionary *dicAddress = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataAddress"] objectAtIndexGC:0];
                    
                    Coord poiCrd = CoordMake([[dicAddress objectForKeyGC:@"X"] doubleValue], [[dicAddress objectForKeyGC:@"Y"] doubleValue]);
                    NSString *addressName = [dicAddress objectForKeyGC:@"ADDRESS"];
                    
                    [oms.searchResult reset]; // 검색결과 리셋
                    [oms.searchResult setUsed:YES];
                    [oms.searchResult setIsCurrentLocation:NO];
                    //[oms.searchResult setStrLocationName:oms.keyword];
                    [oms.searchResult setStrLocationName:addressName];
                    [oms.searchResult setStrLocationAddress:addressName];
                    [oms.searchResult setCoordLocationPoint:poiCrd];
                    [oms.searchResult setStrID:@""];
                    [oms.searchResult setStrType:@"ADDR"];
                    [oms.searchResult setIndex:0];
                    
                    [MainViewController markingSinglePOI_RenderType:MapRenderType_SearchResult_SinglePOI category:MainMap_SinglePOI_Type_Normal animated:YES];

                }
                // 주소 검색결과가 여러개일 경우
                else if (countAddress > 1)
                {
                    // 주소검색결과가 여러개라도 최초 검색어와 동일한케이스가 존재하면 바로 이동한다.
                    NSArray *searchResultList = [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataAddress"];
                    for (int i=0, maxi=(int)searchResultList.count; i<maxi; i++)
                    {
                        // 검색결과 하나씩 가져온다.
                        NSDictionary *poiDic = [searchResultList objectAtIndexGC:i];
                        // 솔성 가져오기
                        NSString *strName = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"ADDRESS"]];
                        NSString *strAddr = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"ADDRESS"]];
                        
                        NSLog(@"|%@|  |%@|", strAddr, oms.keyword);
                        
                        if ([strAddr isEqualToString:[OllehMapStatus sharedOllehMapStatus].keyword])
                        {
                            
                            Coord poiCrd = CoordMake([[poiDic objectForKeyGC:@"X"] doubleValue], [[poiDic objectForKeyGC:@"Y"] doubleValue]);
                            
                            [oms.searchResult reset]; // 검색결과 리셋
                            [oms.searchResult setUsed:YES];
                            [oms.searchResult setIsCurrentLocation:NO];
                            //[oms.searchResult setStrLocationName:oms.keyword];
                            [oms.searchResult setStrLocationName:strName];
                            [oms.searchResult setStrLocationAddress:strAddr];
                            [oms.searchResult setCoordLocationPoint:poiCrd];
                            [oms.searchResult setStrID:@""];
                            [oms.searchResult setStrType:@"ADDR"];
                            [oms.searchResult setIndex:0];
                            
                            [MainViewController markingSinglePOI_RenderType:MapRenderType_SearchResult_SinglePOI category:MainMap_SinglePOI_Type_Normal animated:YES];
                            
                            return;
                        }
                    }
                    
                    // 여러개 주소 렌더링
                    [self renderMultiSearchResultSelector:YES:NO];
                }
                // 주소 검색결과가 없으면
                else
                {
                    // 장소 검색 시도
                    // 주소검색 실행
                    Coord searchCrd = [MapContainer sharedMapContainer_Main].kmap.centerCoordinate;
                    [[ServerConnector sharedServerConnection] requestSearchPlaceAndAddress:self action:@selector(didFinishSearch:) key:oms.keyword mapX:searchCrd.x mapY:searchCrd.y s:@"p" sr:@"RANK" p_startPage:0 a_startPage:0 n_startPage:0 indexCount:5 option:1];
                    
                }
            }
            // 장소검색결과
            else if ( [[request userString] isEqualToString:@"p"] )
            {
                // 검색결과 카운트 계산
                int countPlace = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountPlace"] intValue];
                
                // 장소 검색결과 존재하면 처리
                if (countPlace == 1 )
                {
                    [self renderMultiSearchResultSelector:NO:NO];
                }
                // 장소 검색결과가 여러개일 경우
                else if (countPlace > 1)
                {
                    [self renderMultiSearchResultSelector:NO:NO];
                }
                // 장소 검색 결과마저 없으면 메세지 처리
                else
                {
                    // 오류없이 결과없음 메세지 처리
                    //[OMMessageBox showAlertMessage:NSLocalizedString(@"Msg_SearchFailed_InvalidAddress", @"") :[NSString stringWithFormat:@"\n\"%@\"", [request userObject]]];
                    [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailed_InvalidAddress", @"")];
                }
                
            }
        }
        
        @catch (NSException *ex)
        {
            NSLog(@"didFinishSearchInit 메소드 예외발생 : %@", [ex reason]);
        }
        
    }
    else if([[OllehMapStatus sharedOllehMapStatus] getNetworkStatus] == OMReachabilityStatus_disconnected)
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_NetworkException", @"")];
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}


// *********************



// ==============================
// [ 네비게이션 메소드 - private ]
// ==============================

- (void) onClose :(id)sender
{
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}

- (void) onCloseAddressList:(id)sender
{
    for (UIView *subview in _vwMultiAddressSelector.subviews)
    {
        [subview removeFromSuperview];
    }
    
    [_vwMultiAddressSelector removeFromSuperview];
    
}

- (void) onSelectAddress:(id)sender
{
    // 호출한 셀 정보가져오기
    OMControlContact *cell = (OMControlContact*)sender;
    NSString *address = [[cell addresses] objectAtIndexGC:cell.tag];
    
    // 주소선택 팝업 제거
    [_vwMultiAddressSelector removeFromSuperview];
    
    // 검색시도
    [self search:cell.name :address];
    
}

- (void) onSelectSearchResult:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 호출한 셀 정보가져오기
    OMControlContact *cell = (OMControlContact*)sender;
    NSDictionary *poiDic = [[cell addresses] objectAtIndexGC:cell.tag];
    //BOOL isAddress = [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataAddress"] == [cell addresses];
    BOOL isAddress = cell.isAddress;
    BOOL isNewAddress = cell.isNewAddress;
    
    if (isAddress)
    {
        NSString *strName = nil;
        if ( isNewAddress ) strName = [NSString stringWithFormat:@"%@", stringValueOfDictionary(poiDic, @"NEW_ADDR")];
        else strName = [NSString stringWithFormat:@"%@", stringValueOfDictionary(poiDic, @"ADDRESS")];
        NSString *strAddr = nil;
        if ( isNewAddress ) strAddr = [NSString stringWithFormat:@"%@", stringValueOfDictionary(poiDic, @"NEW_ADDR")];
        else strAddr = [NSString stringWithFormat:@"%@", stringValueOfDictionary(poiDic, @"ADDRESS")];
        
        NSString *strID = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@""]];
        NSString *strType = [NSString stringWithFormat:@"ADDR"];
        Coord crd = CoordMake([[poiDic objectForKeyGC:@"X"] doubleValue], [[poiDic objectForKeyGC:@"Y"] doubleValue]);
        //NSString * strSTheme = @"";
        
        [oms.searchResult reset];
        [oms.searchResult setUsed:YES];
        [oms.searchResult setIsCurrentLocation:NO];
        [oms.searchResult setStrType:strType];
        [oms.searchResult setStrID:strID];
        [oms.searchResult setStrLocationName:strName];
        [oms.searchResult setStrLocationAddress:strAddr];
        [oms.searchResult setCoordLocationPoint:crd];
        
        [_vwMultiAddressSelector removeFromSuperview];
        
        [MainViewController markingSinglePOI_RenderType:MapRenderType_SearchResult_SinglePOI category:MainMap_SinglePOI_Type_Normal animated:YES];
        
    }
    else
    {
        NSString *strName = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"NAME"]];
        NSString *strAddr = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"ADDR"]];
        NSString *strID = nil;
        NSString *strType = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"ORG_DB_TYPE"]];
        NSString *strSTheme = @"";
        if ([strType isEqualToString:@"TR"])
        {
            strType = @"TR_RAW";
            strID = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"DOCID"]];
        }
        else if ([strType isEqualToString:@"OL"])
        {
            strID = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"DOCID"]];
        }
        else if ([strType isEqualToString:@"MV"])
        {
            strID = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"DOCID"]];
        }
        else
        {
            strID = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"ORG_DB_ID"]];
        }
        
        if ([[poiDic allKeys] containsObject:@"STHEME_CODE"] && [[poiDic objectForKeyGC:@"STHEME_CODE"] isEqualToString:@"PG1201000000008"] )
            strSTheme = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"STHEME_CODE"]];
        else
            strSTheme = @"";
        
        Coord crd = CoordMake([[poiDic objectForKeyGC:@"X"] doubleValue], [[poiDic objectForKeyGC:@"Y"] doubleValue]);
        
        [oms.searchResult reset];
        [oms.searchResult setUsed:YES];
        [oms.searchResult setIsCurrentLocation:NO];
        [oms.searchResult setStrType:strType];
        [oms.searchResult setStrID:strID];
        [oms.searchResult setStrLocationName:strName];
        [oms.searchResult setStrLocationAddress:strAddr];
        [oms.searchResult setCoordLocationPoint:crd];
        [oms.searchResult setStrSTheme:strSTheme];
        
        [_vwMultiAddressSelector removeFromSuperview];
        
        [MainViewController markingSinglePOI_RenderType:MapRenderType_SearchResult_SinglePOI category:MainMap_SinglePOI_Type_Normal animated:YES];
    }
    
}

// ******************************


// =====================================================
// [ ABPeoplePickerNavigationController Delegate 메소드 ]
// =====================================================


- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [self searchPersonAddress:person];
    return NO;
}

- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    [self searchPersonAddress:person];
    return NO;
}

- (void) peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    NSLog(@"peoplePickerNavigationControllerDidCancel");
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:YES];
}

// *****************************************************

@end













// 이미지 터치 회전값 구하기
double whellAngleFromPoint (CGPoint location, UIImage *image)
{
    double retAngle;
    
    // subtract center of whell
    location.x -= image.size.width / 2.0;
    location.y = image.size.height / 2.0 - location.y;
    
    // normalize vector
    double vector_length = sqrt(location.x * location.x + location.y * location.y);
    location.x = location.x / vector_length;
    location.y = location.y / vector_length;
    
    retAngle = acos(location.y);
    
    if (location.x<0)
        retAngle = -retAngle;
    
    return retAngle;
}

