//
//  SearchResultViewController.m
//  OllehMap
//
//  Created by 이제민 on 13. 9. 30..
//  Copyright (c) 2013년 이제민. All rights reserved.
//

#import "SearchResultViewController.h"

@interface SearchResultViewController ()

@end

@implementation OMTableView : UITableView
@end
@implementation UIPlaceTableView : OMTableView
@end
@implementation UIAddressTableView : OMTableView
@end
@implementation UIBusStationTableView : OMTableView
@end
@implementation UIBusNumberTableView : OMTableView
@end
@implementation UISubwayTableView : OMTableView
@end
@implementation UIResearchTableView : UITableView
@end

@implementation UIReSearchTableViewCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        [self.textLabel setBackgroundColor:[UIColor clearColor]];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    // Highlighted - 빨간색
    // Normal - 투명
    [self setBackgroundColor:highlighted ? convertHexToDecimalRGBA(@"d9", @"f4", @"ff", 1) : [UIColor clearColor]];
    [self.textLabel setTextColor:highlighted ? [UIColor blackColor] : [UIColor blackColor]];
}

@end


@implementation SearchResultViewController

@synthesize radioType;
@synthesize topType;
@synthesize baseOption;

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
    
    [self initer];
    
    [[ThemeCommon sharedThemeCommon] clearThemeSearchResult];
    
    [[OllehMapStatus sharedOllehMapStatus].pushDataBusNumberArray removeAllObjects];
    [[OllehMapStatus sharedOllehMapStatus].pushDataBusStationArray removeAllObjects];
    
    // 지도화면중심 기준
    [self coordSetMapCenterCoordinate:YES];
    
    NSLog(@"radio : %d, top : %d", _commonRadioType, _topType);
    
    [self topViewRender];
    
    switch (_currentSearchTargetType)
    {
        case SearchTargetType_VOICENONE:
        case SearchTargetType_VOICESTART:
        case SearchTargetType_VOICEVISIT:
        case SearchTargetType_VOICEDEST:
            [_voiceBtn setHidden:NO];
            break;
            
        default:
            [_voiceBtn setHidden:YES];
            break;
    }
    
    // 음성인식 키워드 선택 뷰 초기화
    _vwVoiceKeywordSelectorContainer = [[UIView alloc]
                                        initWithFrame:CGRectMake(0, OM_STARTY,
                                                                 320,
                                                                 self.view.frame.size.height - OM_STARTY)];
    [_vwVoiceKeywordSelectorContainer setBackgroundColor:[UIColor colorWithRed:00 green:00 blue:00 alpha:0.7]];
    
    // 재검색 키워드 선택 뷰 초기화
    _vwreSearchContainer = [[UIView alloc]
                            initWithFrame:CGRectMake(0, OM_STARTY,
                                                     [[UIScreen mainScreen] bounds].size.width,
                                                     self.view.frame.size.height - OM_STARTY)];
    [_vwreSearchContainer setBackgroundColor:[UIColor colorWithRed:00 green:00 blue:00 alpha:0.7]];
    
    
    _vwIndicatorByScroll = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, (74+72+76)/2)];
    [_vwIndicatorByScroll setBackgroundColor:[UIColor clearColor]];
    
    // 더보기뷰
    _moreView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 402/2, 40)];
    
    // 테이블뷰
    _reSearchTableView = [[UIResearchTableView alloc] initWithFrame:CGRectMake(4/2, 62/2 + 90/2, 402/2, 90/2 + 90/2 + 90/2) style:UITableViewStylePlain];
    [_reSearchTableView setDelegate:self];
    [_reSearchTableView setDataSource:self];
    
    
    UIButton *moreBtn = [[UIButton alloc] init];
    [moreBtn setTitle:@"더보기" forState:UIControlStateNormal];
    [moreBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    moreBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [moreBtn setFrame:CGRectMake(0, 0, 402/2, 30)];
    [moreBtn addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
    [_moreView addSubview:moreBtn];
    
}

- (void) initer
{
    _addressTopBottomType = addressTopSection;
    willBaseOption = 1;
    
    if(baseOption == 0)
        baseOption = 1;
    
    exceptioner = NO;
    sameNameOtherPlaceCheck = NO;
    keywordChange = NO;
    _reSearchDic = [[NSMutableArray alloc] init];
    _prevMutableDictionary = [[NSMutableDictionary alloc] init];
    
    [self initWithIndex];
    
    
    
    [_placeTableView setFrame:CGRectMake(0, OM_STARTY+ 148, 320, self.view.frame.size.height - 111 - OM_STARTY)];
    [_addressTableView setFrame:CGRectMake(0, OM_STARTY+ 111, 320, self.view.frame.size.height - 111 -OM_STARTY)];
    [_busStationTableView setFrame:CGRectMake(0, OM_STARTY+111, 320, self.view.frame.size.height - 111-OM_STARTY)];
    [_busNumTableView setFrame:CGRectMake(0, OM_STARTY+111, 320, self.view.frame.size.height - 111-OM_STARTY)];
    [_subwayTableView setFrame:CGRectMake(0, OM_STARTY+111, 320, self.view.frame.size.height - 111-OM_STARTY)];
    
    _tableY = _placeTableView.frame.origin.y;
    _placeNAddressY = _placeNAddressView.frame.origin.y;
    
    // 하단뷰
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 37)];
    [_bottomView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    
    // 이미지
    UIImageView *bottomBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_bottom_bg.png"]];
    [bottomBg setFrame:CGRectMake(0, 0, 320, 37)];
    [_bottomView addSubview:bottomBg];
    
    // 라벨
    _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 0, 24, 37)];
    [_pageLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [_pageLabel setBackgroundColor:[UIColor clearColor]];
    [_pageLabel setTextAlignment:NSTextAlignmentRight];
    [_pageLabel setText:@"0"];
    [_bottomView addSubview:_pageLabel];
    
    UILabel *segLabel = [[UILabel alloc] initWithFrame:CGRectMake(154, 0, 12, 37)];
    [segLabel setFont:[UIFont systemFontOfSize:15]];
    [segLabel setTextAlignment:NSTextAlignmentCenter];
    [segLabel setBackgroundColor:[UIColor clearColor]];
    [segLabel setTextColor:convertHexToDecimalRGBA(@"8b", @"8b", @"8b", 1.0)];
    [segLabel setText:@"/"];
    [_bottomView addSubview:segLabel];
    
    _totalPageLabel = [[UILabel alloc] initWithFrame:CGRectMake(167, 0, 49, 37)];
    [_totalPageLabel setFont:[UIFont systemFontOfSize:15]];
    [_totalPageLabel setTextAlignment:NSTextAlignmentLeft];
    [_totalPageLabel setBackgroundColor:[UIColor clearColor]];
    [_totalPageLabel setTextColor:convertHexToDecimalRGBA(@"8b", @"8b", @"8b", 1.0)];
    [_totalPageLabel setText:@"0"];
    [_bottomView addSubview:_totalPageLabel];
    
    // 버튼
    _prevBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_prevBtn setFrame:CGRectMake(0, 0, 38, 37)];
    [_prevBtn setImage:[UIImage imageNamed:@"btn_left_arrow_pressed.png"] forState:UIControlStateNormal];
    [_prevBtn setImage:[UIImage imageNamed:@"btn_left_arrow.png"] forState:UIControlStateDisabled];
    [_prevBtn addTarget:self action:@selector(prevBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_prevBtn];
    
    
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nextBtn setFrame:CGRectMake(282, 0, 38, 37)];
    [_nextBtn setImage:[UIImage imageNamed:@"btn_right_arrow_pressed.png"] forState:UIControlStateNormal];
    [_nextBtn setImage:[UIImage imageNamed:@"btn_right_arrow.png"] forState:UIControlStateDisabled];
    [_nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_nextBtn];
}
- (void) initWithIndex
{
    _localIndex = -1;
    _addressIndex = -1;
    _busStationIndex = -1;
    _busNumberIndex = -1;
    _subwayIndex = -1;
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    //NSLog(@"currentSearchTargetType : %d", oms.currentSearchTargetType);
    //NSLog(@"_currentSearchTargetType : %d", _currentSearchTargetType);
    
    [oms setCurrentSearchTargetType:_currentSearchTargetType];
    
    [oms.pushDataBusNumberArray removeAllObjects];
    [oms.pushDataBusStationArray removeAllObjects];
    
    [self initWithIndex];
    [self tableViewReloader];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void) tableViewReloader
{
    [_placeTableView reloadData];
    [_addressTableView reloadData];
    [_busStationTableView reloadData];
    [_busNumTableView reloadData];
    [_subwayTableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) topViewRender
{
    // 검색 결과 카운트
    int countPlace, countAddress, countPublicBs, countPublicBn, countPublicSs, countPublic;
    
    countPlace =  [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountPlace"] intValue];
    countAddress = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountAddress"] intValue] + [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountNewAddress"] intValue];
    countPublicBs = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountPublicBusStation"] intValue];
    countPublicBn = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountPublicBusNumber"] intValue];
    countPublicSs = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountPublicSubwayStation"] intValue];
    countPublic = countPublicBs + countPublicBn + countPublicSs;
    
    
    
    
    if(countPlace > 0)
    {
        _topType = topSelectedType_place;
        _commonRadioType = commonRadioButtonType_accuracy;
        
    }
    else if (countAddress > 0)
    {
        _topType = topSelectedType_address;
        _commonRadioType = commonRadioButtonType_accuracy;
        
    }
    else if(countPublic > 0)
    {
        _topType = topSelectedType_public;
        
        if(countPublicBs > 0)
            _commonRadioType = commonRadioButtonType_busStation;
        else if (countPublicBn > 0)
            _commonRadioType = commonRadioButtonType_busNumber;
        else if(countPublicSs > 0)
            _commonRadioType = commonRadioButtonType_subWay;
        else
            NSLog(@"안와");
    }
    else
    {
        NSLog(@"여까지안옴");
    }
    
    if(self.radioType && self.topType)
    {
        _commonRadioType = self.radioType;
    }
    if(self.topType)
    {
        _topType = self.topType;
    }
    NSLog(@"리얼검색 : radio : %d, top : %d", _commonRadioType, _topType);
    
    
    [self topViewButtonStringAbled];
    [self searchSuccess];
    [self bottomViewDraw];
    
    keywordChange = NO;
    
}

- (void)search:(int)page option:(int)option
{
    NSLog(@"장소/주소/대중교통 검색하는 함수들어옴, (페이징:%d)", page);
    
    NSLog(@"option : %d", option);
    
    [self nullCheckImage];
    
    Coord myCrd;
    myCrd.x = _nSearchX;
    myCrd.y = _nSearchY;
    
    _page = page;
    
    // 장소버튼이 클릭 되었다면
    if(_topWillType == topWillSelectType_place)
    {
        // 정확도순 클릭되었다면
        if(_commonRadioWillType == commonRadioWillButtonType_accuracy)
        {
            // 장소정보 요청
            [[ServerConnector sharedServerConnection] requestSearchPlaceAndAddress:self action:@selector(didFinishSearchAll:) key:[OllehMapStatus sharedOllehMapStatus].keyword mapX:myCrd.x mapY:myCrd.y s:@"p" sr:@"RANK" p_startPage:page a_startPage:0 n_startPage:0 indexCount:15 option:option];
        }
        // 거리순 클릭되었다면
        else if(_commonRadioWillType == commonRadioWillButtonType_distance)
        {
            // 장소정보 요청
            [[ServerConnector sharedServerConnection] requestSearchPlaceAndAddress:self action:@selector(didFinishSearchAll:) key:[OllehMapStatus sharedOllehMapStatus].keyword mapX:myCrd.x mapY:myCrd.y s:@"p" sr:@"DIS" p_startPage:page a_startPage:0 n_startPage:0 indexCount:15 option:option];
        }
    }
    // 주소버튼이 클릭되었다면
    else if(_topWillType == topWillSelectType_address)
    {
        // 정확도순 클릭되었다면
        if(_commonRadioWillType == commonRadioWillButtonType_accuracy)
        {
            
            if(_addressType == addressSearchType_new)
            {
                [[ServerConnector sharedServerConnection] requestSearchPlaceAndAddress:self action:@selector(didFinishSearchAll:) key:[OllehMapStatus sharedOllehMapStatus].keyword mapX:_nSearchX mapY:_nSearchY s:@"an" sr:@"RANK" p_startPage:0 a_startPage:0 n_startPage:page indexCount:15 option:option];
            }
            else
                // 주소정보 요청
                [[ServerConnector sharedServerConnection] requestSearchPlaceAndAddress:self action:@selector(didFinishSearchAll:) key:[OllehMapStatus sharedOllehMapStatus].keyword mapX:_nSearchX mapY:_nSearchY s:@"an" sr:@"RANK" p_startPage:0 a_startPage:page n_startPage:page indexCount:15 option:option];
        }
        // 거리순 클릭되었다면
        else if(_commonRadioWillType == commonRadioWillButtonType_distance)
        {
            
            if(_addressType == addressSearchType_new)
            {
                [[ServerConnector sharedServerConnection] requestSearchPlaceAndAddress:self action:@selector(didFinishSearchAll:) key:[OllehMapStatus sharedOllehMapStatus].keyword mapX:_nSearchX mapY:_nSearchY s:@"an" sr:@"DIS" p_startPage:0 a_startPage:0 n_startPage:page indexCount:15 option:option];
            }
            else
                // 주소정보 요청
                [[ServerConnector sharedServerConnection] requestSearchPlaceAndAddress:self action:@selector(didFinishSearchAll:) key:[OllehMapStatus sharedOllehMapStatus].keyword mapX:_nSearchX mapY:_nSearchY s:@"an" sr:@"DIS" p_startPage:0 a_startPage:page n_startPage:page indexCount:15 option:option];
        }
    }
    // 버스/지하철 클릭되었다면
    else if(_topWillType == topWillSelectType_public)
    {
        // 버스번호 요청
        if(_commonRadioWillType == commonRadioWillButtonType_busNumber)
            
        {
            [[ServerConnector sharedServerConnection] requestSearchPublicBusNumber:self action:@selector(didFinishSearchAll:) key:[OllehMapStatus sharedOllehMapStatus].keyword startPage:page indexCount:15];
        }
        // 버스정거장 요청
        else if (_commonRadioWillType == commonRadioWillButtonType_busStation) {
            
            if([[OllehMapStatus sharedOllehMapStatus] number5VaildCheck:[OllehMapStatus sharedOllehMapStatus].keyword] || [[OllehMapStatus sharedOllehMapStatus] uniqueVaildCheck:[OllehMapStatus sharedOllehMapStatus].keyword])
            {
                [[ServerConnector sharedServerConnection] requestSearchPublicBusStationUnique:self action:@selector(didFinishSearchAll:) UniqueId:[OllehMapStatus sharedOllehMapStatus].keyword];
            }
            else
            {
                [[ServerConnector sharedServerConnection] requestSearchPublicBusStation:self action:@selector(didFinishSearchAll:) Name:[OllehMapStatus sharedOllehMapStatus].keyword ViewCnt:15 Page:page];
            }
        }
        // 지하철 요청
        else if(_commonRadioWillType == commonRadioWillButtonType_subWay)
        {
            [[ServerConnector sharedServerConnection] requestSearchPublicSubwayStation:self action:@selector(didFinishSearchAll:) Name:[OllehMapStatus sharedOllehMapStatus].keyword];
        }
        
    }
}

- (void) didFinishSearchAll :(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        
        if(_commonRadioWillType == commonRadioWillButtonType_distance)
        {
            OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
            
        for (int i=0; i<[(NSMutableDictionary *)[oms.searchLocalDictionary objectForKeyGC:@"DataPlace"] count]; i++)
        {
            NSMutableDictionary *dic = [[oms.searchLocalDictionary objectForKey:@"DataPlace"] objectAtIndexGC:i];
            
            Coord objectCoord = CoordMake([[dic objectForKeyGC:@"X"] doubleValue], [[dic objectForKeyGC:@"Y"] doubleValue]);
            Coord myCoord = CoordMake([MapContainer sharedMapContainer_Main].kmap.centerCoordinate.x, [MapContainer sharedMapContainer_Main].kmap.centerCoordinate.y);
            
            double objectDistance = CoordDistance(myCoord, objectCoord);
            
            [dic setObject:[NSString stringWithFormat:@"%f", objectDistance] forKey:@"DISTANCE"];
            
            
        }

        NSSortDescriptor *temp2 = [[NSSortDescriptor alloc] initWithKey:@"DISTANCE" ascending:YES];
        
        [[oms.searchLocalDictionary objectForKeyGC:@"DataPlace"] sortUsingDescriptors:[NSArray arrayWithObjects:temp2,nil]];

        }
        

        
        [self popUpCancelBtnClick:nil];
        
        int topSetType = _topWillType;
        _topType = topSetType;
        
        int commonRadioSetType = _commonRadioWillType;
        _commonRadioType = commonRadioSetType;
        
        if(keywordChange)
            [self topViewRender];
        else
        {
            [self topViewButtonStringAbled];
            [self searchSuccess];
            [self bottomViewDraw];
        }
    }
    else {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
        // 네트워크 오류로 실패시에 이전상태로 되돌린다
        [self searchFail];
        
    }
}
- (void) bottomViewDraw
{
    // 검색 결과 카운트
    int countPlace, countAddress, countPublicBs, countPublicBn, countPublicSs, countPublic;
    
    countPlace =  [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountPlace"] intValue];
    countAddress = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountAddress"] intValue] + [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountNewAddress"] intValue];
    countPublicBs = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountPublicBusStation"] intValue];
    countPublicBn = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountPublicBusNumber"] intValue];
    countPublicSs = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountPublicSubwayStation"] intValue];
    countPublic = countPublicBs + countPublicBn + countPublicSs;
    
    int currentPage = 0;
    int totalPage = 0;
    
    switch (_topType) {
        case topSelectedType_place:
        {
            currentPage = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"CurrentPagePlace"] intValue];
            totalPage = 1 + (int)((countPlace-1)/15);
            
            if([(NSMutableDictionary *)[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"SearchType"] count] < 1)
            {
                
                baseOption = willBaseOption;
            }
            else
            {
                NSLog(@"_prevMutableDic : %@", _prevMutableDictionary);

                
                if([_prevMutableDictionary count] > 1)
                    [_prevMutableDictionary removeAllObjects];
                
                [_prevMutableDictionary setObject:[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"SearchType"] forKey:@"SearchType"];
                [_prevMutableDictionary setObject:[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"QueryResult"] forKey:@"QueryResult"];
                [_prevMutableDictionary setObject:[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"Na_Result"] forKey:@"Na_Result"];
                
                willBaseOption = baseOption;
            }
            
            if(sameNameOtherPlaceCheck == NO)
            {
                    [self searchQuery];
                    
            }
            else
            {
                [_placeTableView setFrame:CGRectMake(0, _tableY - 37, 320, self.view.frame.size.height - (_tableY - 37))];
            }
            
        }
            break;
        case topSelectedType_address:
        {
            switch (_addressType) {
                case addressSearchType_old:
                {
                    currentPage = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"CurrentPageAddress"] intValue];
                    totalPage = 1 + (int)(([[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountAddress"] intValue]-1)/15);
                }
                    break;
                case addressSearchType_new:
                {
                    currentPage = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"CurrentPageNewAddress"] intValue];
                    totalPage = 1 + (int)(([[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountNewAddress"] intValue]-1)/15);
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case topSelectedType_public:
        {
            switch (_commonRadioType) {
                case commonRadioButtonType_busStation:
                {
                    currentPage = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"CurrentPagePublicBusStation"] intValue];
                    totalPage = 1 + (int)((countPublicBs-1)/15);
                }
                    break;
                case commonRadioButtonType_busNumber:
                {
                    currentPage = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"CurrentPagePublicBusNumber"] intValue];
                    totalPage = 1 + (int)((countPublicBn-1)/15);
                }
                    break;
                case commonRadioButtonType_subWay:
                {
                    currentPage = 1;
                    totalPage = 1;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    _page = currentPage;
    
    
    // 페이징 처리 (라벨)
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    _pageLabel.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:currentPage+1]];
    
    _totalPageLabel.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:totalPage]];
    
    _prevBtn.enabled = (_page > 0) ? YES : NO;
    _nextBtn.enabled = (_page < totalPage-1) ? YES : NO;
    
    
    
    // 뭔가 검색 되었다면
    if(_topType == topSelectedType_place && countPlace > 15)
    {
        self.placeTableView.tableFooterView = nil;
        self.placeTableView.tableFooterView = _bottomView;
        [_placeTableView setContentOffset:CGPointMake(0, 0) animated:NO];
        //[_searchList scrollsToTop];
    }
    else if ((_topType == topSelectedType_address && [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountAddress"] intValue] > 15) || (_topType == topSelectedType_address && [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountNewAddress"] intValue] > 15))
    {
        if(_addressType == addressSearchType_All)
        {
            self.addressTableView.tableFooterView = nil;
            return;
        }
        
        else if(_addressType == addressSearchType_old)
        {
            if([[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountAddress"] intValue] <= 15)
            {
                self.addressTableView.tableFooterView = nil;
                return;
            }
        }
        
        else if(_addressType == addressSearchType_new)
        {
            if([[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountNewAddress"] intValue] <= 15)
            {
                self.addressTableView.tableFooterView = nil;
                return;
            }
        }
        
        self.addressTableView.tableFooterView = nil;
        self.addressTableView.tableFooterView = _bottomView;
        [_addressTableView setContentOffset:CGPointMake(0, 0) animated:NO];
        //[_jusoList scrollsToTop];
    }
    else if (_topType == topSelectedType_public && _commonRadioType == commonRadioButtonType_busStation && countPublicBs > 15)
    {
        self.busStationTableView.tableFooterView = nil;
        self.busStationTableView.tableFooterView = _bottomView;
        [_busStationTableView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    else if (_topType == topSelectedType_public && _commonRadioType == commonRadioButtonType_busNumber && countPublicBn > 15)
    {
        self.busNumTableView.tableFooterView = nil;
        self.busNumTableView.tableFooterView = _bottomView;
        [_busNumTableView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    else if(_addressType == addressSearchType_All)
    {
        self.addressTableView.tableFooterView = nil;
        
        // 강남 맛집 재검색할때 결과가 없는데 페이징뷰가 나와서 추가됨
        if(countPlace < 15)
        {
            self.placeTableView.tableFooterView = nil;
        }
        return;
    }
    // 장소/주소의 토탈페이지가 15가 아니면 페이징버튼뷰 없앰
    else
    {
        NSLog(@"_topType %d, countPlace : %d", _topType,countPlace);
        self.placeTableView.tableFooterView = nil;
    }
    
}

- (void) topViewButtonStringAbled
{
    int countPlace =  [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountPlace"] intValue];
    
    [_placeSearchBtn setTitle:[NSString stringWithFormat:@"장소(%d)", countPlace] forState:UIControlStateNormal];
    
    if(countPlace <= 0)
        [_placeSearchBtn setEnabled:NO];
    else
        [_placeSearchBtn setEnabled:YES];
    
    int oldCount = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountAddress"] intValue];
    int newCount = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountNewAddress"] intValue];
    
    int countAddress = oldCount + newCount;
    
    [_addressSearchBtn setTitle:[NSString stringWithFormat:@"주소(%d)", countAddress] forState:UIControlStateNormal];
    
    if (countAddress <= 0)
        [_addressSearchBtn setEnabled:NO];
    else
    {
        [_addressSearchBtn setEnabled:YES];
        
        if(!_moreChecker)
        {
            if(oldCount > 0 && newCount > 0)
                _addressType = addressSearchType_All;
            else if(newCount <= 0)
                _addressType = addressSearchType_old;
            else if (oldCount <= 0)
                _addressType = addressSearchType_new;
        }
        
    }
    
    int countPublicBs = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountPublicBusStation"] intValue];
    int countPublicBn = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountPublicBusNumber"] intValue];
    int countPublicSs = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountPublicSubwayStation"] intValue];
    int countPublic = countPublicBs + countPublicBn + countPublicSs;
    
    [_publicSearchBtn setTitle:[NSString stringWithFormat:@"버스/지하철(%d)", countPublic] forState:UIControlStateNormal];
    
    if (countPublic <= 0)
    {
        [_publicSearchBtn setEnabled:NO];
    }
    else
    {
        if (countPublicBs <= 0)
            [_busStationSearchBtn setEnabled:NO];
        else
            [_busStationSearchBtn setEnabled:YES];
        
        if (countPublicBn <= 0)
            [_busNumSearchBtn setEnabled:NO];
        else
            [_busNumSearchBtn setEnabled:YES];
        
        if (countPublicSs <= 0)
            [_subwaySearchBtn setEnabled:NO];
        else
            [_subwaySearchBtn setEnabled:YES];
    }
}
- (void) reloadNshowElsehiddenn :(OMTableView *)tb
{
    NSArray *arr = [NSArray arrayWithObjects:self.placeTableView, self.addressTableView, self.busStationTableView, self.busNumTableView, self.subwayTableView, nil];
    
    for (OMTableView *table in arr)
    {
        if([table isEqual:tb])
        {
            [self showNReload:table];
        }
        else
        {
            [self hiddenTable:table];
        }
    }
    
}
- (int) radioSelecting :(int)bs :(int)bn :(int)ss
{
    if(bs > 0)
        return commonRadioButtonType_busStation;
    else
    {
        if(bn > 0)
            return commonRadioButtonType_busNumber;
        
        else
            return commonRadioButtonType_subWay;
    }
}
- (void) searchFail
{
    switch (_commonRadioType)
    {
            
        case commonRadioButtonType_accuracy:
            [self accuracyChecked:YES];
            break;
        case commonRadioButtonType_distance:
            [self distaceChecked:YES];
            break;
        case commonRadioButtonType_busStation:
            [self busStationChecked:YES];
            break;
        case commonRadioButtonType_busNumber:
            [self busNumberChecked:YES];
            break;
        case commonRadioButtonType_subWay:
            [self subWayChecked:YES];
            break;
        default:
            break;
    }
}
- (void) searchSuccess
{
    switch (_topType)
    {
        case topSelectedType_place:
        {
            [_multiMapBtn setEnabled:YES];
            [self placeChecked];
            [self reloadNshowElsehiddenn:_placeTableView];
        }
            break;
        case topSelectedType_address:
        {
            switch (_addressType)
            {
                case addressSearchType_All:
                    [_multiMapBtn setEnabled:NO];
                    break;
                default:
                    [_multiMapBtn setEnabled:YES];
                    break;
            }
            [self addressChecked];
            [self reloadNshowElsehiddenn:_addressTableView];
        }
            break;
        case topSelectedType_public:
            [_multiMapBtn setEnabled:YES];
            [self publicChecked];
            break;
        default:
            break;
    }
    
    [_placeNAddressView setHidden:NO];
    [_publicView setHidden:YES];
    
    switch (_commonRadioType)
    {
        case commonRadioButtonType_accuracy:
            [self accuracyChecked:YES];
            break;
        case commonRadioButtonType_distance:
            [self distaceChecked:YES];
            break;
        default:
        {
            [_placeNAddressView setHidden:YES];
            [_publicView setHidden:NO];
            
            switch (_commonRadioType)
            {
                case commonRadioButtonType_busStation:
                    [self busStationChecked:YES];
                    [self reloadNshowElsehiddenn:_busStationTableView];
                    break;
                case commonRadioButtonType_busNumber:
                    [_multiMapBtn setEnabled:NO];
                    [self busNumberChecked:YES];
                    [self reloadNshowElsehiddenn:_busNumTableView];
                    break;
                case commonRadioButtonType_subWay:
                    [self subWayChecked:YES];
                    [self reloadNshowElsehiddenn:_subwayTableView];
                    break;
                default:
                    break;
            }
            
        }
            break;
    }
    
    // 저장된 버튼을 will에 넣어야됨 검색할때 버튼 하나로만 되기때문에
    int savingType = _topType;
    _topWillType = savingType;
    
    
    int savingCommonRadioType = _commonRadioType;
    _commonRadioWillType = savingCommonRadioType;
    
    [self topViewButtonDisableColor];
    //    [self renderTableView];
    
}
- (void) topViewButtonDisableColor
{
    // 검색 결과 카운트
    int countPlace, countAddress, countPublicBs, countPublicBn, countPublicSs, countPublic;
    
    countPlace =  [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountPlace"] intValue];
    countAddress = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountAddress"] intValue] + [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountNewAddress"] intValue];
    countPublicBs = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountPublicBusStation"] intValue];
    countPublicBn = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountPublicBusNumber"] intValue];
    countPublicSs = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountPublicSubwayStation"] intValue];
    countPublic = countPublicBs + countPublicBn + countPublicSs;
    
    if(countPlace <= 0)
    {
        [_placeSearchBtn setTitleColor:convertHexToDecimalRGBA(@"8b", @"8b", @"8b", 1) forState:UIControlStateNormal];
    }
    if(countAddress <= 0)
        [_addressSearchBtn setTitleColor:convertHexToDecimalRGBA(@"8b", @"8b", @"8b", 1) forState:UIControlStateNormal];
    if(countPublic <= 0)
        [_publicSearchBtn setTitleColor:convertHexToDecimalRGBA(@"8b", @"8b", @"8b", 1) forState:UIControlStateNormal];
    if(countPublicBn <= 0)
        [_busNumSearchLbl setTextColor:convertHexToDecimalRGBA(@"8b", @"8b", @"8b", 1)];
    if(countPublicBs <= 0)
        [_busStationSearchLbl setTextColor:convertHexToDecimalRGBA(@"8b", @"8b", @"8b", 1)];
    if(countPublicSs <= 0)
        [_subwaySearchLbl setTextColor:convertHexToDecimalRGBA(@"8b", @"8b", @"8b", 1)];
}
- (void) placeChecked
{
    [_topViewBackground setImage:[UIImage imageNamed:@"3tab_01.png"]];
    [_placeSearchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_placeSearchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [_addressSearchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_addressSearchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_publicSearchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_publicSearchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}
-(void) drawAddressPreView
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    //NSLog(@"서치로칼딕 : %@", oms.searchLocalDictionary);
    
    int oldAddCount = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountAddress"] intValue];
    int newAddCount = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountNewAddress"] intValue];
    
    _addressTopBottomType = addressTopSection;
    
    if(_moreChecker)
        return;
    else
    {
        if(oldAddCount == 0)
        {
            // 새주소로 바로 감
            _addressType = addressSearchType_new;
        }
        else if (newAddCount == 0)
        {
            // 구주소로 바로 감
            _addressType = addressSearchType_old;
        }
        else
        {
            _addressType = addressSearchType_All;
        }
    }
}
- (void) addressChecked
{
    [self drawAddressPreView];
    
    [_topViewBackground setImage:[UIImage imageNamed:@"3tab_02.png"]];
    [_placeSearchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_placeSearchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_addressSearchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_addressSearchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [_publicSearchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_publicSearchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}
- (void) showNReload:(OMTableView *)table
{
    [table setHidden:NO];
    [table reloadData];
}
- (void) hiddenTable:(OMTableView *)table
{
    [table setHidden:YES];
}
- (void) publicChecked
{
    [_topViewBackground setImage:[UIImage imageNamed:@"3tab_03.png"]];
    [_placeSearchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_placeSearchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_addressSearchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_addressSearchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_publicSearchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_publicSearchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    
}
- (NSString *) radioOnImgString:(BOOL)boolean
{
    NSString *imgStr = nil;
    
    if(boolean)
        imgStr = [NSString stringWithFormat:@"radio_btn_on.png"];
    else
        imgStr = [NSString stringWithFormat:@"radio_btn_off.png"];
    
    return imgStr;
}
- (void) nullCheckImage
{
    [_accuracyImg setImage:[UIImage imageNamed:@"radio_btn_off.png"]];
    [_distanceImg setImage:[UIImage imageNamed:@"radio_btn_off.png"]];
    [_busStationImg setImage:[UIImage imageNamed:@"radio_btn_off.png"]];
    [_busNumImg setImage:[UIImage imageNamed:@"radio_btn_off.png"]];
    [_subwayImg setImage:[UIImage imageNamed:@"radio_btn_off.png"]];
}
- (void) accuracyChecked:(BOOL)onState
{
    [_accuracyImg setImage:[UIImage imageNamed:[self radioOnImgString:onState]]];
    [_distanceImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
    [_busStationImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
    [_busNumImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
    [_subwayImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
}
- (void) distaceChecked:(BOOL)onState
{
    [_accuracyImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
    [_distanceImg setImage:[UIImage imageNamed:[self radioOnImgString:onState]]];
    [_busStationImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
    [_busNumImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
    [_subwayImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
}
- (void) busStationChecked:(BOOL)onState
{
    [_accuracyImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
    [_distanceImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
    [_busStationImg setImage:[UIImage imageNamed:[self radioOnImgString:onState]]];
    [_busNumImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
    [_subwayImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
}
- (void) busNumberChecked:(BOOL)onState
{
    [_accuracyImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
    [_distanceImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
    [_busStationImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
    [_busNumImg setImage:[UIImage imageNamed:[self radioOnImgString:onState]]];
    [_subwayImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
}
- (void) subWayChecked:(BOOL)onState
{
    [_accuracyImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
    [_distanceImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
    [_busStationImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
    [_busNumImg setImage:[UIImage imageNamed:[self radioOnImgString:!onState]]];
    [_subwayImg setImage:[UIImage imageNamed:[self radioOnImgString:onState]]];
}
#pragma mark -
#pragma mark - 버튼액션



- (IBAction)voiceBtnClick:(id)sender
{
    // 음성검색더보기 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/local_search/voice_search_more"];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 음성인식 키워드 선택 팝업 초기화
    for (UIView *subview in _vwVoiceKeywordSelectorContainer.subviews)
    {
        [subview removeFromSuperview];
    }
    [_vwVoiceKeywordSelectorContainer removeFromSuperview];
    
    // 팝업 뷰 생성
    UIView *vwVoiceKeywordSelector = [[UIView alloc] initWithFrame:CGRectMake(116/2, 184/2, 410/2, 588/2)];
    
    // 팝업 뷰 배경
    UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_bg.png"]];
    [imgvwBack setFrame:CGRectMake(0, 0, 410/2, 588/2)];
    [vwVoiceKeywordSelector addSubview:imgvwBack];
  
    
    // 타이틀 렌더링
    {
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 410/2, 62/2)];
        
        UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(4/2 + 20/2, 16/2, 310/2, 16)];
        [titleLbl setFont:[UIFont systemFontOfSize:16]];
        [titleLbl setText:@"음성검색 결과"];
        [titleLbl setTextColor:convertHexToDecimalRGBA(@"ff", @"51", @"5e", 1.0)];
        [titleView addSubview:titleLbl];
   
        
        UIButton *titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(4/2 + 348/2, 10/2, 40/2, 40/2)];
        [titleBtn setImage:[UIImage imageNamed:@"btn_close.png"] forState:UIControlStateNormal];
        [titleView addSubview:titleBtn];
        [titleBtn addTarget:self action:@selector(closeClick:) forControlEvents:UIControlEventTouchUpInside];
   
        
        UIImageView *titleUnderLine = [[UIImageView alloc] initWithFrame:CGRectMake(4/2, 60/2, 402/2, 2/2)];
        [titleUnderLine setImage:[UIImage imageNamed:@"popup_title_line.png"]];
        [titleView addSubview:titleUnderLine];
 
        
        [vwVoiceKeywordSelector addSubview:titleView];
    
    }
    
    // 상단 안내문구 배경
    UIView *questionBg = [[UIView alloc] initWithFrame:CGRectMake(4/2, 62/2, 402/2, 126/2)];
    [questionBg setBackgroundColor:convertHexToDecimalRGBA(@"d8", @"d8", @"d8", 1.0)];
    [vwVoiceKeywordSelector addSubview:questionBg];
   
    
    // 상단 안내문구
    CGRect rectQuestionLabel = CGRectMake(4/2 + 20/2, 62/2 + 30/2, 370/2, 126/2 - 30/2); // 최대넓이  226 = 256-15-15
    UILabel *lblQuestion = [[UILabel alloc] initWithFrame:rectQuestionLabel];
    [lblQuestion setBackgroundColor:[UIColor clearColor]];
    [lblQuestion setFont:[UIFont boldSystemFontOfSize:15]];
    [lblQuestion setLineBreakMode:NSLineBreakByClipping];
    [lblQuestion setTextColor:[UIColor blackColor]];
    [lblQuestion setTextAlignment:NSTextAlignmentLeft];
    [lblQuestion setNumberOfLines:999];
    [lblQuestion setText:[NSString stringWithFormat:@"%@ %@", oms.keyword, NSLocalizedString(@"Body_VoiceSearch_OtherKeyword_Question", @"")]];
    
    rectQuestionLabel.size = [lblQuestion.text sizeWithFont:lblQuestion.font constrainedToSize:CGSizeMake(370/2, FLT_MAX) lineBreakMode:lblQuestion.lineBreakMode];
    rectQuestionLabel.origin.x = (390/2 - rectQuestionLabel.size.width) / 2;
    
    if (rectQuestionLabel.origin.x < 9)
        rectQuestionLabel.origin.x = 9;
    
    [lblQuestion setFrame:rectQuestionLabel];
    [vwVoiceKeywordSelector addSubview:lblQuestion];
    
    // 상단 안내문구 키워드 컬러링
    CGRect rectQuestionColorLabel = rectQuestionLabel;
    UILabel *lblQuestionColorKeywrod = [[UILabel alloc] initWithFrame:rectQuestionColorLabel];
    [lblQuestionColorKeywrod setFont:[UIFont boldSystemFontOfSize:15]];
    [lblQuestionColorKeywrod setTextColor:convertHexToDecimalRGBA(@"F2", @"34", @"71", 1.0f)];
    [lblQuestionColorKeywrod setBackgroundColor:[UIColor clearColor]];
    [lblQuestionColorKeywrod setTextAlignment:NSTextAlignmentLeft];
    [lblQuestionColorKeywrod setNumberOfLines:999];
    [lblQuestionColorKeywrod setText:oms.keyword];
    rectQuestionColorLabel.size = [lblQuestionColorKeywrod.text sizeWithFont:lblQuestionColorKeywrod.font constrainedToSize:CGSizeMake(402/2, FLT_MAX) lineBreakMode:lblQuestionColorKeywrod.lineBreakMode];
    [lblQuestionColorKeywrod setFrame:rectQuestionColorLabel];
    [vwVoiceKeywordSelector addSubview:lblQuestionColorKeywrod];
    
    // 키워드 리스트 스크롤뷰
    CGRect rectKeywordList = CGRectMake(0, 0, 0, 0);
    OMScrollView *svwKeywordList = [[OMScrollView alloc] initWithFrame:rectKeywordList];
    [svwKeywordList setDelegate:self];
    [svwKeywordList setScrollType:2];
    
    rectKeywordList.origin.x = 4/2;
    rectKeywordList.size.width = 402/2;
    rectKeywordList.origin.y = rectQuestionLabel.origin.y + rectQuestionLabel.size.height + 11;
    rectKeywordList.size.height = 90/2 + 4/2 + 90/2 + 4/2 + 90/2 + 4/2;
    //279 /*하단버튼높이*/ - 11 /*하단여백*/ - rectKeywordList.origin.y;
    [svwKeywordList setFrame:rectKeywordList];
    
    float keywordListContentHeight = 0;
    
    // 키워드 첫번째 라인 삽입
    {
        UIImageView *vwLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, keywordListContentHeight, rectKeywordList.size.width, 4/2)];
        [vwLine setImage:[UIImage imageNamed:@"popup_list_line.png"]];
        [svwKeywordList addSubview:vwLine];
        keywordListContentHeight += 2;
    }
    // 키워드 목록 삽입
    for (int  cnt=0, maxcnt=oms.voiceSearchArray.count; cnt<maxcnt; cnt++)
    {
        NSString *keyword = [oms.voiceSearchArray objectAtIndexGC:cnt];
        
        // 셀 생성
        UIControl *vwCell = [[UIControl alloc] initWithFrame:CGRectMake(0, keywordListContentHeight, rectKeywordList.size.width, 90/2)];
        [vwCell setBackgroundColor:convertHexToDecimalRGBA(@"f4", @"f4", @"f4", 1.0)];
        
        // 이벤트 처리
        [vwCell setTag:cnt];
        if ([oms.keyword isEqualToString:keyword])
            [vwCell setBackgroundColor:convertHexToDecimalRGBA(@"f4", @"f4", @"f4", 1.0f)];
        else
        {
            [vwCell addTarget:self action:@selector(searchVoiceKeyword:) forControlEvents:UIControlEventTouchUpInside];
            [vwCell addTarget:self action:@selector(onVoiceKeywordCell_Down:) forControlEvents:UIControlEventTouchDown];
            [vwCell addTarget:self action:@selector(onVoiceKeywordCell_Up:) forControlEvents:UIControlEventTouchUpOutside];
        }
        
        // 키워드 라벨 생성 / 삽입
        UILabel *lblKeyword = [[UILabel alloc] initWithFrame:CGRectMake(20/2, 30/2, rectKeywordList.size.width-15-15, 30/2)];
        [lblKeyword setFont:[UIFont systemFontOfSize:15]];
        [lblKeyword setBackgroundColor:[UIColor clearColor]];
        [lblKeyword setText:keyword];
        [vwCell addSubview:lblKeyword];
        
        // 셀 삽입
        [svwKeywordList addSubview:vwCell];
        keywordListContentHeight += vwCell.frame.size.height;
        
        UIImageView *vwLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, keywordListContentHeight, rectKeywordList.size.width, 4/2)];
        [vwLine setImage:[UIImage imageNamed:@"popup_list_line.png"]];
        [svwKeywordList addSubview:vwLine];
  
        
        keywordListContentHeight += 2;
    }
    
    // 키워드 리스트 스크롤 컨텐츠 사이즈
    [svwKeywordList setContentSize:CGSizeMake(rectKeywordList.size.width, keywordListContentHeight)];
    
    // 키워드 리스트 스크롤뷰 삽입
    [vwVoiceKeywordSelector addSubview:svwKeywordList];

    
    // 재검색 버튼
    UIButton *btnReRecord = [[UIButton  alloc] initWithFrame:CGRectMake(24/2, 496/2, 176/2, 64/2)];
    [btnReRecord setImage:[UIImage imageNamed:@"popup_again_btn_pressed.png"] forState:UIControlStateNormal];
    [btnReRecord addTarget:self action:@selector(reRecognize:) forControlEvents:UIControlEventTouchUpInside];
    [vwVoiceKeywordSelector addSubview:btnReRecord];

    
    // 닫기 버튼
    UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(210/2, 496/2, 176/2, 64/2)];
    [btnClose setImage:[UIImage imageNamed:@"popup_btn_cancel_default.png"] forState:UIControlStateNormal];
    [btnClose setImage:[UIImage imageNamed:@"popup_btn_cancel_pressed.png"] forState:UIControlStateHighlighted];
    [btnClose addTarget:self action:@selector(closeClick:) forControlEvents:UIControlEventTouchUpInside];
    [vwVoiceKeywordSelector addSubview:btnClose];

    
    // 팝업 뷰 삽입
    [_vwVoiceKeywordSelectorContainer addSubview:vwVoiceKeywordSelector];

    
    // 음성인식 키워드 선택 팝업 삽입
    [self.view addSubview:_vwVoiceKeywordSelectorContainer];
}
- (IBAction)topViewSelect:(id)sender
{
    int resultTopType = (int)[(UIButton *)sender tag];
    
    _topWillType = resultTopType;
    
    if(_topWillType == topWillSelectType_public)
    {
        // 0개인 카운터는 선택못하게끔 빈화면 안보여주려고 세팅값바꿈
        int countPublicBs = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountPublicBusStation"] intValue];
        int countPublicBn = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountPublicBusNumber"] intValue];
        int countPublicSs = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"TotalCountPublicSubwayStation"] intValue];
        
        _commonRadioWillType = [self radioSelecting:countPublicBs :countPublicBn :countPublicSs];
    }
    else
    {
        _commonRadioWillType = commonRadioWillButtonType_accuracy;
        

            willBaseOption = 1;
            baseOption = 1;
    }
    
    _moreChecker = NO;
    
    [self search:0 option:baseOption];
}
- (IBAction)middleBtnClick:(id)sender
{
    int trafficRadioType = (int)((UIButton *)sender).tag;
    
    // 13 버정 14 버노 15 지하철
    _commonRadioWillType = trafficRadioType;
    
    [self search:0 option:baseOption];
}
- (IBAction)distanceBtnSelect:(id)sender
{
    [self distaceChecked:YES];
}

- (IBAction)correctBtnSelect:(id)sender
{
    [self accuracyChecked:YES];
}

- (IBAction)busStationBtnSelect:(id)sender
{
    [self busStationChecked:YES];
}

- (IBAction)busNumberBtnSelect:(id)sender
{
    [self busNumberChecked:YES];
}

- (IBAction)subwayBtnSelect:(id)sender
{
    [self subWayChecked:YES];
}
// 하이라이트 캔슬
- (IBAction)radioHightlightCancel:(id)sender
{
    [self searchFail];
}
- (IBAction)mapOrMyBtnClick:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"" delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:@"지도 화면 중심" otherButtonTitles:@"내 위치 중심", nil];
    
    // 2번째 인덱스는 빨간색으로 표시
    actionSheet.destructiveButtonIndex = 2;
    [actionSheet setTag:0];
    [actionSheet showInView:[self view]];
    
}

- (IBAction)reSearchQuery:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *searchType = [[oms.searchLocalDictionary objectForKeyGC:@"SearchType"] objectForKeyGC:@"orgType"];
    
    NSString *mylocationStr = [NSString stringWithFormat:@"현재위치 근처 %@", self.searchKeyword];
    NSString *locationNearStr = nil;
 
    if([(NSMutableDictionary *)[oms.searchLocalDictionary objectForKeyGC:@"SearchType"] count] >= 1)
    {
    if([searchType isEqualToString:@"A"] || [searchType isEqualToString:@"B"] || [searchType isEqualToString:@"G"])
    {
        locationNearStr = [NSString stringWithFormat:@"%@ 근처 장소", oms.keyword];
    }
    else if([searchType isEqualToString:@"C"] || [searchType isEqualToString:@"D"] || [searchType isEqualToString:@"E"])
    {
        locationNearStr = [NSString stringWithFormat:@"%@ 근처 %@", [oms poiQueryReturn], [oms r_QueryReturn]];
    }
    
    NSString *oldAddressStr =  nil;
    
    if([searchType isEqualToString:@"B"])
    {
        oldAddressStr = [NSString stringWithFormat:@"지번주소 %@ 근처 장소", [oms poiQueryReturn]];
    }
    else if ([searchType isEqualToString:@"D"])
    {
        oldAddressStr = [NSString stringWithFormat:@"지번주소 %@ 근처 %@", [oms poiQueryReturn], [oms r_QueryReturn]];
    }
    
    UIActionSheet *actionSheet = nil;
    
    // ver3 수정사항 : 구주소 갯수가 1개 이상이어야 옵션3으로 검색가능
    int oldAddCount = (int)[(NSMutableDictionary *)[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataAddress"] count];
    
    //NSLog(@"힝 %@", [OllehMapStatus sharedOllehMapStatus].searchLocalDictionary);
    
    if(([searchType isEqualToString:@"B"] || [searchType isEqualToString:@"D"]) && oldAddCount > 1)
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:locationNearStr  otherButtonTitles:mylocationStr, oldAddressStr, nil];
        [actionSheet setTag:2];
        
        actionSheet.destructiveButtonIndex = baseOption-1;
    }
    else
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:locationNearStr otherButtonTitles:mylocationStr , nil];
        [actionSheet setTag:1];
        
        if([oms reSearchException])
            actionSheet.destructiveButtonIndex = baseOption-1;
        else
        {
            if(baseOption == 1)
                actionSheet.destructiveButtonIndex = 1;
            else if(baseOption == 2)
                actionSheet.destructiveButtonIndex = 0;
        }
        
        
    }
    
    
    
    [actionSheet showInView:[self view]];
    
    }
    // 답없다
    else
    {
        searchType = [[_prevMutableDictionary objectForKeyGC:@"SearchType"] objectForKeyGC:@"orgType"];
        
        if([searchType isEqualToString:@"A"] || [searchType isEqualToString:@"B"] || [searchType isEqualToString:@"G"])
        {
            locationNearStr = [NSString stringWithFormat:@"%@ 근처 장소", oms.keyword];
        }
        else if([searchType isEqualToString:@"C"] || [searchType isEqualToString:@"D"] || [searchType isEqualToString:@"E"])
        {
            locationNearStr = [NSString stringWithFormat:@"%@ 근처 %@", [self prevPOIQueryReturn], [self prevR_QueryReturn]];
        }
        else
        {
            locationNearStr = @"이전이 없을수가없지";
        }
        
        NSString *oldAddressStr =  nil;
        
        if([searchType isEqualToString:@"B"])
        {
            oldAddressStr = [NSString stringWithFormat:@"지번주소 %@ 근처 장소", [self prevPOIQueryReturn]];
        }
        else if ([searchType isEqualToString:@"D"])
        {
            oldAddressStr = [NSString stringWithFormat:@"지번주소 %@ 근처 %@", [self prevPOIQueryReturn], [self prevR_QueryReturn]];
        }
        
        UIActionSheet *actionSheet = nil;
        
        // ver3 수정사항 : 구주소 갯수가 1개 이상이어야 옵션3으로 검색가능
        int oldAddCount = (int)[(NSMutableDictionary *)[_prevMutableDictionary objectForKeyGC:@"DataAddress"] count];
        
        //NSLog(@"힝 %@", [OllehMapStatus sharedOllehMapStatus].searchLocalDictionary);
        
        if(([searchType isEqualToString:@"B"] || [searchType isEqualToString:@"D"]) && oldAddCount > 1)
        {
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:locationNearStr  otherButtonTitles:mylocationStr, oldAddressStr, nil];
            [actionSheet setTag:2];
            
            actionSheet.destructiveButtonIndex = baseOption-1;
        }
        else
        {
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:locationNearStr otherButtonTitles:mylocationStr , nil];
            [actionSheet setTag:1];
            
            if([self PrevReSearchException])
                actionSheet.destructiveButtonIndex = baseOption-1;
            else
            {
                if(baseOption == 1)
                    actionSheet.destructiveButtonIndex = 1;
                else if(baseOption == 2)
                    actionSheet.destructiveButtonIndex = 0;
            }
            
            
        }
        
        
        
        [actionSheet showInView:[self view]];
    }

}


- (IBAction)popBtnClick:(id)sender
{
    // 검색결과에서는 어떤 조건에서도 무조건 가장 마지막 검색창이 나와야 한다.
    OMNavigationController *nc = [OMNavigationController sharedNavigationController];
    for (int i=(int)nc.viewControllers.count-1; i>=0; i--)
    {
        UIViewController *vc = [nc.viewControllers objectAtIndexGC:i];
        if ([vc isKindOfClass:[SearchViewController class]])
        {
            [nc popToViewController:vc animated:NO];
            return;
        }
        else if([vc isKindOfClass:[MainViewController class]])
        {
            [nc popToRootViewControllerAnimated:NO];
            return;
        }
    }
    
    // 음성검색에서 넘어왔을 경우에는 2단계 뒤로 이동한다. (음성검색화면 보이지 않게)
    switch (_currentSearchTargetType)
    {
        case SearchTargetType_VOICENONE:
        case SearchTargetType_VOICESTART:
        case SearchTargetType_VOICEVISIT:
        case SearchTargetType_VOICEDEST:
        {
            OMNavigationController *nc = [OMNavigationController sharedNavigationController];
            [nc popToViewController:[nc.viewControllers objectAtIndexGC:nc.viewControllers.count-3] animated:NO];
        }
            break;
            
        default:
        {
            [[OMNavigationController sharedNavigationController] popViewControllerAnimated:YES];
        }
            break;
    }
    
}
#pragma mark -
#pragma mark Table Data Source Methods
// Row 의 총 갯수 출력
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    // 장소버튼일떄는 장소의현재페이지갯수
    if ([tableView isKindOfClass:[UIPlaceTableView class]])
    {
        count = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"CurrentCountPlace"] intValue];
        
        //NSLog(@"장소결과 갯수 : %d", count);
    }
    // 주소버튼일때는 주소의현재페이지갯수
    else if ([tableView isKindOfClass:[UIAddressTableView class]])
    {
        if(_addressType == addressSearchType_old)
        {
            count = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"CurrentCountAddress"] intValue];
        }
        
        else if (_addressType == addressSearchType_new)
        {
            count = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"CurrentCountNewAddress"] intValue];
        }
        else if (_addressType == addressSearchType_All)
        {
            OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
            
            int oldAddCount = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountAddress"] intValue];
            int newAddCount = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountNewAddress"] intValue];
            
            if(oldAddCount > 2)
            {
                oldAddCount = 3;
            }
            
            if(newAddCount > 2)
            {
                newAddCount = 3;
            }
            
            if(section != 0)
            {
                count = oldAddCount;
            }
            else
            {
                count = newAddCount;
            }
            
        }
        
        //NSLog(@"주소결과 갯수 : %d", count);
    }
    // 버스/지하철일때는
    else if([tableView isKindOfClass:[UIBusStationTableView class]])
    {
        // 버스정류장일때는
        count = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"CurrentCountPublicBusStation"] intValue];
        
        //NSLog(@"버정결과 갯수 : %d", count);
        
    }
    // 버스노선일때
    else if ([tableView isKindOfClass:[UIBusNumberTableView class]])
    {
        count = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"CurrentCountPublicBusNumber"] intValue];
        
        //NSLog(@"노선결과 갯수 : %d", count);
    }
    // 지하철일때
    else if([tableView isKindOfClass:[UISubwayTableView class]])
    {
        count = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"CurrentCountPublicSubwayStation"] intValue];
        
        //NSLog(@"지하철 갯수 : %d", count);
    }
    // 같은이름다른지역 갯수
    else if ([tableView isKindOfClass:[UIResearchTableView class]])
    {
        
        
        if( (nPage * maxPage ) < _sameNameOtherPlaceCount ) {
            //self.btnMore.enabled = TRUE;
            _moreView.hidden = FALSE;
            
            count = ((int)nPage * maxPage);
            
        }
        else
        {
            _moreView.hidden = TRUE;
            count = _sameNameOtherPlaceCount;
        }
        
        //count = _sameNameOtherPlaceCount;
    }
    
    return count;
}
// 섹션헤더 커스텀
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if([tableView isKindOfClass:[UIAddressTableView class]] && _addressType == addressSearchType_All)
    {
        if(section == 0)
        {
            UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 25.0)];
            [customView setBackgroundColor:convertHexToDecimalRGBA(@"ed", @"ed", @"ed", 1)];
            
            // create the button object
            UILabel *headerLabel = [[UILabel alloc] init];
            headerLabel.backgroundColor = [UIColor clearColor];
            headerLabel.font = [UIFont boldSystemFontOfSize:13];
            headerLabel.frame = CGRectMake(10, 6, 100, 13);
            headerLabel.text = @"도로명주소"; // i.e. array element
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(258, 0, 62, 25)];
            [btn addTarget:self action:@selector(newAddressBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *moreLbl = [[UILabel alloc] init];
            [moreLbl setBackgroundColor:[UIColor clearColor]];
            [moreLbl setText:@"더보기"];
            [moreLbl setTextAlignment:NSTextAlignmentRight];
            [moreLbl setFont:[UIFont systemFontOfSize:12]];
            [moreLbl setTextColor:convertHexToDecimalRGBA(@"8b", @"8b", @"8b", 1)];
            [moreLbl setFrame:CGRectMake(258, 7, 41, 12)];
            
            
            
            UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_btn_arrow_01.png"]];
            [arrow setFrame:CGRectMake(299, 0, 21, 25)];
            
            [customView addSubview:headerLabel];
            [customView addSubview:btn];
            [customView addSubview:moreLbl];
            [customView addSubview:arrow];
            
            return customView;
        }
        else
        {
            UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 25.0)];
            [customView setBackgroundColor:convertHexToDecimalRGBA(@"ed", @"ed", @"ed", 1)];
            
            // create the button object
            UILabel *headerLabel = [[UILabel alloc] init];
            headerLabel.backgroundColor = [UIColor clearColor];
            headerLabel.font = [UIFont boldSystemFontOfSize:13];
            headerLabel.frame = CGRectMake(10, 6, 100, 13);
            headerLabel.text = @"지번주소"; // i.e. array element
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(258, 0, 62, 25)];
            [btn addTarget:self action:@selector(oldAddressBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *moreLbl = [[UILabel alloc] init];
            [moreLbl setText:@"더보기"];
            [moreLbl setTextAlignment:NSTextAlignmentRight];
            [moreLbl setBackgroundColor:[UIColor clearColor]];
            [moreLbl setFont:[UIFont systemFontOfSize:12]];
            [moreLbl setTextColor:convertHexToDecimalRGBA(@"8b", @"8b", @"8b", 1)];
            [moreLbl setFrame:CGRectMake(258, 7, 41, 12)];
            
            UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_btn_arrow_01.png"]];
            [arrow setFrame:CGRectMake(299, 0, 21, 25)];
            
            [customView addSubview:headerLabel];
            [customView addSubview:btn];
            [customView addSubview:moreLbl];
            [customView addSubview:arrow];
            
            return customView;
        }
        
    }
    else
    {
        return nil;
    }
}
// 섹션헤더 높이
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([tableView isKindOfClass:[UIAddressTableView class]] && _addressType == addressSearchType_All)
        return 25.0;
    else
    {
        return 0;
    }
}
// 테이블View의 셀  높이 조절 Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSUInteger section = [indexPath section];
    
    if([tableView isKindOfClass:[UIPlaceTableView class]])
    {
        if(indexPath.row == _localIndex)
            return 132;
        else
            return 75;
    }
    else if ([tableView isKindOfClass:[UIAddressTableView class]])
    {
        NSLog(@"indexPath.row: %d, _addressIndex: %d ,indexPath.section: %d ,sectionType: %d", (int)indexPath.row, _addressIndex, (int)indexPath.section, _addressTopBottomType);
        if(indexPath.row == _addressIndex && indexPath.section == _addressTopBottomType)
        {
            return 115;
        }
        else
            return 58;
    }
    else if ([tableView isKindOfClass:[UIBusStationTableView class]])
    {
        if(indexPath.row == _busStationIndex)
            return 115;
        else
            return 58;
    }
    else if ([tableView isKindOfClass:[UIBusNumberTableView class]])
    {
        return 58;
        //_busNumberIndex = indexPath.row;
        //[_searchList reloadRowsAtIndexPaths:[_searchList indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if ([tableView isKindOfClass:[UISubwayTableView class]])
    {
        if(indexPath.row == _subwayIndex)
            return 115;
        else
            return 58;
    }
    else if ([tableView isKindOfClass:[UIResearchTableView class]])
    {
        return 90/2;
    }
    else
    {
        return 0;
    }
}
// 섹션갯수
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([tableView isKindOfClass:[UIAddressTableView class]] && _addressType == addressSearchType_All)
    {
        return 2;
    }
    else
    {
        return 1;
    }
    
}

// 셀을 그린다
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    // 세퍼레이터
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1];
    
    UITableViewCell *cell = nil;

    // 장소!!
    if([tableView isKindOfClass:[UIPlaceTableView class]])
    {
        static NSString *identifier = @"localIdentifier";
        
        LocalCell *cell = (LocalCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if ( cell == nil )
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LocalCell" owner:nil options:nil];
            for (id oneObject in nib)
            {
                if([oneObject isKindOfClass:[LocalCell class]])
                {
                    cell = (LocalCell *)oneObject;
                    
                    break;
                }
                
            }
            
            UIImageView *selectedBackgroundView = [[UIImageView alloc] init];
            [selectedBackgroundView setBackgroundColor:convertHexToDecimalRGBA(@"d9", @"f4", @"ff", 1)];
            cell.selectedBackgroundView = selectedBackgroundView;
            
            
        }
        
        if(indexPath.row == _localIndex)
        {
            [cell.cellBgView setBackgroundColor:convertHexToDecimalRGBA(@"d9", @"f4", @"ff", 1)];
            [cell.localBtnView setHidden:NO];
        }
        else
        {
            //cell.cellBgView.backgroundColor = [UIColor whiteColor];
            [cell.localBtnView setHidden:YES];
            
        }
        
        //[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        NSMutableDictionary *poiDic = [[oms.searchLocalDictionary objectForKeyGC:@"DataPlace"] objectAtIndexGC:indexPath.row];
        
        
        cell.localSinglePOI.tag = indexPath.row;
        
        //NSLog(@"cell.POIStart.tag = %d", cell.POIStart.tag);
        
        //[cell.viewMap setTitle:[rowData objectForKeyGC:@"Name"] forState:UIControlStateDisabled];
        
        [cell.localSinglePOI addTarget:self action:@selector(clickToSinglePOILocal:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *shapeType = stringValueOfDictionary(poiDic, @"SHAPE_TYPE");
        //NSString *rdCd = stringValueOfDictionary(poiDic, @"RD_CD");
        
        if(![shapeType isEqualToString:@""])
        {
            cell.localImg.image = [UIImage imageNamed:@"line_list_b_marker.png"];
            [cell.localStart setTag:indexPath.row + 200];
            [cell.localDest setTag:indexPath.row + 300];
            [cell.localVisit setTag:indexPath.row + 400];
            [cell.localStart setImage:[UIImage imageNamed:@"list_btn_start_disabled.png"] forState:UIControlStateNormal];
            [cell.localDest setImage:[UIImage imageNamed:@"list_btn_stop_disabled.png"] forState:UIControlStateNormal];
            [cell.localVisit setImage:[UIImage imageNamed:@"list_btn_via_disabled.png"] forState:UIControlStateNormal];
            
        }
        else
        {
            cell.localImg.image = [UIImage imageNamed:@"list_b_marker.png"];
        }
        
        cell.localStrImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"list_marker_%d.png", 1 + ((int)indexPath.row % 15)]];
        
        CGRect localStringImgFrame = cell.localStrImg.frame;
        CGPoint localStringImgPoint = CGPointMake(localStringImgFrame.origin.x + 2, localStringImgFrame.origin.y + 2);
        CGSize localStringImgSize = CGSizeMake(13, 14);
        localStringImgFrame.size = localStringImgSize;
        localStringImgFrame.origin = localStringImgPoint;
        [cell.localStrImg setFrame:localStringImgFrame];
        
        //NSLog(@"poi딕 : %@", [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataPlace"]);
        //NSLog(@"인덱스패쓰 : %@, prev인덱스패쓰 : %@", indexPath, _prevIndexPath);
        
        //NSLog(@"Index.row : %d", indexPath.row);
        
        /* 장소 */
        
        cell.localName.text = [poiDic objectForKeyGC:@"NAME"];

        CGSize sizePlaceName = [cell.localName.text sizeWithFont:cell.localName.font];
        [cell.localName setFrame:CGRectMake(41, 11, sizePlaceName.width, 15)];
        
        if(41 + sizePlaceName.width > 253)
        {
            sizePlaceName.width = 253 - 41;
            [cell.localName setFrame:CGRectMake(41, 11, sizePlaceName.width, 15)];
        }
        /* 장소 끝 */
        
        /* 주소 */
        NSString *newAddrString = stringValueOfDictionary(poiDic, @"NEW_ADDR");
        
        NSString *linePOIAddr = stringValueOfDictionary(poiDic, @"URL");
        
        if(![shapeType isEqualToString:@""] && ![linePOIAddr isEqualToString:@""])
        {
            NSString *lineAddrSegment  = [linePOIAddr substringFromIndex:20];
            
            NSArray *kiJongDist = [lineAddrSegment componentsSeparatedByString:@"/"];
            
            cell.localAddress.text = [NSString stringWithFormat:@"%@ ~ %@", [kiJongDist objectAtIndexGC:1], [kiJongDist objectAtIndexGC:2]];
            
            
            CGSize localAddressSize = [cell.localAddress.text sizeWithFont:cell.localAddress.font];
            [cell.localAddress setFrame:CGRectMake(41, 33, localAddressSize.width, 13)];

            UIImageView *segImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_text_line.png"]];
            [segImg setFrame:CGRectMake(41 + localAddressSize.width, 33, 13, 13)];
            [cell addSubview:segImg];
            
            UILabel *dist = [[UILabel alloc] initWithFrame:CGRectMake(41 + localAddressSize.width + 13, 33, 70, 13)];
            [dist setFont:[UIFont systemFontOfSize:13]];
            [dist setTextColor:convertHexToDecimalRGBA(@"8b", @"8b", @"8b", 1.0)];
            [dist setText:[kiJongDist objectAtIndex:3]];
            [cell addSubview:dist];
            
            [cell.localStart setTag:indexPath.row + 200];
            [cell.localDest setTag:indexPath.row + 300];
            [cell.localVisit setTag:indexPath.row + 400];
            
            [cell.localStart setImage:[UIImage imageNamed:@"list_btn_start_disabled.png"] forState:UIControlStateNormal];
            [cell.localDest setImage:[UIImage imageNamed:@"list_btn_stop_disabled.png"] forState:UIControlStateNormal];
            [cell.localVisit setImage:[UIImage imageNamed:@"list_btn_via_disabled.png"] forState:UIControlStateNormal];

        }
        else
        {
        
            if([newAddrString isEqualToString:@""])
            cell.localAddress.text = [poiDic objectForKeyGC:@"B_ADDR"];
            else
            {
                cell.localAddress.text = newAddrString;
            }
            
            }
        
        CGSize sizeAddress = [cell.localAddress.text sizeWithFont:cell.localAddress.font];
        
        [cell.localAddress setFrame:CGRectMake(41, 33, sizeAddress.width, 13)];
        
        if(41 + sizeAddress.width > 253)
        {
            sizeAddress.width = 253 - 41;
            [cell.localAddress setFrame:CGRectMake(41, 33, sizeAddress.width, 15)];
        }
        
        /* 주소 끝 */
        
        /* 거리변환 */
        // 내위치좌표
        //Coord myCrd = [[MapContainer sharedMapContainer_Main].kmap getUserLocation];
        // 지도중심좌표
        //Coord Crd = [[MapContainer sharedMapContainer_Main].kmap centerCoordinate];
        [cell.localDistance setText:[NSString stringWithFormat:@"%@", [self getDistance:poiDic:@"place"]]];
        
        /* 무료통화, left바, 거리, right바, 분류 */
        NSString *freeCalling = @"";
        if( [stringValueOfDictionary(poiDic, @"STHEME_CODE") rangeOfString:@"PG1201000000008"].location != NSNotFound )
            freeCalling = @"PG1201000000008";
        
        //cell.classfication.text = [poiDic objectForKeyGC:@"UJ_NAME"];
        @try {
            NSString *ujName = [poiDic objectForKeyGC:@"UJ_NAME"];
            
            NSArray *ujNameArr = [ujName componentsSeparatedByString:@">"];
            
            NSString *bigSegment;
            NSString *middleSegment;
            
            //NSLog(@"업종명길이 : %d", ujNameArr.count);
            if(ujNameArr.count > 0)
            {
                bigSegment = [ujNameArr objectAtIndexGC:0];
                
                
                cell.localUj.text = [NSString stringWithFormat:@"%@", bigSegment];
                
                if(ujNameArr.count > 1)
                {
                    middleSegment = [ujNameArr objectAtIndexGC:1];
                    
                    if([middleSegment isEqualToString:@""])
                    {
                        cell.localUj.text = [NSString stringWithFormat:@"%@", bigSegment];
                    }
                    else
                        
                    {
                        cell.localUj.text = [NSString stringWithFormat:@"%@ > %@", bigSegment, middleSegment];
                    }
                }
                
                if([cell.localUj.text isEqualToString:@""])
                {
                    [cell.localRightBar setHidden:YES];
                }
                
            }
            else {
                cell.localUj.text = @"";
                
            }
            
        }
        @catch (NSException *exception) {
            cell.localUj.text = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"UJ_NAME"]];
            
        }
        
        //NSLog(@"%@, %d", freeCalling, indexPath.row);
        
        /* 무료통화 있으면 모두출력 */
        if( [freeCalling rangeOfString:@"PG1201000000008"].location != NSNotFound )
            //if([freeCalling isEqualToString:@"PG1201000000008"])
        {
            cell.localFreeCall.hidden = NO;
            
            
            CGSize sizeDistance = [cell.localDistance.text sizeWithFont:cell.localDistance.font];
            CGSize sizeClassification = [cell.localUj.text sizeWithFont:cell.localUj.font];
            
            [cell.localDistance setFrame:CGRectMake(41 + 60 + 13, 50, sizeDistance.width, 13)];
            [cell.localRightBar setFrame:CGRectMake(41 + 60 + 13 + sizeDistance.width, cell.localDistance.frame.origin.y, 13, 13)];
            [cell.localUj setFrame:CGRectMake(41 + 60 + 13 + sizeDistance.width + 13, cell.localDistance.frame.origin.y, sizeClassification.width, 13)];
            
            if(41 + 60 + 13 + sizeDistance.width + 13 + sizeClassification.width > 253)
            {
                sizeClassification.width = 253 - 41 - 60 - 13 - sizeDistance.width - 13;
                [cell.localUj setFrame:CGRectMake(41 + 60 + 13 + sizeDistance.width + 13, cell.localDistance.frame.origin.y, sizeClassification.width, 13)];
            }
            
            
        }
        /* 무료통화 없으면 거리, right바, 분류 출력 */
        else {
            cell.localLeftBar.hidden = YES;
            cell.localFreeCall.hidden = YES;
            
            CGSize sizeDistance = [cell.localDistance.text sizeWithFont:cell.localDistance.font];
            CGSize sizeClassification = [cell.localUj.text sizeWithFont:cell.localUj.font];
            
            [cell.localDistance setFrame:CGRectMake(41, 50, sizeDistance.width, 13)];
            [cell.localRightBar setFrame:CGRectMake(41 + sizeDistance.width, 50, 13, 13)];
            [cell.localUj setFrame:CGRectMake(41 + sizeDistance.width + 13, 50, sizeClassification.width, 13)];
            
            if(41 + sizeDistance.width + 13 + sizeClassification.width > 253)
            {
                sizeClassification.width = 253 - 41 - sizeDistance.width - 13;
                [cell.localUj setFrame:CGRectMake(41 + sizeDistance.width + 13, 50, sizeClassification.width, 13)];
            }
        }
        
        /* 무료통화, left바, 거리, right바, 분류 끝 */
        //
        
        // 출발지로 왔으면 도착버튼 없애기
        if(_currentSearchTargetType == SearchTargetType_START)
        {
            cell.localDest.hidden = YES;
            cell.localVisit.hidden = YES;
            [cell.localShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.localDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 도착지로 왔으면 출발버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_DEST)
        {
            cell.localStart.hidden = YES;
            cell.localVisit.hidden = YES;
            [cell.localDest setFrame:CGRectMake(10, 9, 81, 38)];
            [cell.localShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.localDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 경유지로 왔으면 출발, 도착버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_VISIT)
            
        {
            cell.localStart.hidden = YES;
            cell.localDest.hidden = YES;
            cell.localVisit.hidden = NO;
            [cell.localVisit setFrame:CGRectMake(10, 9, 81, 38)];
            [cell.localShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.localDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 음성검색출발지로 왔으면 출발버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_VOICESTART)
            
        {
            cell.localDest.hidden = YES;
            cell.localVisit.hidden = YES;
            [cell.localShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.localDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 음성검색도착지로 왔으면 도착버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_VOICEDEST)
            
        {
            cell.localStart.hidden = YES;
            cell.localVisit.hidden = YES;
            [cell.localDest setFrame:CGRectMake(10, 9, 81, 38)];
            [cell.localShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.localDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 음성검색경유지로 왔으면 출발, 도착버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_VOICEVISIT)
        {
            cell.localStart.hidden = YES;
            cell.localDest.hidden = YES;
            cell.localVisit.hidden = NO;
            [cell.localVisit setFrame:CGRectMake(10, 9, 81, 38)];
            [cell.localShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.localDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        [cell.localDetail addTarget:self action:@selector(generalDetail:) forControlEvents:UIControlEventTouchUpInside];
        
        // 라인POI일때 출발도착경유 disabled처리
//        if(![shapeType isEqualToString:@""])
//        {
//            [cell.localStart setEnabled:NO];
//            [cell.localDest setEnabled:NO];
//            [cell.localVisit setEnabled:NO];
//        }
//        else
//        {
//            [cell.localStart setEnabled:YES];
//            [cell.localDest setEnabled:YES];
//            [cell.localVisit setEnabled:YES];
//        }
        
        return cell;
        
    }
    
    // 주소!!!
    else if([tableView isKindOfClass:[UIAddressTableView class]])
    {
        
        NSUInteger section = [indexPath section];
        
        static NSString *identifier = @"addressIdentifier";
        
        AddressCell *cell = (AddressCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        
        if ( cell == nil )
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AddressCell" owner:nil options:nil];
            for (id oneObject in nib)
            {
                if([oneObject isKindOfClass:[AddressCell class]])
                {
                    cell = (AddressCell *)oneObject;
                    
                    break;
                }
                
            }
            
            UIImageView *selectedBackgroundView = [[UIImageView alloc] init];
            [selectedBackgroundView setBackgroundColor:convertHexToDecimalRGBA(@"d9", @"f4", @"ff", 1)];
            cell.selectedBackgroundView = selectedBackgroundView;
        }
        //NSLog(@"indexPath.row: %d, _addressIndex: %d ,indexPath.section: %d ,sectionType: %d _prevIndexPath : %@, indexPath : %@", indexPath.row, _addressIndex, indexPath.section, _sectionType, _prevIndexPath, indexPath);
        
        
        if(indexPath.row == _addressIndex && indexPath.section == _addressSection)
        {
            
            [cell.addBgView setBackgroundColor:convertHexToDecimalRGBA(@"d9", @"f4", @"ff", 1)];
            [cell.addressBtnView setHidden:NO];
            
        }
        else
        {
            //cell.addBgView.backgroundColor = [UIColor whiteColor];
            [cell.addressBtnView setHidden:YES];
        }
        
        //[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [cell.addressBtnView setFrame:CGRectMake(0, 58, 320, 57)];
        //[cell.addressSinglePOI setFrame:CGRectMake(280, 13, 30, 31)];
        
        cell.addressSinglePOI.tag = indexPath.row;
        
        //NSLog(@"cell.viewMap.tag = %d", indexPath.row);
        //[cell.viewMap setTitle:[rowData objectForKeyGC:@"Name"] forState:UIControlStateDisabled];
        
        [cell.addressSinglePOI addTarget:self action:@selector(clickToSinglePOIAddress:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect addressStrImgFrame = cell.addressStrImg.frame;
        CGPoint addressStrImgPoint = CGPointMake(addressStrImgFrame.origin.x + 2, addressStrImgFrame.origin.y + 2);
        CGSize addressStrImgSize = CGSizeMake(13, 14);
        addressStrImgFrame.size = addressStrImgSize;
        addressStrImgFrame.origin = addressStrImgPoint;
        [cell.addressStrImg setFrame:addressStrImgFrame];
        
        CGSize subSize;
        
        NSMutableDictionary *poiDic = [NSMutableDictionary dictionary];
        
        CGSize distSize;
        
        /* 거리변환 끝 */
        
        if(_addressType == addressSearchType_All)
        {
            if(section != 0)
            {
                
                poiDic = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataAddress"] objectAtIndexGC:indexPath.row];
                
                cell.addressName.text = [poiDic objectForKeyGC:@"ADDRESS"];
                
                //NSLog(@"주소 데이타 : %@", [poiDic objectForKeyGC:@"ADDRESS"] );
                
                cell.subAddress.text = [poiDic objectForKeyGC:@"M_NEWADDR2"];
                cell.subAddressImg.image = [UIImage imageNamed:@"new_address_icon.png"];
                
                [cell.addressDistance setText:[NSString stringWithFormat:@"%@", [self getDistance:poiDic:@"addr"]]];
                
                distSize = [cell.addressDistance.text sizeWithFont:cell.addressDistance.font];
                
                if(![poiDic objectForKeyGC:@"M_NEWADDR2"])
                {
                    [cell.subAddressImg setHidden:YES];
                    [cell.segmentBar setHidden:YES];
                    [cell.addressDistance setFrame:CGRectMake(41, 33, 47, 13)];
                    
                }
                else
                {
                    [cell.subAddressImg setFrame:CGRectMake(41, 32, 33, 15)];
                    
                    CGSize subAddressSize = [cell.subAddress.text sizeWithFont:cell.subAddress.font];
                    
                    [cell.segmentBar setFrame:CGRectMake(82 +subAddressSize.width, 33, 13, 13)];
                    [cell.addressDistance setFrame:CGRectMake(82+subAddressSize.width+13, 33, distSize.width, 13)];
                    
                    
                    subSize = subAddressSize;
                    
                    
                }

                cell.addressImg.image = [UIImage imageNamed:@"list_b_marker.png"];
                
                cell.addressStrImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"list_marker_%d.png", 1 + (int)(indexPath.row % 15)]];
                
            }
            else
            {
                
                cell.addressSinglePOI.tag = indexPath.row+100;
                
                _addressTopBottomType = addressBottomSection;
                poiDic = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataNewAddress"] objectAtIndexGC:indexPath.row];
                
                cell.addressName.text =[poiDic objectForKeyGC:@"NEW_ADDR"];
                
                cell.subAddress.text = [poiDic objectForKeyGC:@"M_ADDR2"];
                cell.subAddressImg.image = [UIImage imageNamed:@"old_address_icon.png"];
                
                [cell.addressDistance setText:[NSString stringWithFormat:@"%@", [self getDistance:poiDic:@"addr"]]];
                
                distSize = [cell.addressDistance.text sizeWithFont:cell.addressDistance.font];
                
                if(![poiDic objectForKeyGC:@"M_ADDR2"])
                {
                    [cell.subAddressImg setHidden:YES];
                    [cell.segmentBar setHidden:YES];
                    [cell.addressDistance setFrame:CGRectMake(41, 33, 47, 13)];
                    
//                    [cell.addressStart setEnabled:YES];
//                    [cell.addressDest setEnabled:YES];
//                    [cell.addressVisit setEnabled:YES];
                    
                }
                else
                {
                    [cell.subAddressImg setFrame:CGRectMake(41, 32, 33, 15)];
                    
                    CGSize subAddressSize = [cell.subAddress.text sizeWithFont:cell.subAddress.font];
                    
                    [cell.segmentBar setFrame:CGRectMake(82 +subAddressSize.width, 33, 13, 13)];
                    [cell.addressDistance setFrame:CGRectMake(82+subAddressSize.width+13, 33, distSize.width, 13)];
                    
                    subSize = subAddressSize;
                }
                
                NSString *mAddr2 = stringValueOfDictionary(poiDic, @"M_ADDR2");
                
                if(![mAddr2 isEqualToString:@""])
                {
                    cell.addressImg.image = [UIImage imageNamed:@"list_b_marker.png"];
//                    [cell.addressStart setEnabled:YES];
//                    [cell.addressDest setEnabled:YES];
//                    [cell.addressVisit setEnabled:YES];
                }
                else
                {
                    cell.addressImg.image = [UIImage imageNamed:@"line_list_b_marker.png"];
                    
                    [cell.addressStart setTag:indexPath.row + 500];
                    [cell.addressDest setTag:indexPath.row + 600];
                    [cell.addressVisit setTag:indexPath.row + 700];
//                    [cell.addressStart setEnabled:NO];
//                    [cell.addressDest setEnabled:NO];
//                    [cell.addressVisit setEnabled:NO];
                    
                    [cell.addressStart setImage:[UIImage imageNamed:@"list_btn_start_disabled.png"] forState:UIControlStateNormal];
                    [cell.addressDest setImage:[UIImage imageNamed:@"list_btn_stop_disabled.png"] forState:UIControlStateNormal];
                    [cell.addressVisit setImage:[UIImage imageNamed:@"list_btn_via_disabled.png"] forState:UIControlStateNormal];
                }
                
                cell.addressStrImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"list_marker_%d.png", 1 + (int)(indexPath.row % 15)]];
            }
            
            
            
        }
        else if (_addressType == addressSearchType_old)
        {
            
            poiDic = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataAddress"] objectAtIndexGC:indexPath.row];
            
            cell.addressName.text = [poiDic objectForKeyGC:@"ADDRESS"];
            
            //NSLog(@"주소 데이타 : %@", [poiDic objectForKeyGC:@"ADDRESS"] );
            
            cell.subAddress.text = [poiDic objectForKeyGC:@"M_NEWADDR2"];
            cell.subAddressImg.image = [UIImage imageNamed:@"new_address_icon.png"];
            
            [cell.addressDistance setText:[NSString stringWithFormat:@"%@", [self getDistance:poiDic:@"addr"]]];
            
            distSize = [cell.addressDistance.text sizeWithFont:cell.addressDistance.font];
            
            if(![poiDic objectForKeyGC:@"M_NEWADDR2"])
            {
                [cell.subAddressImg setHidden:YES];
                [cell.segmentBar setHidden:YES];
                [cell.addressDistance setFrame:CGRectMake(41, 33, 47, 13)];
                
            }
            else
            {
                [cell.subAddressImg setFrame:CGRectMake(41, 32, 33, 15)];
                
                CGSize subAddressSize = [cell.subAddress.text sizeWithFont:cell.subAddress.font];
                
                [cell.subAddress setFrame:CGRectMake(82, 33, subAddressSize.width, 13)];
                [cell.segmentBar setFrame:CGRectMake(82+subAddressSize.width, 33, 13, 13)];
                [cell.addressDistance setFrame:CGRectMake(82+subAddressSize.width+13, 33, distSize.width, 13)];
                
                subSize = subAddressSize;
            }
            
            cell.addressImg.image = [UIImage imageNamed:@"list_b_marker.png"];
            
            
            cell.addressStrImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"list_marker_%d.png", 1 + (int)(indexPath.row % 15)]];
            
//            [cell.addressStart setEnabled:YES];
//            [cell.addressDest setEnabled:YES];
//            [cell.addressVisit setEnabled:YES];
            
        }
        else if (_addressType == addressSearchType_new)
        {
            //NSLog(@"localDic : %@", [OllehMapStatus sharedOllehMapStatus].searchLocalDictionary);
            NSLog(@"indexPath : %d", (int)indexPath.row);
            NSLog(@"poiDic : %@", poiDic);
            
            
            poiDic = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataNewAddress"] objectAtIndexGC:indexPath.row];
            
            cell.addressName.text =[poiDic objectForKeyGC:@"NEW_ADDR"];
            
            cell.subAddress.text = [poiDic objectForKeyGC:@"M_ADDR2"];
            cell.subAddressImg.image = [UIImage imageNamed:@"old_address_icon.png"];
            
            [cell.addressDistance setText:[NSString stringWithFormat:@"%@", [self getDistance:poiDic:@"addr"]]];
            
            distSize = [cell.addressDistance.text sizeWithFont:cell.addressDistance.font];
            
            if(![poiDic objectForKeyGC:@"M_ADDR2"])
            {
                [cell.subAddressImg setHidden:YES];
                [cell.segmentBar setHidden:YES];
                [cell.addressDistance setFrame:CGRectMake(41, 33, 47, 13)];
                
//                [cell.addressStart setEnabled:YES];
//                [cell.addressDest setEnabled:YES];
//                [cell.addressVisit setEnabled:YES];
                
            }
            else
            {
                CGSize subAddressSize = [cell.subAddress.text sizeWithFont:cell.subAddress.font];
                
                [cell.subAddressImg setFrame:CGRectMake(41, 32, 33, 15)];
                [cell.subAddress setFrame:CGRectMake(82, 33, subAddressSize.width, 13)];
                [cell.segmentBar setFrame:CGRectMake(82+subAddressSize.width, 33, 13, 13)];
                [cell.addressDistance setFrame:CGRectMake(82+subAddressSize.width+13, 33, distSize.width, 13)];
                
                subSize = subAddressSize;
                
            }
            
            NSString *mAddr2 = stringValueOfDictionary(poiDic, @"M_ADDR2");
            
            if(![mAddr2 isEqualToString:@""])
            {
                cell.addressImg.image = [UIImage imageNamed:@"list_b_marker.png"];
//                [cell.addressStart setEnabled:YES];
//                [cell.addressDest setEnabled:YES];
//                [cell.addressVisit setEnabled:YES];
            }
            else
            {
                cell.addressImg.image = [UIImage imageNamed:@"line_list_b_marker.png"];
                [cell.addressStart setTag:indexPath.row + 500];
                [cell.addressDest setTag:indexPath.row + 600];
                [cell.addressVisit setTag:indexPath.row + 700];

                
                [cell.addressStart setImage:[UIImage imageNamed:@"list_btn_start_disabled.png"] forState:UIControlStateNormal];
                [cell.addressDest setImage:[UIImage imageNamed:@"list_btn_stop_disabled.png"] forState:UIControlStateNormal];
                [cell.addressVisit setImage:[UIImage imageNamed:@"list_btn_via_disabled.png"] forState:UIControlStateNormal];
            }
            
            cell.addressStrImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"list_marker_%d.png", 1 + (int)(indexPath.row % 15)]];
        }
        

        
        /* 주소 출력 */
        
        CGSize sizePlaceName = [cell.addressName.text sizeWithFont:cell.addressName.font];
        [cell.addressName setFrame:CGRectMake(41, 11, sizePlaceName.width, 15)];
        if(41 + sizePlaceName.width > 253)
        {
            sizePlaceName.width = 253 - 41;
            [cell.addressName setFrame:CGRectMake(41, 11, sizePlaceName.width, 15)];
        }
        
        /* 주소 출력 끝 */
        
        // 하위 길어질 때
        if(82 + subSize.width + 13 + distSize.width > 251)
        {
            subSize.width = 251 - 82 - 13 - distSize.width;
            [cell.subAddress setAdjustsFontSizeToFitWidth:NO];
            [cell.subAddress setFrame:CGRectMake(82, 33, subSize.width, 13)];
            [cell.segmentBar setFrame:CGRectMake(82+subSize.width, 33, 13, 13)];
            [cell.addressDistance setFrame:CGRectMake(82+subSize.width+13, 33, distSize.width, 13)];
            
        }
        
        //CGSize sizeDistance = [cell.addressDistance.text sizeWithFont:cell.addressDistance.font];
        
        
        //[cell.addressDistance setFrame:CGRectMake(41, 33, sizeDistance.width, 13)];
        
        //NSMutableDictionary *poiDic = [[oms.searchLocalDictionary objectForKeyGC:@"DataAddress"] objectAtIndexGC:indexPath.row];
        
        // 출발지로 왔으면 도착버튼 없애기
        if(_currentSearchTargetType == SearchTargetType_START)
        {
            cell.addressDest.hidden = YES;
            cell.addressVisit.hidden = YES;
            [cell.addressShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.addressDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 도착지로 왔으면 출발버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_DEST)
        {
            cell.addressStart.hidden = YES;
            cell.addressVisit.hidden = YES;
            [cell.addressDest setFrame:CGRectMake(10, 9, 81, 38)];
            [cell.addressShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.addressDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 경유지로 왔으면 출발, 도착버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_VISIT)
            
        {
            cell.addressStart.hidden = YES;
            cell.addressDest.hidden = YES;
            cell.addressVisit.hidden = NO;
            [cell.addressVisit setFrame:CGRectMake(10, 9, 81, 38)];
            [cell.addressShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.addressDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 음성검색출발지로 왔으면 출발버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_VOICESTART)
            
        {
            cell.addressDest.hidden = YES;
            cell.addressVisit.hidden = YES;
            [cell.addressShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.addressDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 음성검색도착지로 왔으면 도착버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_VOICEDEST)
            
        {
            cell.addressStart.hidden = YES;
            cell.addressVisit.hidden = YES;
            [cell.addressDest setFrame:CGRectMake(10, 9, 81, 38)];
            [cell.addressShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.addressDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 음성검색경유지로 왔으면 출발, 도착버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_VOICEVISIT)
            
        {
            cell.addressStart.hidden = YES;
            cell.addressDest.hidden = YES;
            cell.addressVisit.hidden = NO;
            [cell.addressVisit setFrame:CGRectMake(10, 9, 81, 38)];
            [cell.addressShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.addressDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        [cell.addressDetail addTarget:self action:@selector(addressDetail:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        
        
    }
    
    // 버정!!
    else if ([tableView isKindOfClass:[UIBusStationTableView class]])
    {
        static NSString *identifier = @"busStationIdentifier";
        
        BusStationCell *cell = (BusStationCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        
        if ( cell == nil )
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BusStationCell" owner:nil options:nil];
            for (id oneObject in nib)
            {
                if([oneObject isKindOfClass:[BusStationCell class]])
                {
                    cell = (BusStationCell *)oneObject;
                    
                    break;
                }
                
            }
            
            UIImageView *selectedBackgroundView = [[UIImageView alloc] init];
            [selectedBackgroundView setBackgroundColor:convertHexToDecimalRGBA(@"d9", @"f4", @"ff", 1)];
            cell.selectedBackgroundView = selectedBackgroundView;
        }
        
        if(indexPath.row == _busStationIndex)
        {
            [cell.busStationBgView setBackgroundColor:convertHexToDecimalRGBA(@"d9", @"f4", @"ff", 1)];
            [cell.busStationBtnView setHidden:NO];
        }
        else
        {
            //cell.busStationBgView.backgroundColor = [UIColor whiteColor];
            [cell.busStationBtnView setHidden:YES];
        }
        
        //[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        
        //[cell.busStationSinglePOI setFrame:CGRectMake(280, 13, 30, 31)];
        cell.busStationSinglePOI.tag = indexPath.row;
        
        //[cell.viewMap setTitle:[rowData objectForKeyGC:@"Name"] forState:UIControlStateDisabled];
        cell.busStationImg.image = [UIImage imageNamed:@"list_b_marker.png"];
        cell.busStationStrImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"list_marker_%d.png", 1 + (int)(indexPath.row % 15)]];
        
        CGRect busStationStrImgFrame = cell.busStationStrImg.frame;
        CGPoint busStationStrImgPoint = CGPointMake(busStationStrImgFrame.origin.x + 2, busStationStrImgFrame.origin.y + 2);
        CGSize busStationStrImgSize = CGSizeMake(13, 14);
        busStationStrImgFrame.size = busStationStrImgSize;
        busStationStrImgFrame.origin = busStationStrImgPoint;
        [cell.busStationStrImg setFrame:busStationStrImgFrame];
        
        [cell.busStationBtnView setFrame:CGRectMake(0, 58, 320, 57)];
        
        [cell.busStationSinglePOI addTarget:self action:@selector(clickToSinglePOIBusStation:) forControlEvents:UIControlEventTouchUpInside];
        
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        NSMutableDictionary *dic = [[oms.searchLocalDictionary objectForKeyGC:@"DataPublicBusStation"] objectAtIndexGC:indexPath.row];
        
        /* 버스정류장 이름 출력 */
        //                cell.placeName.text = [NSString stringWithFormat:@"%@(%d)", [dic objectForKeyGC:@"BST_NAME"], [dic objectForKeyGC:@"STID"]];
        //NSLog(@"버정인덱스패쓰 : %d", indexPath.row);
        
        cell.busStationName.text = [dic objectForKeyGC:@"BST_NAME"];
        
        CGSize sizePlaceName = [cell.busStationName.text sizeWithFont:cell.busStationName.font];
        [cell.busStationName setFrame:CGRectMake(41, 11, sizePlaceName.width, 15)];
        
        /* 버스정류장 이름 출력 끝 */
        
        /* 정류장 고유번호 출력 */
        cell.busStationUniqueId.text = [dic objectForKeyGC:@"ST_UNIQUEID"];
        
        
        NSString *busUniqueID = [dic objectForKeyGC:@"ST_UNIQUEID"];
        
        if([busUniqueID isEqualToString:@"0"])
        {
            cell.busStationUniqueId.hidden = YES;
        }
        else
        {
            NSString *before2;
            NSString *after3;
            
            before2 = [busUniqueID substringToIndex:2];
            after3 = [busUniqueID substringFromIndex:2];
            //        NSLog(@"2자리 : %@", before2);
            //        NSLog(@"3자리 : %@", after3);
            
            
            
            
            cell.busStationUniqueId.text = [NSString stringWithFormat:@"[%@%@%@]", before2, @"-" ,after3];
            
        }
        
        //NSLog(@"%@", [dic objectForKeyGC:@"STID"]);
        //cell.busStationNum.text = [dic objectForKeyGC:@"STID"];
        CGSize sizeBusStationNum = [cell.busStationUniqueId.text sizeWithFont:cell.busStationUniqueId.font];
        [cell.busStationUniqueId setFrame:CGRectMake(41 + sizePlaceName.width, 11, sizeBusStationNum.width, 15)];
        
        
        if(41 + sizePlaceName.width + sizeBusStationNum.width > 253)
        {
            sizePlaceName.width = 253 - 41 - sizeBusStationNum.width;
            [cell.busStationName setFrame:CGRectMake(41, 11, sizePlaceName.width, 15)];
            [cell.busStationUniqueId setFrame:CGRectMake(41 + sizePlaceName.width, 11, sizeBusStationNum.width, 15)];
        }
        
        /* 고유번호 출력 끝 */
        
        /* 거리변환 */
        
        [cell.busStationDistance setText:[NSString stringWithFormat:@"%@", [self getDistance:dic:@"bs"]]];
        
        /* 거리변환 끝 */
        
        /* 시도동 출력 */
        
        cell.busStationDo.text = [dic objectForKeyGC:@"BST_DO"];
        cell.busStationGu.text = [dic objectForKeyGC:@"BST_GU"];
        cell.busStationDong.text = [dic objectForKeyGC:@"BST_DONG"];
        
        if([cell.busStationGu.text isEqualToString:@""])
        {
            cell.busStationGu.hidden = YES;
        }
        if([cell.busStationDong.text isEqualToString:@""])
        {
            cell.busStationDong.hidden = YES;
        }
        
        CGSize sizeDistance = [cell.busStationDistance.text sizeWithFont:cell.busStationDistance.font];
        CGSize sizeClassfication = [cell.busStationDo.text sizeWithFont:cell.busStationDo.font];
        CGSize sizeBusStationGu = [cell.busStationGu.text sizeWithFont:cell.busStationGu.font];
        CGSize sizeBusStationDong = [cell.busStationDong.text sizeWithFont:cell.busStationDong.font];
        
        [cell.busStationDistance setFrame:CGRectMake(41, 33, sizeDistance.width, 13)];
        [cell.busStationRightBar setFrame:CGRectMake(41 + sizeDistance.width, 33, 13, 13)];
        [cell.busStationDo
         setFrame:CGRectMake(41 + sizeDistance.width + 13, 33, sizeClassfication.width, 13)];
        [cell.busStationGu
         setFrame:CGRectMake(41 + sizeDistance.width + 13 + sizeClassfication.width + 5, 33, sizeBusStationGu.width , 13)];
        [cell.busStationDong
         setFrame:CGRectMake(41 + sizeDistance.width + 13 + + sizeClassfication.width + 5 + sizeBusStationGu.width + 5, 33, sizeBusStationDong.width , 13)];
        
        if(41 + sizeDistance.width + 13 + sizeClassfication.width + 5 + sizeBusStationGu.width + 5 + sizeBusStationDong.width > 253)
        {
            sizeBusStationDong.width = 253 - (41 + sizeDistance.width + 13 + sizeClassfication.width + 5 + sizeBusStationGu.width + 5);
            
            [cell.busStationDong
             setFrame:CGRectMake(41 + sizeDistance.width + 13 + + sizeClassfication.width + 5 + sizeBusStationGu.width + 5, 33, sizeBusStationDong.width , 13)];
        }
        
        // 출발지로 왔으면 도착버튼 없애기
        if(_currentSearchTargetType == SearchTargetType_START)
        {
            cell.busStationDest.hidden = YES;
            cell.busStationVisit.hidden = YES;
            [cell.busStationShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.busStationDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 도착지로 왔으면 출발버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_DEST)
        {
            cell.busStationStart.hidden = YES;
            cell.busStationVisit.hidden = YES;
            [cell.busStationDest setFrame:CGRectMake(10, 9, 81, 38)];
            [cell.busStationShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.busStationDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 경유지로 왔으면 출발, 도착버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_VISIT)
            
        {
            cell.busStationStart.hidden = YES;
            cell.busStationDest.hidden = YES;
            cell.busStationVisit.hidden = NO;
            [cell.busStationVisit setFrame:CGRectMake(10, 9, 81, 38)];
            [cell.busStationShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.busStationDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 음성검색출발지로 왔으면 출발버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_VOICESTART)
            
        {
            cell.busStationDest.hidden = YES;
            cell.busStationVisit.hidden = YES;
            [cell.busStationShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.busStationDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 음성검색도착지로 왔으면 도착버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_VOICEDEST)
            
        {
            cell.busStationStart.hidden = YES;
            cell.busStationVisit.hidden = YES;
            [cell.busStationDest setFrame:CGRectMake(10, 9, 81, 38)];
            [cell.busStationShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.busStationDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 음성검색경유지로 왔으면 출발, 도착버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_VOICEVISIT)
            
        {
            cell.busStationStart.hidden = YES;
            cell.busStationDest.hidden = YES;
            cell.busStationVisit.hidden = NO;
            [cell.busStationVisit setFrame:CGRectMake(10, 9, 81, 38)];
            [cell.busStationShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.busStationDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        [cell.busStationDetail addTarget:self action:@selector(busStationDetail:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        //NSMutableDictionary *dic = [[oms.searchLocalDictionary objectForKeyGC:@"DataPublicBusStation"] objectAtIndexGC:indexPath.row];
        
        
    }
    // 지하철!!
    else if ([tableView isKindOfClass:[UISubwayTableView class]])
    {
        
        static NSString *identifier = @"subwayStationIdentifier";
        
        SubwayStationCell *cell = (SubwayStationCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        
        if ( cell == nil )
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SubwayStationCell" owner:nil options:nil];
            for (id oneObject in nib)
            {
                if([oneObject isKindOfClass:[SubwayStationCell class]])
                {
                    cell = (SubwayStationCell *)oneObject;
                    
                    break;
                }
                
            }
            
            UIImageView *selectedBackgroundView = [[UIImageView alloc] init];
            [selectedBackgroundView setBackgroundColor:convertHexToDecimalRGBA(@"d9", @"f4", @"ff", 1)];
            cell.selectedBackgroundView = selectedBackgroundView;
        }
        
        if(indexPath.row == _subwayIndex)
        {
            [cell.subwayBgView setBackgroundColor:convertHexToDecimalRGBA(@"d9", @"f4", @"ff", 1)];
            [cell.subwayStationBtnView setHidden:NO];
        }
        else
        {
            //cell.subwayBgView.backgroundColor = [UIColor whiteColor];
            [cell.subwayStationBtnView setHidden:YES];
        }
        
        //[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        //NSMutableDictionary *dic = [[oms.searchLocalDictionary objectForKeyGC:@"DataPublicSubwayStation"] objectAtIndexGC:indexPath.row];
        [cell.subwayStationBtnView setFrame:CGRectMake(0, 58, 320, 57)];
        //[cell.subwayStationSinglePOI setFrame:CGRectMake(280, 13, 30, 31)];
        cell.subwayStationSinglePOI.tag = indexPath.row;
        
        //[cell.viewMap setTitle:[rowData objectForKeyGC:@"Name"] forState:UIControlStateDisabled];
        
        cell.subwayStationImg.image = [UIImage imageNamed:@"list_b_marker.png"];
        cell.subwayStationStr.image = [UIImage imageNamed:[NSString stringWithFormat:@"list_marker_%d.png", 1 + (int)(indexPath.row % 15)]];
        
        CGRect subwayStationStrImgFrame = cell.subwayStationStr.frame;
        CGPoint subwayStationStrImgPoint = CGPointMake(subwayStationStrImgFrame.origin.x + 2,
                                                       subwayStationStrImgFrame.origin.y + 2);
        CGSize subwayStationStrImgSize = CGSizeMake(13, 14);
        subwayStationStrImgFrame.size = subwayStationStrImgSize;
        subwayStationStrImgFrame.origin = subwayStationStrImgPoint;
        [cell.subwayStationStr setFrame:subwayStationStrImgFrame];
        
        [cell.subwayStationSinglePOI addTarget:self action:@selector(clickToSinglePOISubwayStation:) forControlEvents:UIControlEventTouchUpInside];
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        NSMutableDictionary *dic = [[oms.searchLocalDictionary objectForKeyGC:@"DataPublicSubwayStation"] objectAtIndexGC:indexPath.row];
        
        //NSLog(@"지하철인덱스패쓰 : %d", indexPath.row);
        //NSLog(@"dic의 내용 %@", dic);
        
        cell.subwayStationName.text = stringValueOfDictionary(dic, @"SST_NAME"); [dic objectForKeyGC:@"SST_NAME"];
        cell.subwayStationLine.text = stringValueOfDictionary(dic, @"SUBWAY_LANENAME"); //[dic objectForKeyGC:@"SUBWAY_LANENAME"];
        
        CGSize sizePlaceName = [cell.subwayStationName.text sizeWithFont:cell.subwayStationName.font];
        CGSize sizeSubwayLine = [cell.subwayStationLine.text sizeWithFont:cell.subwayStationLine.font];
        
        
        [cell.subwayStationName setFrame:CGRectMake(41, 11, sizePlaceName.width, 15)];
        [cell.subwayStationLine setFrame:CGRectMake(41 + sizePlaceName.width + 5, 11, sizeSubwayLine.width, 15)];
        
        if(41 + sizePlaceName.width + 5 + sizeSubwayLine.width > 253)
        {
            sizePlaceName.width = 253 - 41 - 5 - sizeSubwayLine.width;
            [cell.subwayStationName setFrame:CGRectMake(41, 11, sizePlaceName.width, 15)];
            [cell.subwayStationLine setFrame:CGRectMake(41 + sizePlaceName.width + 5, 11, sizeSubwayLine.width, 15)];
        }
        
        [cell.subwayStationDistance setText:[NSString stringWithFormat:@"%@", [self getDistance:dic:@"ss"]]];
        
        ////
        cell.subwayStationDo.text = stringValueOfDictionary(dic, @"DO"); //[dic objectForKeyGC:@"DO"];
        cell.subwayStationGu.text = stringValueOfDictionary(dic, @"GU"); //[dic objectForKeyGC:@"GU"];
        cell.subwayStationDong.text = stringValueOfDictionary(dic, @"DONG"); //[dic objectForKeyGC:@"DONG"];
        
        if([cell.subwayStationGu.text isEqualToString:@""])
        {
            cell.subwayStationGu.hidden = YES;
        }
        if([cell.subwayStationDong.text isEqualToString:@""])
        {
            cell.subwayStationDong.hidden = YES;
        }
        
        CGSize sizeDistance = [cell.subwayStationDistance.text sizeWithFont:cell.subwayStationDistance.font];
        CGSize sizeClassfication = [cell.subwayStationDo.text sizeWithFont:cell.subwayStationDo.font];
        CGSize sizeSubwayStationGu = [cell.subwayStationGu.text sizeWithFont:cell.subwayStationGu.font];
        CGSize sizeSubwayStationDong = [cell.subwayStationDong.text sizeWithFont:cell.subwayStationDong.font];
        
        [cell.subwayStationDistance setFrame:CGRectMake(41, 33, sizeDistance.width, 13)];
        [cell.subwayStationRightBar setFrame:CGRectMake(41 + sizeDistance.width, 33, 13, 13)];
        [cell.subwayStationDo
         setFrame:CGRectMake(41 + sizeDistance.width + 13, 33, sizeClassfication.width, 13)];
        [cell.subwayStationGu
         setFrame:CGRectMake(41 + sizeDistance.width + 13 + sizeClassfication.width + 5, 33, sizeSubwayStationGu.width , 13)];
        [cell.subwayStationDong
         setFrame:CGRectMake(41 + sizeDistance.width + 13 + + sizeClassfication.width + 5 + sizeSubwayStationGu.width + 5, 33, sizeSubwayStationDong.width , 13)];
        
        if(41 + sizeDistance.width + 13 + sizeClassfication.width + 5 + sizeSubwayStationGu.width + 5 + sizeSubwayStationDong.width > 253)
        {
            sizeSubwayStationDong.width = 253 - (41 + sizeDistance.width + 13 + sizeClassfication.width + 5 + sizeSubwayStationGu.width + 5);
            
            [cell.subwayStationDong
             setFrame:CGRectMake(41 + sizeDistance.width + 13 + + sizeClassfication.width + 5 + sizeSubwayStationGu.width + 5, 33, sizeSubwayStationDong.width , 13)];
        }
        
        // 출발지로 왔으면 도착버튼 없애기
        if(_currentSearchTargetType == SearchTargetType_START)
        {
            cell.subwayDest.hidden = YES;
            cell.subwayVisit.hidden = YES;
            [cell.subwayShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.subwayDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 도착지로 왔으면 출발버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_DEST)
        {
            cell.subwayStart.hidden = YES;
            cell.subwayVisit.hidden = YES;
            [cell.subwayDest setFrame:CGRectMake(10, 9, 81, 38)];
            [cell.subwayShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.subwayDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 경유지로 왔으면 출발, 도착버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_VISIT)
            
        {
            cell.subwayStart.hidden = YES;
            cell.subwayDest.hidden = YES;
            cell.subwayVisit.hidden = NO;
            [cell.subwayVisit setFrame:CGRectMake(10, 9, 81, 38)];
            [cell.subwayShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.subwayDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 음성검색출발지로 왔으면 출발버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_VOICESTART)
            
        {
            cell.subwayDest.hidden = YES;
            cell.subwayVisit.hidden = YES;
            [cell.subwayShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.subwayDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 음성검색도착지로 왔으면 도착버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_VOICEDEST)
            
        {
            cell.subwayStart.hidden = YES;
            cell.subwayVisit.hidden = YES;
            [cell.subwayDest setFrame:CGRectMake(10, 9, 81, 38)];
            [cell.subwayShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.subwayDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        // 음성검색경유지로 왔으면 출발, 도착버튼 없애기
        else if(_currentSearchTargetType == SearchTargetType_VOICEVISIT)
            
        {
            cell.subwayStart.hidden = YES;
            cell.subwayDest.hidden = YES;
            cell.subwayVisit.hidden = NO;
            [cell.subwayVisit setFrame:CGRectMake(10, 9, 81, 38)];
            [cell.subwayShare setFrame:CGRectMake(96, 9, 61, 38)];
            [cell.subwayDetail setFrame:CGRectMake(162, 9, 61, 38)];
        }
        
        [cell.subwayDetail addTarget:self action:@selector(subwayDetail:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    // 버스!!
    else if ([tableView isKindOfClass:[UIBusNumberTableView class]])
    {
        static NSString *identifier = @"busNumberdentifier";
        
        DetailCell2 *cell2 = (DetailCell2 *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if( cell2 == nil ) {
            NSBundle *nbd = [NSBundle mainBundle];
            
            NSArray *nib = [nbd loadNibNamed:@"DetailCell2" owner:self
                                     options:nil];
            for (id oneObject in nib)
            {
                if([oneObject isKindOfClass:[DetailCell2 class]])
                    cell2 = (DetailCell2 *)oneObject;
                
            }
            
            UIImageView *selectedBackgroundView = [[UIImageView alloc] init];
            [selectedBackgroundView setBackgroundColor:convertHexToDecimalRGBA(@"d9", @"f4", @"ff", 1)];
            cell2.selectedBackgroundView = selectedBackgroundView;
        }
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        NSMutableDictionary *dic =
        
        [[oms.searchLocalDictionary objectForKeyGC:@"DataPublicBusNumber"] objectAtIndexGC:indexPath.row];
        //[cell2 setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        NSString *busNumValue = [dic objectForKeyGC:@"BL_BUSCLASS"];
        
        [cell2.poiImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", [oms getLaneIdToImgString:busNumValue]]]];
        
        int citycode2 = [[dic objectForKeyGC:@"BL_CITYCODE"] intValue];
        
        //NSLog(@"히히 %@", dic);
        
        NSString *busStr = [dic objectForKeyGC:@"BL_BUSNO"];
        
        NSString *finder = @"-0";
        
        NSRange rOriginal = [busStr rangeOfString:finder];
        if (NSNotFound != rOriginal.location)
        {
            busStr = [busStr substringToIndex:rOriginal.location];
        }
        
        
        
        cell2.busNumber.text = busStr;
        cell2.busArea.text = [oms cityCodeToCityName:citycode2];
        
        
        CGSize sizeBusNumber = [cell2.busNumber.text sizeWithFont:cell2.busNumber.font];
        CGSize sizeBusArea = [cell2.busArea.text sizeWithFont:cell2.busArea.font];
        [cell2.busNumber setFrame:CGRectMake(cell2.busNumber.frame.origin.x, cell2.busNumber.frame.origin.y, sizeBusNumber.width, sizeBusNumber.height)];
        [cell2.busArea setFrame:CGRectMake(cell2.busNumber.frame.origin.x+sizeBusNumber.width, cell2.busNumber.frame.origin.y, sizeBusArea.width, sizeBusNumber.height)];
        
        
        
        NSString *laneInfo = [dic objectForKeyGC:@"BL_LANEINFO"];
        
        NSArray *arr = [laneInfo componentsSeparatedByString:@"-"];
        
        NSString *startStat = [arr objectAtIndexGC:0];
        NSString *returnStat = [arr objectAtIndexGC:1];
        
        //기존
        cell2.startStation.text = [NSString stringWithFormat:@"%@ ~ ", startStat];
        
        // 기존수정
        //cell2.startStation.text = [NSString stringWithFormat:@"%@ ~ %@", startStat, returnStat];
        
        cell2.returnStation.text = returnStat;
        
        CGSize sizeStartStation = [cell2.startStation.text sizeWithFont:cell2.startStation.font];
        CGSize sizeReturnStation = [cell2.returnStation.text sizeWithFont:cell2.returnStation.font];
        
        [cell2.startStation setFrame:CGRectMake(41, 33, sizeStartStation.width, sizeStartStation.height)];
        
        // 기존 이미지 삭제
        [cell2.arrow setHidden:YES];
        //[cell2.returnStation setHidden:YES];
        // 기존이미지 삭제 끝
        [cell2.arrow setFrame:CGRectMake(41 + sizeStartStation.width, 33, 21, 13)];
        [cell2.returnStation setFrame:CGRectMake(41 + sizeStartStation.width, 33, sizeReturnStation.width, sizeReturnStation.height)];
        
        if(41 + sizeStartStation.width + sizeReturnStation.width > 289)
        {
            sizeReturnStation.width = 289 - (41 + sizeStartStation.width);
            
            [cell2.startStation setFrame:CGRectMake(41, 33, sizeStartStation.width, sizeStartStation.height)];
            [cell2.returnStation setFrame:CGRectMake(41 + sizeStartStation.width, 33, sizeReturnStation.width, sizeReturnStation.height)];
        }
        
        return cell2;
        
    }
    //    // 같은이름다른지역 그리기
    else if ([tableView isKindOfClass:[UIResearchTableView class]])
    {
        
        UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"poi_busstop_list_bg_pressed.png"]];
        
        [tableView setSeparatorColor:backgroundColor];
        
        static NSString *reidentifier = @"reSearchIdentifier";
        
        //
        UIReSearchTableViewCell *reCell = (UIReSearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reidentifier];
        if (reCell == nil) {
            reCell = [[UIReSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reidentifier];
            [reCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [reCell.contentView setBackgroundColor:convertHexToDecimalRGBA(@"f4", @"f4", @"f4", 1.0)];
        }
        
        // 참이면 새주소 아니면 구주소
        if([self oldAddressORNewAddressSelectReturnBool])
        {
            
            //dic = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataNewAddress"] objectAtIndexGC:indexPath.row];
            reCell.textLabel.text = [[_reSearchDic objectAtIndexGC:indexPath.row] objectForKeyGC:@"NEW_ADDR"];
            
        }
        else
        {
            //dic = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataAddress"] objectAtIndexGC:indexPath.row];
            //reCell.textLabel.text = [dic objectForKeyGC:@"ADDRESS"];
            reCell.textLabel.text = [[_reSearchDic objectAtIndexGC:indexPath.row] objectForKeyGC:@"ADDRESS"];
            
        }
        
        reCell.textLabel.font = [UIFont systemFontOfSize:14];
        
        
        return reCell;
        
    }
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"celllasdasd"];
        
        cell.textLabel.text = @"기타";
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    return cell;
    
}

// 행을 클릭할 때 액션
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 새로운 url공유
    NSString *order = @"rank";
    
    if(_commonRadioType == commonRadioButtonType_distance)
    {
        order = @"dis";
    }
    
    [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@", order] forKey:@"LastExtendOrder"];
    
    //
    
    if([tableView isKindOfClass:[UIPlaceTableView class]])
    {
        // 확장어쩌고저쩌고 이후 해당 셀 스크롤..
        CGRect rectVisible = [_placeTableView rectForRowAtIndexPath:indexPath];
        
        CGRect rect = [_placeTableView convertRect:rectVisible toView:self.view];
        
        NSMutableArray *reloadList = [[NSMutableArray alloc] init];
        
        for (NSIndexPath *currentPath in [_placeTableView indexPathsForVisibleRows])
        {
            if(currentPath.row == _localIndex && _localIndex != indexPath.row)
                [reloadList addObject:currentPath];
            
        }
        
        _localIndex = _localIndex == indexPath.row ? -1 : (int)indexPath.row;
        
        [reloadList addObject:indexPath];
        //[_searchList reloadRowsAtIndexPaths:[_searchList indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
        [_placeTableView reloadRowsAtIndexPaths:reloadList withRowAnimation:UITableViewRowAnimationNone];
        
        
        @try {
            
            
            NSMutableDictionary *poiDic = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataPlace"] objectAtIndexGC:indexPath.row];
            
            
            //NSLog(@"셀의 내용 : %@", poiDic);
            NSString *place = [poiDic objectForKeyGC:@"NAME"];
            
            
            Coord poiCrd = CoordMake([[poiDic objectForKeyGC:@"X"] doubleValue], [[poiDic objectForKeyGC:@"Y"] doubleValue]);
            
            
            double xx = poiCrd.x;
            double yy = poiCrd.y;
            
            //NSLog(@"%@, %f, %f", place, xx, yy);
            NSString *freecalling = @"";
            if( [stringValueOfDictionary(poiDic, @"STHEME_CODE") rangeOfString:@"PG1201000000008"].location != NSNotFound )
                freecalling = @"PG1201000000008";
            
            // 추가됨
            NSString *shapeType = stringValueOfDictionary(poiDic, @"SHAPE_TYPE");
            NSString *fcNm = stringValueOfDictionary(poiDic, @"FC_NM");
            NSString *idBGM = stringValueOfDictionary(poiDic, @"ID_BGM");
            
            NSString *org_Db_Type = [poiDic objectForKeyGC:@"ORG_DB_TYPE"];
            NSString *org_db_id = [poiDic objectForKeyGC:@"ORG_DB_ID"];
            NSString *did_code = [poiDic objectForKeyGC:@"DOCID"];
            NSString *theme_code = [poiDic objectForKeyGC:@"THEME_CODE"];
            NSString *newAddrString = stringValueOfDictionary(poiDic, @"NEW_ADDR");
            
            NSString *addr = [poiDic objectForKeyGC:@"ADDR"];
            NSString *tel = [poiDic objectForKeyGC:@"TEL"];
            
            [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@",place] forKey:@"LastExtendCellName"];
            [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%f",xx] forKey:@"LastExtendCellX"];
            [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setObject:[NSString stringWithFormat:@"%f",yy] forKey:@"LastExtendCellY"];
            [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@",org_Db_Type] forKey:@"LastExtendCellType"];
            [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@",org_db_id] forKey:@"LastExtendCellId"];
            [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@",did_code] forKey:@"LastExtendCellDidCode"];
            [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@", theme_code] forKey:@"LastExtendCellTheme"];
            
            //NSLog(@"freecalling : %@", freecalling);
            
            NSLog(@"%@ %@", [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"LastExtendCellId"], [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"LastExtendCellDidCode"]);
            
            if([freecalling isEqualToString:@""])
            {
                [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setObject:[NSString stringWithFormat:@""] forKey:@"LastExtendFreeCall"];
            }
            else
            {
                
                
                [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setObject:[NSString stringWithFormat:@"%@", freecalling] forKey:@"LastExtendFreeCall"];
            }
            
            if([newAddrString isEqualToString:@""])
            {
                [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setObject:[NSString stringWithFormat:@""] forKey:@"LastExtendNewAddr"];
            }
            else
            {
                [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setObject:[NSString stringWithFormat:@"%@", newAddrString] forKey:@"LastExtendNewAddr"];
            }
            
            [[OllehMapStatus sharedOllehMapStatus].searchResult setStrShape:shapeType];
            [[OllehMapStatus sharedOllehMapStatus].searchResult setStrShapeFcNm:fcNm];
            [[OllehMapStatus sharedOllehMapStatus].searchResult setStrShapeIdBgm:idBGM];
            
            [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@", tel] forKey:@"LastExtendCellTel"];
            [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@", addr] forKey:@"LastExtendCellTelAddress"];
            
            // 마지막꺼 확장시 내림
            if (self.view.frame.size.height - 132 < rect.origin.y)
                [_placeTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            
        }
        @catch (NSException *exception)
        {
            [OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"%@", exception]];
        }
        
    }
    else if ([tableView isKindOfClass:[UIAddressTableView class]])
    {
        
        NSUInteger section = [indexPath section];
        
        // 확장어쩌고저쩌고 이후 해당 셀 스크롤..
        if(_addressType == addressSearchType_All)
        {
            if(section == 0)
            {
                _addressTopBottomType = addressTopSection;
            }
            if(section == 1)
            {
                _addressTopBottomType = addressBottomSection;
            }
        }
        //NSLog(@"인덱패스로우 : %d", indexPath.row);
        
        CGRect rectVisible = [_addressTableView rectForRowAtIndexPath:indexPath];
        
        CGRect rect = [_addressTableView convertRect:rectVisible toView:self.view];
        
        NSMutableArray *reloadList = [[NSMutableArray alloc] init];
        
        for (NSIndexPath *currentPath in [_addressTableView indexPathsForVisibleRows])
        {
            NSLog(@"currentRow : %d, _addressIndex : %d, currentSec : %d, _addressSec : %d", (int)currentPath.row, _addressIndex, (int)currentPath.section, _addressSection);
            if(currentPath.row == _addressIndex && currentPath.section == _addressSection)
            {
                //
                [reloadList addObject:currentPath];
            }
            else if (indexPath.row == currentPath.row && indexPath.section == currentPath.section)
            {
                [reloadList addObject:currentPath];
            }
            
        }
        
        NSLog(@"reloadList : %@", reloadList);
        
        if(_addressSection == indexPath.section && _addressIndex == indexPath.row)
        {
            _addressIndex = -1;
            _addressSection = -1;
        }
        else
        {
            _addressIndex = (int)indexPath.row;
            _addressSection = (int)indexPath.section;
        }
        
        NSLog(@"reloadList : %@", reloadList);
        
        [_addressTableView reloadRowsAtIndexPaths:reloadList withRowAnimation:UITableViewRowAnimationNone];
        
        
        NSMutableDictionary *poiDic = [NSMutableDictionary dictionary];
        NSString *add;
        NSString *subAddSigu;
        NSString *subAddDetail;
        NSString *hangSido;
        NSString *hangSigunGu;
        NSString *hangDong;
        NSString *oldOrNew;
        
        if(_addressType == addressSearchType_All)
        {
            if(section != 0)
            {
                poiDic = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataAddress"] objectAtIndexGC:indexPath.row];
                add = [poiDic objectForKeyGC:@"ADDRESS"];
                
                subAddSigu = stringValueOfDictionary(poiDic, @"M_NEWADDR1");
                subAddDetail = stringValueOfDictionary(poiDic, @"M_NEWADDR2");
                
                hangSido = stringValueOfDictionary(poiDic, @"SIDO");
                hangSigunGu = stringValueOfDictionary(poiDic, @"L_SIGUN_GU");
                hangDong = stringValueOfDictionary(poiDic, @"H_DONG");
                
                oldOrNew = @"Old";
            }
            else
            {
                poiDic = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataNewAddress"] objectAtIndexGC:indexPath.row];
                add = [poiDic objectForKeyGC:@"NEW_ADDR"];

                subAddSigu = stringValueOfDictionary(poiDic, @"M_ADDR1");
                subAddDetail = stringValueOfDictionary(poiDic, @"M_ADDR2");
                
                oldOrNew = @"New";
            }
            
        }
        else if(_addressType == addressSearchType_old)
        {
            poiDic = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataAddress"] objectAtIndexGC:indexPath.row];
            add = [poiDic objectForKeyGC:@"ADDRESS"];
 
            subAddSigu = stringValueOfDictionary(poiDic, @"M_NEWADDR1");
            subAddDetail = stringValueOfDictionary(poiDic, @"M_NEWADDR2");

            hangSido = stringValueOfDictionary(poiDic, @"SIDO");
            hangSigunGu = stringValueOfDictionary(poiDic, @"L_SIGUN_GU");
            hangDong = stringValueOfDictionary(poiDic, @"H_DONG");
            
            oldOrNew = @"Old";
        }
        else if (_addressType == addressSearchType_new)
        {
            poiDic = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataNewAddress"] objectAtIndexGC:indexPath.row];
            add = [poiDic objectForKeyGC:@"NEW_ADDR"];

            subAddSigu = stringValueOfDictionary(poiDic, @"M_ADDR1");
            subAddDetail = stringValueOfDictionary(poiDic, @"M_ADDR2");

            
            oldOrNew = @"New";
        }
        
        Coord poiCrd = CoordMake([[poiDic objectForKeyGC:@"X"] doubleValue], [[poiDic objectForKeyGC:@"Y"] doubleValue]);
        
        double xx = poiCrd.x;
        double yy = poiCrd.y;
        NSString *rdCd = stringValueOfDictionary(poiDic, @"RD_CD");
        //NSLog(@"%@, %f, %f", add, xx, yy);
        
        NSString *org_Db_Type = @"ADDR";
        
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@",add] forKey:@"LastExtendCellName"];
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%f",xx] forKey:@"LastExtendCellX"];
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setObject:[NSString stringWithFormat:@"%f",yy] forKey:@"LastExtendCellY"];
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@",org_Db_Type] forKey:@"LastExtendCellType"];
        
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@", add] forKey:@"LastExtendCellTelAddress"];
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@", rdCd] forKey:@"LastExtendRoadCode"];
        
        NSLog(@"%@ %@", subAddSigu, subAddDetail);
        
        
        // 서브주소 있는곳 보다가 없는곳 보면 서브주소가 남아있기 때문에 다음줄 추가
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary removeObjectForKey:@"LastExtendCellSubDetail"];
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary removeObjectForKey:@"LastExtendCellSubSubDetail"];
        
        if([subAddSigu isEqualToString:@""])
        {
            [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@", subAddDetail] forKey:@"LastExtendCellSubDetail"];
        }
        else if ([subAddDetail isEqualToString:@""])
        {
            [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@""] forKey:@"LastExtendCellSubDetail"];
        }
        else
        {
            
            [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@%@", subAddSigu ,subAddDetail] forKey:@"LastExtendCellSubDetail"];
        }
        
        // 지번주소일 때는 행정동주소도 필요
        if((_addressType == addressSearchType_All && section == 1) || _addressType == addressSearchType_old)
        {
            [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@ %@ %@", hangSido, hangSigunGu ,hangDong] forKey:@"LastExtendCellSubSubDetail"];
        }
        
        
        // rdcd 있다가 없는 곳 보면 남아있기 때문에!
        if([rdCd isEqualToString:@""])
        {
            [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@", rdCd] forKey:@"LastExtendRoadCode"];
        }
        
        // 새주소인지 구주소인지 판단
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setObject:[NSString stringWithFormat:@"%@", oldOrNew] forKey:@"AddressType"];
        
        if(section == 0 || (_addressType == addressSearchType_All && section == 1))
        {
            // 마지막꺼 확장시 내림
            if (self.view.frame.size.height - 115 < rect.origin.y)
                [_addressTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        
        
        //        _addressIndex = indexPath.row;
        //        [_jusoList reloadRowsAtIndexPaths:[_jusoList indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if ([tableView isKindOfClass:[UIBusStationTableView class]])
    {
        
        // 확장어쩌고저쩌고 이후 해당 셀 스크롤..
        CGRect rectVisible = [_busStationTableView rectForRowAtIndexPath:indexPath];
        
        CGRect rect = [_busStationTableView convertRect:rectVisible toView:self.view];
        NSMutableArray *reloadList = [[NSMutableArray alloc] init];
        
        for (NSIndexPath *currentPath in [_busStationTableView indexPathsForVisibleRows])
        {
            if(currentPath.row == _busStationIndex && _busStationIndex != indexPath.row)
                [reloadList addObject:currentPath];
            
        }
        
        _busStationIndex = _busStationIndex == indexPath.row ? -1 : (int)indexPath.row;
        
        [reloadList addObject:indexPath];
        //[_searchList reloadRowsAtIndexPaths:[_searchList indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
        [_busStationTableView reloadRowsAtIndexPaths:reloadList withRowAnimation:UITableViewRowAnimationNone];
        
        
        //        _busStationIndex = indexPath.row;
        //        [_busStationList reloadRowsAtIndexPaths:[_busStationList indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
        
        NSMutableDictionary *dic = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataPublicBusStation"] objectAtIndexGC:indexPath.row];
        
        NSLog(@"셀의 내용 : %@", dic);
        NSString *bstName = [dic objectForKeyGC:@"BST_NAME"];
        
        Coord poiCrd = CoordMake([[dic objectForKeyGC:@"BST_X"] doubleValue], [[dic objectForKeyGC:@"BST_Y"] doubleValue]);
        
        double xx = poiCrd.x;
        double yy = poiCrd.y;
        
        NSString *stId = [dic objectForKeyGC:@"STID"];
        NSString *org_Db_Type = @"TR_BUS";
        NSString *uniqueId = [dic objectForKeyGC:@"ST_UNIQUEID"];
        //NSLog(@"%@, %f, %f", bstName, xx, yy);
        NSString *add = @"";
        NSString *tel = @"";
        
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@",bstName] forKey:@"LastExtendCellName"];
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%f",xx] forKey:@"LastExtendCellX"];
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setObject:[NSString stringWithFormat:@"%f",yy] forKey:@"LastExtendCellY"];
        
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@",org_Db_Type] forKey:@"LastExtendCellType"];
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@",stId] forKey:@"LastExtendCellId"];
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@", uniqueId] forKey:@"LastExtendUniqueId"];
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setObject:[NSString stringWithFormat:@"%@", add] forKey:@"LastExtendCellTel"];
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setObject:[NSString stringWithFormat:@"%@", tel] forKey:@"LastExtendCellTelAddress"];
        
        // 마지막꺼 확장시 내림
        if (self.view.frame.size.height - 115 < rect.origin.y)
            [_busStationTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        
    }
    else if ([tableView isKindOfClass:[UIBusNumberTableView class]])
    {
        
        
        _busNumberIndex = (int)indexPath.row;
        
        
        if(_currentSearchTargetType != SearchTargetType_NONE)
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Popup_ClickBusNumber", @"")];
            return;
        }
        NSMutableDictionary *dicBusNum = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataPublicBusNumber"] objectAtIndexGC:indexPath.row];
        
        //NSLog(@"셀의 내용 : %@", dicBusNum);
        [_busNumTableView deselectRowAtIndexPath:indexPath animated:NO];
        
        NSString *LaneID = [dicBusNum objectForKeyGC:@"LANEID"];
        
        // 버스노선 상세 가자
        [[ServerConnector sharedServerConnection] requestBusNumberInfo:self action:@selector(finishBusNumberDetail:) laneId:LaneID];
        
    }
    else if ([tableView isKindOfClass:[UISubwayTableView class]])
    {
        
        // 확장어쩌고저쩌고 이후 해당 셀 스크롤..
        CGRect rectVisible = [_subwayTableView rectForRowAtIndexPath:indexPath];
        
        CGRect rect = [_subwayTableView convertRect:rectVisible toView:self.view];
        
        NSMutableArray *reloadList = [[NSMutableArray alloc] init];
        
        for (NSIndexPath *currentPath in [_subwayTableView indexPathsForVisibleRows])
        {
            if(currentPath.row == _subwayIndex && _subwayIndex != indexPath.row)
                [reloadList addObject:currentPath];
            
        }
        
        _subwayIndex = _subwayIndex == indexPath.row ? -1 : (int)indexPath.row;
        
        [reloadList addObject:indexPath];
        
        [_subwayTableView reloadRowsAtIndexPaths:reloadList withRowAnimation:UITableViewRowAnimationNone];
        
        
        NSMutableDictionary *dic = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataPublicSubwayStation"] objectAtIndexGC:indexPath.row];
        
        NSLog(@"셀의 내용 : %@", dic);
        
        NSString *sstName = [dic objectForKeyGC:@"SST_NAME"];
        NSString *sstLaneName = [dic objectForKeyGC:@"SUBWAY_LANENAME"];
        Coord poiCrd = CoordMake([[dic objectForKeyGC:@"SST_X"] doubleValue], [[dic objectForKeyGC:@"SST_Y"] doubleValue]);
        
        double xx = poiCrd.x;
        double yy = poiCrd.y;
        
        NSString *stId = [dic objectForKeyGC:@"STID"];
        NSString *org_Db_Type = @"TR";
        //NSLog(@"%@, %f, %f", sstName, xx, yy);
        
        NSString *addDo = [dic objectForKeyGC:@"DO"];
        NSString *addGu = [dic objectForKeyGC:@"GU"];
        NSString *addDong = [dic objectForKeyGC:@"DONG"];
        NSString *theme_code = @"0406";
        
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@",sstName] forKey:@"LastExtendCellName"];
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@",sstLaneName] forKey:@"LastExtendCellLaneName"];
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%f",xx] forKey:@"LastExtendCellX"];
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setObject:[NSString stringWithFormat:@"%f",yy] forKey:@"LastExtendCellY"];
        
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@",org_Db_Type] forKey:@"LastExtendCellType"];
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@",stId] forKey:@"LastExtendCellId"];
        
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@%@%@",addDo, addGu, addDong] forKey:@"LastExtendCellTelAddress"];
        [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary setValue:[NSString stringWithFormat:@"%@", theme_code] forKey:@"LastExtendCellTheme"];
        
        // 마지막꺼 확장시 내림
        if (self.view.frame.size.height - 115 < rect.origin.y)
            [_subwayTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        
        
    }
    // 같은이름다른지역 클릭
    else if ([tableView isKindOfClass:[UIResearchTableView class]])
    {
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        //NSMutableDictionary *dic = nil;
        NSString *juso = nil;
        // 참이면 새, 아님 구
        if([self oldAddressORNewAddressSelectReturnBool])
        {
            //dic = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataNewAddress"] objectAtIndexGC:indexPath.row];
            
            juso = [[_reSearchDic objectAtIndexGC:indexPath.row] objectForKeyGC:@"NEW_ADDR"];
        }
        else
        {
            //dic = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataAddress"] objectAtIndexGC:indexPath.row];
            //juso = [dic objectForKeyGC:@"ADDRESS"];
            
            //dic = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataAddress"] objectAtIndexGC:indexPath.row];
            //reCell.textLabel.text = [dic objectForKeyGC:@"ADDRESS"];
            juso = [[_reSearchDic objectAtIndexGC:indexPath.row] objectForKeyGC:@"ADDRESS"];
        }
        
        NSString *rQuery = (NSString *)[[oms.searchLocalDictionary objectForKeyGC:@"QueryResult"] objectForKeyGC:@"r_query"];
        
        if(!rQuery || [rQuery isEqualToString:@""])
        {
            rQuery= [[oms.searchLocalDictionary objectForKeyGC:@"Na_Result"] objectForKeyGC:@"r_query"];
        }
        
        [OllehMapStatus sharedOllehMapStatus].keyword = [NSString stringWithFormat:@"%@ %@", juso, rQuery];
        
        //[OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"%@", reSearchingKeyword]];
        keywordChange = YES;
        sameNameOtherPlaceCheck = YES;
        
        //        int page = 0;
        //        _page = page;
        
        
        [[ServerConnector sharedServerConnection] requestSearchPlaceAndAddress:self action:@selector(didFinishSearch_Place:) key:[OllehMapStatus sharedOllehMapStatus].keyword mapX:[MapContainer sharedMapContainer_Main].kmap.centerCoordinate.x mapY:[MapContainer sharedMapContainer_Main].kmap.centerCoordinate.y s:@"p" sr:@"RANK" p_startPage:0 a_startPage:0 n_startPage:0 indexCount:15 option:1];
        
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
        
        return;
    }
    
}
#pragma mark 싱글POI 지도
- (void)clickToSinglePOILocal:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    UIButton *singleBtn = (UIButton *)sender;
    
    int i = (int)singleBtn.tag;
    
    //NSLog(@"%@", oms.searchLocalDictionary);
    
    NSMutableDictionary *dicPlace = [[oms.searchLocalDictionary objectForKeyGC:@"DataPlace"] objectAtIndexGC:i];
    
    
    Coord poiCrd = CoordMake([[dicPlace objectForKeyGC:@"X"] doubleValue], [[dicPlace objectForKeyGC:@"Y"] doubleValue]);
    
    
    double xx = poiCrd.x;
    double yy = poiCrd.y;
    
    NSString *placeName = [dicPlace objectForKeyGC:@"NAME"];
    NSString *address = [dicPlace objectForKeyGC:@"ADDR"];
    
    NSString *classification = [dicPlace objectForKeyGC:@"UJ_NAME"];
    
    NSString *org_Db_Id = @"";
    NSString *org_Db_Type = [dicPlace objectForKeyGC:@"ORG_DB_TYPE"];
    NSString *theme = [dicPlace objectForKeyGC:@"THEME_CODE"];
    //NSString *freeCall = [dicPlace objectForKeyGC:@"STHEME_CODE"];
    NSString *freeCall = stringValueOfDictionary(dicPlace, @"STHEME_CODE");
    
    NSString *shapeType = stringValueOfDictionary(dicPlace, @"SHAPE_TYPE");
    NSString *fcNm = stringValueOfDictionary(dicPlace, @"FC_NM");
    NSString *id_Bgm = stringValueOfDictionary(dicPlace, @"ID_BGM");
    
    // 무료통화 있으면 저장
    //if([freeCall isEqualToString:@"PG1201000000008"])
    if( [freeCall rangeOfString:@"PG1201000000008"].location != NSNotFound )
    {
        //[oms.searchLocalDictionary setObject:freeCall forKey:@"LastExtendFreeCaller"];
    }
    else
    {
        //[oms.searchLocalDictionary setObject:@"" forKey:@"LastExtendFreeCaller"];
    }
    
    
    // 최근검색 저장(이름, 업종분류, x, y, 타입, id, 전번, 주소)
    
    NSMutableDictionary *placeDic = [NSMutableDictionary dictionary];
    
    // 싱글poi누를 때 최근검색에 저장하는데....장소검색일때 지하철, 버정, 다나옴.......아)
    // 지하철
    
    if([org_Db_Type isEqualToString:@"TR"] && [theme rangeOfString:@"0406"].length > 0)
    {
        [placeDic setObject:[NSNumber numberWithInt:Favorite_IconType_Subway] forKey:@"ICONTYPE"];
        org_Db_Type = @"TR";
    }
    // 버스
    else if ([org_Db_Type isEqualToString:@"TR"] && [theme rangeOfString:@"0407"].length > 0)
    {
        [placeDic setObject:[NSNumber numberWithInt:Favorite_IconType_BusStop] forKey:@"ICONTYPE"];
        org_Db_Type = @"TR_BUS";
    }
    // 그외엔 장소POI
    else
    {
        [placeDic setObject:[NSNumber numberWithInt:Favorite_IconType_POI] forKey:@"ICONTYPE"];
        
        if([org_Db_Type isEqualToString:@"TR"])
        {
            org_Db_Type = @"MP";
            org_Db_Id = [dicPlace objectForKeyGC:@"DOCID"];
        }
    }
    
    if ([org_Db_Type isEqualToString:@"OL"] || [org_Db_Type isEqualToString:@"MV"])
    {
        org_Db_Id = [dicPlace objectForKeyGC:@"DOCID"];
    }
    else
    {
        org_Db_Id = [dicPlace objectForKeyGC:@"ORG_DB_ID"];
    }
    
    NSString *tel = [dicPlace objectForKeyGC:@"TEL"];
    
    if(tel == nil)
        tel = @"";
    
    //NSLog(@"장소 : %@, 주소 : %@, x좌표 : %f, y좌표 : %f, 타입 : %@, Id : %@", placeName, address, xx, yy, org_Db_Type, org_Db_Id);
    
    [oms.searchResult reset]; // 검색결과 리셋
    [oms.searchResult setUsed:YES];
    [oms.searchResult setIsCurrentLocation:NO];
    [oms.searchResult setStrLocationName:placeName];
    [oms.searchResult setStrLocationAddress:address];
    [oms.searchResult setCoordLocationPoint:CoordMake(xx, yy)];
    [oms.searchResult setIndex:i+1];
    [oms.searchResult setStrType:org_Db_Type];
    [oms.searchResult setStrID:org_Db_Id];
    [oms.searchResult setStrTel:tel];
    // 20121017 추가
    [oms.searchResult setStrSTheme:freeCall];
    [oms.searchResult setStrShape:shapeType];
    [oms.searchResult setStrShapeFcNm:fcNm];
    [oms.searchResult setStrShapeIdBgm:id_Bgm];
    
    
    
    [placeDic setObject:placeName forKey:@"NAME"];
    [placeDic setObject:[oms ujNameSegment:classification] forKey:@"CLASSIFY"];
    [placeDic setValue:[NSNumber numberWithDouble:xx] forKey:@"X"];
    [placeDic setValue:[NSNumber numberWithDouble:yy] forKey:@"Y"];
    [placeDic setObject:org_Db_Type forKey:@"TYPE"];
    [placeDic setObject:org_Db_Id forKey:@"ID"];
    [placeDic setObject:tel forKey:@"TEL"];
    [placeDic setObject:address forKey:@"ADDR"];
    
    
    
    if(![shapeType isEqualToString:@""] && ![fcNm isEqualToString:@""] && ![id_Bgm isEqualToString:@""])
    {
        [placeDic setObject:shapeType forKey:@"SHAPE_TYPE"];
        [placeDic setObject:fcNm forKey:@"FCNM"];
        [placeDic setObject:id_Bgm forKey:@"ID_BGM"];
    }
    
    [oms addRecentSearch:placeDic];
    
    
    
    
    // 라인폴리곤 그리기
    if(![shapeType isEqualToString:@""] && ![fcNm isEqualToString:@""] && ![id_Bgm isEqualToString:@""])
    {
        [[ServerConnector sharedServerConnection] requestPolygonSearch:self action:@selector(finishedPolygonInfo:) table:fcNm loadKey:id_Bgm];
    }
    else
    {
        [MainViewController markingSinglePOI_RenderType:MapRenderType_SearchResult_SinglePOI category:MainMap_SinglePOI_Type_Normal animated:YES];
    }
}
- (void) finishedPolygonInfo:(id)request
{
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        if([(NSMutableDictionary *)[[OllehMapStatus sharedOllehMapStatus].linePolygonDictionary objectForKeyGC:@"LinePolygon"] count] == 0)
        {
            [MainViewController markingSinglePOI_RenderType:MapRenderType_SearchResult_SinglePOI category:MainMap_SinglePOI_Type_Line animated:YES];
 
        }
        else
        {
            [MainViewController markingLinePolygonPOI];
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
- (void)clickToSinglePOIAddress:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    UIButton *singleBtn = (UIButton *)sender;
    
    int i = (int)singleBtn.tag;
    
    
    NSMutableDictionary *dicAddress = [NSMutableDictionary dictionary];
    NSString *placeName = @"";
    //NSString *subAddSigu = nil;
    //NSString *subAddDetail = nil;
    if(_addressType == addressSearchType_All && i < 5)
    {
        dicAddress = [[oms.searchLocalDictionary objectForKeyGC:@"DataAddress"] objectAtIndexGC:i];
        placeName = [dicAddress objectForKeyGC:@"ADDRESS"];
        //subAddSigu = [dicAddress objectForKeyGC:@"M_NEW_ADDR1"];
        //subAddDetail = [dicAddress objectForKeyGC:@"M_NEWADDR2"];
    }
    else if (_addressType == addressSearchType_All && i > 5)
    {
        i -= 100;
        
        dicAddress = [[oms.searchLocalDictionary objectForKeyGC:@"DataNewAddress"] objectAtIndexGC:i];
        placeName = [dicAddress objectForKeyGC:@"NEW_ADDR"];
        //subAddSigu = [dicAddress objectForKeyGC:@"M_ADDR1"];
        //subAddDetail = [dicAddress objectForKeyGC:@"M_ADDR2"];
    }
    else if(_addressType == addressSearchType_old)
    {
        dicAddress = [[oms.searchLocalDictionary objectForKeyGC:@"DataAddress"] objectAtIndexGC:i];
        placeName = [dicAddress objectForKeyGC:@"ADDRESS"];
        //subAddSigu = [dicAddress objectForKeyGC:@"M_NEW_ADDR1"];
        //subAddDetail = [dicAddress objectForKeyGC:@"M_NEWADDR2"];
    }
    else if (_addressType == addressSearchType_new)
    {
        dicAddress = [[oms.searchLocalDictionary objectForKeyGC:@"DataNewAddress"] objectAtIndexGC:i];
        placeName = [dicAddress objectForKeyGC:@"NEW_ADDR"];
        //subAddSigu = [dicAddress objectForKeyGC:@"M_ADDR1"];
        //subAddDetail = [dicAddress objectForKeyGC:@"M_ADDR2"];
    }
    Coord poiCrd = CoordMake([[dicAddress objectForKeyGC:@"X"] doubleValue], [[dicAddress objectForKeyGC:@"Y"] doubleValue]);
    
    
    double xx = poiCrd.x;
    double yy = poiCrd.y;
    
    // 도로명주소
    NSString *roadCode = stringValueOfDictionary(dicAddress, @"RD_CD");
    
    
    [oms.searchResult reset]; // 검색결과 리셋
    [oms.searchResult setUsed:YES];
    [oms.searchResult setIsCurrentLocation:NO];
    [oms.searchResult setStrLocationName:placeName];
    [oms.searchResult setStrLocationAddress:placeName];
    [oms.searchResult setCoordLocationPoint:CoordMake(xx, yy)];
    [oms.searchResult setStrType:@"ADDR"];
    [oms.searchResult setIndex:i+1];
    [oms.searchResult setStrLocationRoadName:roadCode];
    
    NSString *mAddr2 = stringValueOfDictionary(dicAddress, @"M_ADDR2");
    
    [oms.searchResult setStrShape:![mAddr2 isEqualToString:@""] ? @"" : @"L"];
    
    
    NSMutableDictionary *addressDic = [NSMutableDictionary dictionary];
    
    // ver3테스트버그(지도보기 클릭시 id값이 널이라서 앱 사망 id값에 공백추가
    [addressDic setObject:@"" forKey:@"ID"];
    [addressDic setObject:placeName forKey:@"NAME"];
    //[addressDic setObject:classfication forKey:@"CLASSIFY"];
    [addressDic setValue:[NSNumber numberWithDouble:xx] forKey:@"X"];
    [addressDic setValue:[NSNumber numberWithDouble:yy] forKey:@"Y"];
    [addressDic setObject:@"ADDR" forKey:@"TYPE"];
    [addressDic setObject:@"" forKey:@"ADDR"];
    
    [addressDic setObject:[NSNumber numberWithInt:Favorite_IconType_POI] forKey:@"ICONTYPE"];
    [addressDic setObject:roadCode forKey:@"RD_CD"];
    
    [oms addRecentSearch:addressDic];
    
    NSString *shapePOI = stringValueOfDictionary(dicAddress, @"M_ADDR2");
    
    if([shapePOI isEqualToString:@""] && ![roadCode isEqualToString:@""])
    {
        
        
        [[ServerConnector sharedServerConnection] requestRoadNameSearch:self action:@selector(finishRoadNameSearchInfo:) roadCode:roadCode];
    }
    else
    {
        [MainViewController markingSinglePOI_RenderType:MapRenderType_SearchResult_SinglePOI category:MainMap_SinglePOI_Type_Normal animated:YES];
    }
}
- (void) finishRoadNameSearchInfo:(id)request
{
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        // 재수없게 결과값이 없을수도 있음
        if([(NSMutableDictionary *)[[OllehMapStatus sharedOllehMapStatus].roadNameDictionary objectForKeyGC:@"RoadCode"] count] == 0)
        {
            [MainViewController markingSinglePOI_RenderType:MapRenderType_SearchResult_SinglePOI category:MainMap_SinglePOI_Type_Line animated:YES];
        }
        else
        {
            [MainViewController markingRoadCodeSearch];
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
- (void)clickToSinglePOIBusStation:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    UIButton *singleBtn = (UIButton *)sender;
    
    int i = (int)singleBtn.tag;
    
    NSMutableDictionary *dicBus = [[oms.searchLocalDictionary objectForKeyGC:@"DataPublicBusStation"] objectAtIndexGC:i];
    
    Coord poiCrd = CoordMake([[dicBus objectForKeyGC:@"BST_X"] doubleValue], [[dicBus objectForKeyGC:@"BST_Y"] doubleValue]);
    
    
    double xx = poiCrd.x;
    double yy = poiCrd.y;
    
    NSString *placeName = [dicBus objectForKeyGC:@"BST_NAME"];
    NSString *stId = [dicBus objectForKeyGC:@"STID"];
    NSString *doo = [dicBus objectForKeyGC:@"BST_DO"];
    NSString *guu = [dicBus objectForKeyGC:@"BST_GU"];
    NSString *dong = [dicBus objectForKeyGC:@"BST_DONG"];
    //NSString *org_Db_Type = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellType"];
    
    NSString *uniqueId = [dicBus objectForKeyGC:@"ST_UNIQUEID"];
    
    NSLog(@"고유아디 : %@", uniqueId);
    
    NSString *before2 = nil;
    NSString *after3 = nil;
    
    if(![uniqueId isEqualToString:@"0"])
    {
        before2 = [uniqueId substringToIndex:2];
        after3 = [uniqueId substringFromIndex:2];
        
    }
    
    NSString *classfication = @"대중교통 > 버스정류장";
    
    NSString *address = [NSString stringWithFormat:@"%@%@%@", doo, guu, dong];
    NSString *tel = @"";
    NSLog(@"버스정류장 이름 : %@, 버정주소 : %@, x좌표 : %f, y좌표 : %f, 타입 : %@, Id : %@", placeName, address, xx, yy, @"TR_BUS", stId);
    
    [oms.searchResult reset]; // 검색결과 리셋
    [oms.searchResult setUsed:YES];
    [oms.searchResult setIsCurrentLocation:NO];
    if([uniqueId isEqualToString:@"0"])
    {
        [oms.searchResult setStrLocationName:placeName];
    }
    else
    {
        [oms.searchResult setStrLocationName:[NSString stringWithFormat:@"%@ [%@-%@]", placeName, before2, after3]];
        
    }
    [oms.searchResult setStrLocationAddress:address];
    [oms.searchResult setCoordLocationPoint:CoordMake(xx, yy)];
    [oms.searchResult setIndex:i+1];
    [oms.searchResult setStrType:@"TR_BUS"];
    [oms.searchResult setStrID:stId];
    [oms.searchResult setStrTel:tel];
    
    NSMutableDictionary *busDic = [NSMutableDictionary dictionary];
    
    [busDic setObject:placeName forKey:@"NAME"];
    
    if(![uniqueId isEqualToString:@"0"])
    {
        NSString *before2;
        NSString *after3;
        NSString *busUniqueId;
        before2 = [uniqueId substringToIndex:2];
        after3 = [uniqueId substringFromIndex:2];
        
        busUniqueId = [NSString stringWithFormat:@"[%@-%@]", before2, after3];
        
        [busDic setObject:busUniqueId forKey:@"SUBNAME"];
    }
    [busDic setValue:[NSNumber numberWithDouble:xx] forKey:@"X"];
    [busDic setValue:[NSNumber numberWithDouble:yy] forKey:@"Y"];
    [busDic setObject:classfication forKey:@"CLASSIFY"];
    [busDic setObject:@"TR_BUS" forKey:@"TYPE"];
    [busDic setObject:stId forKey:@"ID"];
    [busDic setObject:tel forKey:@"TEL"];
    [busDic setObject:address forKey:@"ADDR"];
    
    [busDic setObject:[NSNumber numberWithInt:Favorite_IconType_BusStop] forKey:@"ICONTYPE"];
    [oms addRecentSearch:busDic];

    [MainViewController markingSinglePOI_RenderType:MapRenderType_SearchResult_SinglePOI category:MainMap_SinglePOI_Type_Normal animated:YES];
}
- (void)clickToSinglePOISubwayStation:(id)sender
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    UIButton *singleBtn = (UIButton *)sender;
    
    int i = (int)singleBtn.tag;
    NSMutableDictionary *dicSub = [[oms.searchLocalDictionary objectForKeyGC:@"DataPublicSubwayStation"] objectAtIndexGC:i];
    
    
    Coord poiCrd = CoordMake([[dicSub objectForKeyGC:@"SST_X"] doubleValue], [[dicSub objectForKeyGC:@"SST_Y"] doubleValue]);
    
    
    double xx = poiCrd.x;
    double yy = poiCrd.y;
    
    NSString *placeName = [dicSub objectForKeyGC:@"SST_NAME"];
    NSString *address = [NSString stringWithFormat:@"%@ %@ %@", [dicSub objectForKeyGC:@"DO"], [dicSub objectForKeyGC:@"GU"], [dicSub objectForKeyGC:@"DONG"]];
    NSString *subway_Lane = [dicSub objectForKeyGC:@"SUBWAY_LANENAME"];
    
    //NSString *org_Db_Type = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellType"];
    NSString *classfication = @"대중교통 > 지하철역";
    NSString *stId = [dicSub objectForKeyGC:@"STID"];
    
    NSString *tel = @"";
    
    NSLog(@"지하철 내용 : %@", dicSub);
    
    NSLog(@"지하철역 이름 : %@ %@, 주소 : %@, x좌표 : %f, y좌표 : %f, 타입 : %@, ID : %@", placeName, subway_Lane, address, xx, yy, @"TR", stId);
    
    
    [oms.searchResult reset]; // 검색결과 리셋
    [oms.searchResult setUsed:YES];
    [oms.searchResult setIsCurrentLocation:NO];
    [oms.searchResult setStrLocationName:[NSString stringWithFormat:@"%@(%@)", placeName, subway_Lane]];
    [oms.searchResult setStrLocationAddress:address];
    [oms.searchResult setCoordLocationPoint:CoordMake(xx, yy)];
    [oms.searchResult setIndex:i+1];
    [oms.searchResult setStrType:@"TR"];
    [oms.searchResult setStrID:stId];
    [oms.searchResult setStrTel:tel];
    
    
    NSMutableDictionary *subwayDic = [NSMutableDictionary dictionary];
    
    [subwayDic setObject:placeName forKey:@"NAME"];
    [subwayDic setObject:classfication forKey:@"CLASSIFY"];
    [subwayDic setValue:[NSNumber numberWithDouble:xx] forKey:@"X"];
    [subwayDic setValue:[NSNumber numberWithDouble:yy] forKey:@"Y"];
    [subwayDic setObject:@"TR" forKey:@"TYPE"];
    [subwayDic setObject:stId forKey:@"ID"];
    [subwayDic setObject:tel forKey:@"TEL"];
    [subwayDic setObject:address forKey:@"ADDR"];
    [subwayDic setObject:[NSString stringWithFormat:@"(%@)", subway_Lane] forKey:@"SUBNAME"];
    [subwayDic setObject:[NSNumber numberWithInt:Favorite_IconType_Subway] forKey:@"ICONTYPE"];
    [oms addRecentSearch:subwayDic];
    
    [MainViewController markingSinglePOI_RenderType:MapRenderType_SearchResult_SinglePOI category:MainMap_SinglePOI_Type_Normal animated:YES];

}

#pragma mark -
#pragma mark - 버정, 지정 거리구하기
// 거리구하기
- (NSString *) getDistance:(NSMutableDictionary *)dic :(NSString *)type
{
    
    Coord poiCrd;
    NSString *distStr;
    
    if([type isEqualToString:@"bs"])
    {
        poiCrd = CoordMake([[dic objectForKeyGC:@"BST_X"] doubleValue], [[dic objectForKeyGC:@"BST_Y"] doubleValue]);
    }
    else if ([type isEqualToString:@"ss"])
    {
        poiCrd = CoordMake([[dic objectForKeyGC:@"SST_X"] doubleValue], [[dic objectForKeyGC:@"SST_Y"] doubleValue]);
    }
    else
    {
        poiCrd = CoordMake([[dic objectForKeyGC:@"X"] doubleValue], [[dic objectForKeyGC:@"Y"] doubleValue]);
    }
    
    Coord myCrd;
    
    myCrd.x = _nSearchX;
    myCrd.y = _nSearchY;
    
    
    int dist = CoordDistance(myCrd, poiCrd);
    
    if(dist > 1000)
    {
        dist = (dist / 1000);
        
        distStr = [[NSString stringWithFormat:@"%d", dist] stringByAppendingString:@"km"];
    }
    else {
        distStr = [[NSString stringWithFormat:@"%d", dist] stringByAppendingString:@"m"];
        
    }
    return distStr;
}
// 지도중심 내중심 세팅변경
- (void) coordSetMapCenterCoordinate :(BOOL)priority
{
    Coord myCrd;
    // 지도중심 기본 세팅
    if(priority == YES)
    {
        myCrd = [[MapContainer sharedMapContainer_Main].kmap centerCoordinate];
        [_mapOrMyLabel setText:@"지도 화면 중심"];
        [_mapOrMyLabel setFont:[UIFont systemFontOfSize:13]];
        
    }
    else
    {
        myCrd = [[MapContainer sharedMapContainer_Main].kmap getUserLocation];
        [_mapOrMyLabel setText:@"내 위치 중심"];
        [_mapOrMyLabel setFont:[UIFont systemFontOfSize:13]];
        
    }
    
    _nSearchX = myCrd.x;
    _nSearchY = myCrd.y;
    
}
#pragma mark -
#pragma mark - 구주소, 새주소 모두 있을 때 클릭
- (void) oldAddressBtnClick:(id)sender
{
    _addressType = addressSearchType_old;
    _moreChecker = YES;
    [self search:0 option:baseOption];
}
- (void) newAddressBtnClick:(id)sender
{
    _addressType = addressSearchType_new;
    
    _moreChecker = YES;
    [self search:0 option:baseOption];
}
#pragma mark -
#pragma mark - 페이징뷰 액션
- (void)prevBtnClick:(id)sender
{
    [self initWithIndex];
    [self search:_page-1 option:baseOption];
}

- (void)nextBtnClick:(id)sender
{
    [self initWithIndex];
    [self search:_page+1 option:baseOption];
}
#pragma mark -
#pragma mark - 재검색 관련
- (void) searchQuery
{
    ///////////////////
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    //    // 검색쿼리
    
    NSString *search1 = [oms poiQueryReturn];
    NSString *search3 = [oms r_QueryReturn];
    NSString *searchType = [[oms.searchLocalDictionary objectForKeyGC:@"SearchType"] objectForKeyGC:@"orgType"];
    NSString *lblText = nil;
    
    if([(NSMutableDictionary *)[oms.searchLocalDictionary objectForKey:@"SearchType"] count] > 1)
    {
        [_searchControllLbl setFrame:CGRectMake(0, 9, 320, 36)];
        [_searchControllLbl setNumberOfLines:1];
        [_searchControllLbl setBackgroundColor:[UIColor clearColor]];
        [_searchControllLbl setTextColor:convertHexToDecimalRGBA(@"19", @"a8", @"c7", 1.0)];
        [_searchControllLbl setFont:[UIFont boldSystemFontOfSize:13]];
        [_searchControllLbl setTextAlignment:NSTextAlignmentCenter];
        
        
        
        NSLog(@"타입보까? %@", [oms.searchLocalDictionary objectForKeyGC:@"SearchType"]);
        //NSLog(@"오엠에스 키워드 : %@", oms.keyword);
        if([searchType isEqualToString:@"H"])
        {
            [_placeTableView setFrame:CGRectMake(0, _tableY - 37, 320, self.view.frame.size.height - (_tableY - 37))];
            
            return;
            
        }
        else if(baseOption == 1 && [oms reSearchException])
        {
            if([searchType isEqualToString:@"A"] || [searchType isEqualToString:@"B"] || [searchType isEqualToString:@"G"])
                
            {
                lblText = [NSString stringWithFormat:@"%@ 근처 장소", oms.keyword];
            }
            else if([searchType isEqualToString:@"C"] || [searchType isEqualToString:@"D"] || [searchType isEqualToString:@"E"])
            {
                lblText = [NSString stringWithFormat:@"%@ 근처 %@", search1, search3];
            }
            
        }
        // 마포갈비처럼 예외로 들어오는 ㅡㅡ
        else if(baseOption == 1 && ![oms reSearchException])
        {
            lblText = [NSString stringWithFormat:@"현재위치 근처 %@", self.searchKeyword];
            
            if(exceptioner == NO)
            {
                exceptioner = YES;
                [self coordSetMapCenterCoordinate:NO];
                
                if([searchType isEqualToString:@"C"])
                    baseOption = 1;
                else
                baseOption = 2;
                
                [self search:0 option:baseOption];
                
                return;
            }
        }
        else if(baseOption == 2 && [oms reSearchException] && ([searchType isEqualToString:@"A"] || [searchType isEqualToString:@"B"] || [searchType isEqualToString:@"G"]))
        {
            lblText = [NSString stringWithFormat:@"현재위치 근처 %@", self.searchKeyword];
        }
        else if (baseOption == 2 && [oms reSearchException] && ([searchType isEqualToString:@"C"] ||[searchType isEqualToString:@"D"] || [searchType isEqualToString:@"E"]))
        {
            lblText = [NSString stringWithFormat:@"현재위치 근처 %@", self.searchKeyword];
        }
        else if(baseOption == 2 && ![oms reSearchException] && ([searchType isEqualToString:@"A"] || [searchType isEqualToString:@"B"] || [searchType isEqualToString:@"G"]))
        {
            lblText = [NSString stringWithFormat:@"현재위치 근처 %@", self.searchKeyword];
        }
        else if (baseOption == 2 && ![oms reSearchException] && ([searchType isEqualToString:@"C"] || [searchType isEqualToString:@"D"] || [searchType isEqualToString:@"E"]))
        {
            lblText = [NSString stringWithFormat:@"%@ 근처 %@", search1, search3];
        }
        else if(baseOption == 3 && [searchType isEqualToString:@"B"])
        {
            lblText = [NSString stringWithFormat:@"지번주소 %@ 근처 장소", search1];
        }
        else if(baseOption == 3 && [searchType isEqualToString:@"D"])
        {
            lblText = [NSString stringWithFormat:@"지번주소 %@ 근처 %@", search1, search3];
        }
        
        [_searchControllLbl setText:lblText afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
            NSRange colorRange = [lblText rangeOfString: @"근처" options: NSCaseInsensitiveSearch];
            if (colorRange.location != NSNotFound) {
                [mutableAttributedString addAttribute:(NSString *) kCTForegroundColorAttributeName value:(id)[[UIColor blackColor] CGColor] range:colorRange];
            }
            
            NSRange colorRange2 = [lblText rangeOfString: @"새주소" options: NSCaseInsensitiveSearch];
            if (colorRange2.location != NSNotFound) {
                [mutableAttributedString addAttribute:(NSString *) kCTForegroundColorAttributeName value:(id)[[UIColor blackColor] CGColor] range:colorRange2];
            }
            NSRange colorRange3 = [lblText rangeOfString: @"현재위치" options: NSCaseInsensitiveSearch];
            if (colorRange3.location != NSNotFound) {
                [mutableAttributedString addAttribute:(NSString *) kCTForegroundColorAttributeName value:(id)[[UIColor blackColor] CGColor] range:colorRange3];
            }
            NSRange colorRange4 = [lblText rangeOfString: @"장소" options: NSCaseInsensitiveSearch];
            if (colorRange4.location != NSNotFound) {
                [mutableAttributedString addAttribute:(NSString *) kCTForegroundColorAttributeName value:(id)[[UIColor blackColor] CGColor] range:colorRange4];
            }
            NSRange colorRange5 = [lblText rangeOfString: @"지번주소" options: NSCaseInsensitiveSearch];
            if (colorRange5.location != NSNotFound) {
                [mutableAttributedString addAttribute:(NSString *) kCTForegroundColorAttributeName value:(id)[[UIColor blackColor] CGColor] range:colorRange5];
            }
            
            
            return mutableAttributedString;
        }];
        
        [_searchControll addSubview:_searchControllLbl];
        
        int countGeneralAddress = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountAddress"] intValue];
        int countNewAddress = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountNewAddress"] intValue];
        
        // 리얼을 사용하겠음
        int realCount = [self oldAddressORNewAddressSelect:countGeneralAddress :countNewAddress];
        
        NSLog(@"realcount %d", realCount);
        
        NSLog(@"baseoption : %d", baseOption);
        
        // ver3 수정사항 : && 옵션추가...poi쿼리가 없을때 문답형검색 안보이게 테이블 올림
        
        if(realCount > 1)
        {
            [_placeNAddressView setFrame:CGRectMake(0, _placeNAddressView.frame.origin.y, 320, _placeNAddressY+45)];
            [_placeTableView setFrame:CGRectMake(0, _tableY+45, 320, self.view.frame.size.height - (_tableY+45))];
            
            UIView *reSearchView = [[UIView alloc] init];
            [reSearchView setFrame:CGRectMake(0, 74, 320, 45)];
            
            UIImageView *reSearchBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"align_bg.png"]];
            [reSearchBg setFrame:CGRectMake(0, 0, 320, 45)];
            [reSearchView addSubview:reSearchBg];
            
            
            UIButton *reSearchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [reSearchBtn setImage:[UIImage imageNamed:@"search_btn.png"] forState:UIControlStateNormal];
            [reSearchBtn setFrame:CGRectMake(11, 8, 298, 29)];
            [reSearchBtn addTarget:self action:@selector(reSearchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [reSearchView addSubview:reSearchBtn];
            
            [_placeNAddressView addSubview:reSearchView];
            
        }
        else
        {
            [_placeTableView setFrame:CGRectMake(0, OM_STARTY + 148, 320, self.view.frame.size.height - 148 - OM_STARTY)];
        }

    }
    // 답없다11
    else
    {
        
        search1 = [self prevPOIQueryReturn];
        search3 = [self prevR_QueryReturn];
        searchType = [[_prevMutableDictionary objectForKeyGC:@"SearchType"] objectForKeyGC:@"orgType"];
        
        if([searchType isEqualToString:@"H"])
        {
            [_placeTableView setFrame:CGRectMake(0, _tableY - 37, 320, self.view.frame.size.height - (_tableY - 37))];
            return;
        }
        else if(baseOption == 1 && [self PrevReSearchException])
        {
            if([searchType isEqualToString:@"A"] || [searchType isEqualToString:@"B"] || [searchType isEqualToString:@"G"])
                
            {
                lblText = [NSString stringWithFormat:@"%@ 근처 장소", oms.keyword];
            }
            else if([searchType isEqualToString:@"C"] || [searchType isEqualToString:@"D"] || [searchType isEqualToString:@"E"])
            {
                lblText = [NSString stringWithFormat:@"%@ 근처 %@", search1, search3];
            }
            else
            {
                //[OMMessageBox showAlertMessage:@"" :@"실패전도 없었을리가 없지"];
            }
        }
        else if(baseOption == 1 && ![self PrevReSearchException])
        {
            lblText = [NSString stringWithFormat:@"현재위치 근처 %@", self.searchKeyword];
            
            if(exceptioner == NO)
            {
                exceptioner = YES;
                [self coordSetMapCenterCoordinate:NO];
                [self search:0 option:baseOption];
                
                return;
            }
            
        }
        else if(baseOption == 2 && [self PrevReSearchException] && ([searchType isEqualToString:@"A"] || [searchType isEqualToString:@"B"] || [searchType isEqualToString:@"G"]))
        {
            lblText = [NSString stringWithFormat:@"현재위치 근처 %@", self.searchKeyword];
        }
        else if (baseOption == 2 && [self PrevReSearchException] && ([searchType isEqualToString:@"C"] ||[searchType isEqualToString:@"D"] || [searchType isEqualToString:@"E"]))
        {
            lblText = [NSString stringWithFormat:@"현재위치 근처 %@", self.searchKeyword];
        }
        else if(baseOption == 2 && ![self PrevReSearchException] && ([searchType isEqualToString:@"A"] || [searchType isEqualToString:@"B"] || [searchType isEqualToString:@"G"]))
        {
            lblText = [NSString stringWithFormat:@"현재위치 근처 %@", self.searchKeyword];
        }
        else if (baseOption == 2 && ![self PrevReSearchException] && ([searchType isEqualToString:@"C"] ||[searchType isEqualToString:@"D"] || [searchType isEqualToString:@"E"]))
        {
            lblText = [NSString stringWithFormat:@"%@ 근처 %@", search1, search3];
        }
        else if(baseOption == 3 && [searchType isEqualToString:@"B"])
        {
            lblText = [NSString stringWithFormat:@"지번주소 %@ 근처 장소", search1];
        }
        else if(baseOption == 3 && [searchType isEqualToString:@"D"])
        {
            lblText = [NSString stringWithFormat:@"지번주소 %@ 근처 %@", search1, search3];
        }
        
        [_searchControllLbl setText:lblText afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
            NSRange colorRange = [lblText rangeOfString: @"근처" options: NSCaseInsensitiveSearch];
            if (colorRange.location != NSNotFound) {
                [mutableAttributedString addAttribute:(NSString *) kCTForegroundColorAttributeName value:(id)[[UIColor blackColor] CGColor] range:colorRange];
            }
            
            NSRange colorRange2 = [lblText rangeOfString: @"새주소" options: NSCaseInsensitiveSearch];
            if (colorRange2.location != NSNotFound) {
                [mutableAttributedString addAttribute:(NSString *) kCTForegroundColorAttributeName value:(id)[[UIColor blackColor] CGColor] range:colorRange2];
            }
            NSRange colorRange3 = [lblText rangeOfString: @"현재위치" options: NSCaseInsensitiveSearch];
            if (colorRange3.location != NSNotFound) {
                [mutableAttributedString addAttribute:(NSString *) kCTForegroundColorAttributeName value:(id)[[UIColor blackColor] CGColor] range:colorRange3];
            }
            NSRange colorRange4 = [lblText rangeOfString: @"장소" options: NSCaseInsensitiveSearch];
            if (colorRange4.location != NSNotFound) {
                [mutableAttributedString addAttribute:(NSString *) kCTForegroundColorAttributeName value:(id)[[UIColor blackColor] CGColor] range:colorRange4];
            }
            NSRange colorRange5 = [lblText rangeOfString: @"지번주소" options: NSCaseInsensitiveSearch];
            if (colorRange5.location != NSNotFound) {
                [mutableAttributedString addAttribute:(NSString *) kCTForegroundColorAttributeName value:(id)[[UIColor blackColor] CGColor] range:colorRange5];
            }
            
            
            return mutableAttributedString;
        }];
        
        [_searchControll addSubview:_searchControllLbl];
        
        int countGeneralAddress = [[_prevMutableDictionary objectForKeyGC:@"TotalCountAddress"] intValue];
        int countNewAddress = [[_prevMutableDictionary objectForKeyGC:@"TotalCountNewAddress"] intValue];
        
        // 리얼을 사용하겠음
        int realCount = [self oldAddressORNewAddressSelect:countGeneralAddress :countNewAddress];
        
        NSLog(@"realcount %d", realCount);
        
        NSLog(@"baseoption : %d", baseOption);
        
        // ver3 수정사항 : && 옵션추가...poi쿼리가 없을때 문답형검색 안보이게 테이블 올림
        
        if(realCount > 1)
        {
            [_placeNAddressView setFrame:CGRectMake(0, _placeNAddressView.frame.origin.y, 320, _placeNAddressY+45)];
            [_placeTableView setFrame:CGRectMake(0, _tableY+45, 320, self.view.frame.size.height - (_tableY+45))];
            
            UIView *reSearchView = [[UIView alloc] init];
            [reSearchView setFrame:CGRectMake(0, 74, 320, 45)];
            
            UIImageView *reSearchBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"align_bg.png"]];
            [reSearchBg setFrame:CGRectMake(0, 0, 320, 45)];
            [reSearchView addSubview:reSearchBg];
            
            
            UIButton *reSearchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [reSearchBtn setImage:[UIImage imageNamed:@"search_btn.png"] forState:UIControlStateNormal];
            [reSearchBtn setFrame:CGRectMake(11, 8, 298, 29)];
            [reSearchBtn addTarget:self action:@selector(reSearchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [reSearchView addSubview:reSearchBtn];
            
            [_placeNAddressView addSubview:reSearchView];
            
        }
        else
        {
            [_placeTableView setFrame:CGRectMake(0, OM_STARTY + 148, 320, self.view.frame.size.height - 148 - OM_STARTY)];
        }
    }
    
}
- (NSString *) prevPOIQueryReturn
{
    
    // 검색쿼리
    NSString *poiQuery = [[_prevMutableDictionary objectForKeyGC:@"QueryResult"] objectForKeyGC:@"PoiQuery"];
    NSString *searchType = [[_prevMutableDictionary objectForKeyGC:@"SearchType"] objectForKeyGC:@"orgType"];
    
    if([searchType isEqualToString:@"D"])
    {
        poiQuery = [[_prevMutableDictionary objectForKeyGC:@"Na_Result"] objectForKeyGC:@"road_name"];
    }
    else if(!poiQuery || [poiQuery isEqualToString:@""])
    {
        poiQuery = [[_prevMutableDictionary objectForKeyGC:@"Na_Result"] objectForKeyGC:@"road_name"];
    }
    
    return poiQuery;
}
// R_QUERY 구하기
- (NSString *) prevR_QueryReturn
{
    NSString *rQuery = (NSString *)[[_prevMutableDictionary objectForKeyGC:@"QueryResult"] objectForKeyGC:@"r_query"];
    NSString *searchType = [[_prevMutableDictionary objectForKeyGC:@"SearchType"] objectForKeyGC:@"orgType"];
    
    if([searchType isEqualToString:@"D"])
    {
        rQuery = [[_prevMutableDictionary objectForKeyGC:@"Na_Result"] objectForKeyGC:@"r_query"];
    }
    else if(!rQuery || [rQuery isEqualToString:@""])
    {
        if([searchType isEqualToString:@"A"] || [searchType isEqualToString:@"B"] || [searchType isEqualToString:@"G"])
        {
            rQuery = @"장소";
        }
        else if([searchType isEqualToString:@"C"] || [searchType isEqualToString:@"D"] || [searchType isEqualToString:@"G"])
        {
            rQuery = [[_prevMutableDictionary objectForKeyGC:@"Na_Result"] objectForKeyGC:@"r_query"];
        }
    }
    
    if([rQuery isEqualToString:@""])
    {
        rQuery = @"장소";
    }
    
    return rQuery;
    
    
}
// 새주소, 구주소 판단(새주소가 있으면 새주소 없으면 구주소)
- (int) oldAddressORNewAddressSelect :(int)oldCount :(int)newCount
{
    int reallyCount = 0;
    
    // 둘다 0보다 크면(구주소, 새주소 일때는 새주소)
    if(oldCount > 0 && newCount > 0)
        reallyCount = newCount;
    // 일반이 0보다 크면 일반
    else if(oldCount > 0)
        reallyCount = oldCount;
    // 새주소가 0보다 크면 새주소
    else if(newCount > 0)
        reallyCount = newCount;
    
    return reallyCount;
}
// 구주소인가 새주소인가? YES는 새주소
- (BOOL) oldAddressORNewAddressSelectReturnBool
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    int oldCount = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountAddress"] intValue];
    int newCount = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountNewAddress"] intValue];
    
    // 둘다 0보다 크면(구주소, 새주소 일때는 새주소)
    if(oldCount > 0 && newCount > 0)
        return YES;
    // 일반이 0보다 크면 일반
    else if(oldCount > 0)
        return NO;
    // 새주소가 0보다 크면 새주소
    else
        return YES;
}
-(BOOL) PrevReSearchException
{
    NSString *option = [[_prevMutableDictionary objectForKeyGC:@"SearchType"] objectForKeyGC:@"option"];
    NSString *use_option = [[_prevMutableDictionary objectForKeyGC:@"SearchType"] objectForKeyGC:@"use_option"];
    
    if([option isEqualToString:use_option])
        return TRUE;
    else
        return FALSE;
}
#pragma mark -
#pragma mark - UIActionSheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case 0:
            if(buttonIndex == [actionSheet cancelButtonIndex])
            {
                //NSLog(@"취소 Click..");
            }
            else if ( buttonIndex == 0)
            {
                [self coordSetMapCenterCoordinate:YES];
                [self search:0 option:baseOption];
            }
            else if ( buttonIndex == 1)
            {
                [self coordSetMapCenterCoordinate:NO];
                [self search:0 option:baseOption];
            }
            
            break;
        case 1:
            if(buttonIndex == [actionSheet cancelButtonIndex])
            {
                
            }
            else if ( buttonIndex == 0)
            {
                if([(NSMutableDictionary *)[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"SearchType"] count] < 1)
                {
                    if([self PrevReSearchException])
                    {
                        willBaseOption = baseOption;
                        baseOption = 1;
                    }
                    else
                    {
                        willBaseOption = baseOption;
                        baseOption = 2;
                    }
                }
                else
                {
                if([[OllehMapStatus sharedOllehMapStatus] reSearchException])
                {
                    willBaseOption = baseOption;
                    baseOption = 1;
                }
                else
                {
                    willBaseOption = baseOption;
                    baseOption= 2;
                }
                }
                
                
                [self coordSetMapCenterCoordinate:YES];
                
                [self search:0 option:baseOption];
                
            }
            else if ( buttonIndex == 1)
            {
                if([(NSMutableDictionary *)[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"SearchType"] count] < 1)
                {
                    if([self PrevReSearchException])
                    {
                        willBaseOption = baseOption;
                        baseOption = 2;
                    }
                    else
                    {
                        willBaseOption = baseOption;
                        baseOption = 1;
                    }
                }
                else
                {
                    if([[OllehMapStatus sharedOllehMapStatus] reSearchException])
                    {
                    willBaseOption = baseOption;
                    baseOption = 2;
                    }
                    else
                    {
                    willBaseOption = baseOption;
                    baseOption = 1;
                    }
                }
                
                [self coordSetMapCenterCoordinate:NO];
                [self search:0 option:baseOption];
                
            }
            
            break;
            
        case 2:
            if(buttonIndex == [actionSheet cancelButtonIndex])
            {
                //NSLog(@"취소 Click..");
            }
            else if ( buttonIndex == 0)
            {
                willBaseOption = baseOption;
                baseOption = 1;
                [self coordSetMapCenterCoordinate:YES];
                [self search:0 option:baseOption];
                
            }
            else if ( buttonIndex == 1)
            {
                willBaseOption = baseOption;
                baseOption = 2;
                [self coordSetMapCenterCoordinate:NO];
                [self search:0 option:baseOption];
                
            }
            else if ( buttonIndex == 2)
            {
                [self coordSetMapCenterCoordinate:YES];
                willBaseOption = baseOption;
                baseOption = 3;
                [self search:0 option:baseOption];
            }
            break;
        default:
            break;
    }
    
}
#pragma mark -
#pragma mark - 같은이름 다른지역
// 같은이름 다른지역 클릭
- (void) reSearchBtnClick:(id)sender
{
    // 같은이름 다른지역 선택 팝업 초기화
    for (UIView *subview in _vwreSearchContainer.subviews)
    {
        [subview removeFromSuperview];
    }
    [_vwreSearchContainer removeFromSuperview];

    [self reSearchRequest:baseOption];
    
}
// 주소리스트 가져옴
- (void) reSearchRequest:(int)option
{
    
    [[ServerConnector sharedServerConnection] requestSearchPlaceAndAddress:self action:@selector(didFinishreSearchRequest:) key:[OllehMapStatus sharedOllehMapStatus].keyword mapX:_nSearchX mapY:_nSearchY s:@"an" sr:@"RANK" p_startPage:0 a_startPage:0 n_startPage:0 indexCount:100 option:option];
}
- (void) didFinishreSearchRequest:(id)request
{
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        int oldAddCount = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountAddress"] intValue];
        int newAddCount = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountNewAddress"] intValue];
        
        _sameNameOtherPlaceCount = [self oldAddressORNewAddressSelect:oldAddCount :newAddCount];
        
        // 팝업그리기
        [self popUpDrawing];
        
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

// 팝업 그리는 부분
- (void) popUpDrawing
{
    // 팝업이미지
    UIImageView *reSearchPopUpViewBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_bg.png"]];
    
    // 팝업뷰
    UIView *reSearchPopUpView = [[UIView alloc] init];
    [reSearchPopUpView setFrame:CGRectMake(116/2, 202/2, 410/2, 552/2)];
    [reSearchPopUpView setBackgroundColor:[UIColor clearColor]];
    
    [reSearchPopUpViewBg setFrame:CGRectMake(0, 0, 410/2, 552/2)];
    [reSearchPopUpView addSubview:reSearchPopUpViewBg];
    
    
    //nTotal = 100;
    nPage = 1;
    
    // 타이틀 렌더링
    {
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 410/2, 62/2)];
        
        UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(4/2 + 20/2, 16/2, 310/2, 16)];
        [titleLbl setFont:[UIFont systemFontOfSize:16]];
        [titleLbl setText:@"같은이름 다른지역"];
        [titleLbl setTextColor:convertHexToDecimalRGBA(@"ff", @"51", @"5e", 1.0)];
        [titleView addSubview:titleLbl];
        
        UIButton *titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(4/2 + 348/2, 10/2, 40/2, 40/2)];
        [titleBtn setImage:[UIImage imageNamed:@"btn_close.png"] forState:UIControlStateNormal];
        [titleView addSubview:titleBtn];
        [titleBtn addTarget:self action:@selector(popUpCancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *titleUnderLine = [[UIImageView alloc] initWithFrame:CGRectMake(4/2, 60/2, 402/2, 2/2)];
        [titleUnderLine setImage:[UIImage imageNamed:@"popup_title_line.png"]];
        [titleView addSubview:titleUnderLine];
        
        [reSearchPopUpView addSubview:titleView];
    }

    
    // 라베에엘
    UILabel *lbl = [[UILabel alloc] init];
    [lbl setFrame:CGRectMake(4/2, 62/2, 402/2, 90/2)];
    [lbl setText:@"같은이름 다른지역"];
    [lbl setBackgroundColor:convertHexToDecimalRGBA(@"d8", @"d8", @"d8", 1.0)];
    [lbl setFont:[UIFont systemFontOfSize:15]];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [reSearchPopUpView addSubview:lbl];
    
    
    // 주소 들어있는 테이블
    if(_sameNameOtherPlaceCount > 99)
    {
        _reSearchTableView.tableFooterView = _moreView;
    }
    
    
    [reSearchPopUpView addSubview:_reSearchTableView];
    
    // 취소버튼
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(116/2, 460/2, 176/2, 64/2)];
    [cancelBtn setImage:[UIImage imageNamed:@"popup_btn_cancel.png"] forState:UIControlStateNormal];
    [cancelBtn setImage:[UIImage imageNamed:@"popup_btn_cancel_pressed.png"] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(popUpCancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [reSearchPopUpView addSubview:cancelBtn];
    
    [_vwreSearchContainer addSubview:reSearchPopUpView];
    
    
    [self moreRefresh];
    
    [self.view addSubview:_vwreSearchContainer];
}
// 100개가 넘어가나??
- (void) moreRefresh
{
    if(nPage < 2)
    {
        for( int i = 0; i < maxPage; i++) {
            if( (i+maxPage*(nPage-1)) < _sameNameOtherPlaceCount)
            {
                NSDictionary *stmp = nil;
                if([self oldAddressORNewAddressSelectReturnBool])
                {
                    stmp = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataNewAddress"] objectAtIndex:(i+maxPage*(nPage-1))];
                }
                else
                {
                    stmp = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataAddress"] objectAtIndex:(i+maxPage*(nPage-1))];
                }
                //NSLog(@"%d", i+maxPage*(nPage-1));
                [_reSearchDic addObject:stmp];
            }
            else
                break;
        }
        [_reSearchTableView reloadData];
        [_reSearchTableView setContentOffset:CGPointMake(0, 0)];
    }
    else
    {
        [self reSearchRequest100More :baseOption page:100];
    }
    
}
- (void) reSearchRequest100More :(int)option page:(int)startPage
{
    
    [[ServerConnector sharedServerConnection] requestSearchPlaceAndAddress:self action:@selector(didFinishreSearchRequest100More:) key:[OllehMapStatus sharedOllehMapStatus].keyword mapX:_nSearchX mapY:_nSearchY s:@"an" sr:@"RANK" p_startPage:0 a_startPage:(int)nPage-1 n_startPage:(int)nPage-1 indexCount:100 option:option];
}
- (void) didFinishreSearchRequest100More:(id)request
{
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        
        for( int i = 0; i < maxPage; i++)
        {
            if( (i+maxPage*(nPage-1)) < _sameNameOtherPlaceCount)
            {
                NSDictionary *stmp = nil;
                if([self oldAddressORNewAddressSelectReturnBool])
                {
                    stmp = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataNewAddress"] objectAtIndex:i];
                }
                else
                {
                    stmp = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataAddress"] objectAtIndex:i];
                }
                
                //NSLog(@"%d", i+maxPage*(nPage-1));
                
                [_reSearchDic addObject:stmp];
            }
            else
            {
                _reSearchTableView.tableFooterView = nil;
                break;
            }
        }
        
        [_reSearchTableView reloadData];
        
    }
}
- (void) moreClick:(id)sender
{
    nPage++;
    [self moreRefresh];
}
- (void) popUpCancelBtnClick:(id)sender
{
    [_reSearchTableView removeFromSuperview];
    for (UIView *subview in _vwreSearchContainer.subviews)
    {
        [subview removeFromSuperview];
    }
    [_reSearchDic removeAllObjects];
    [_vwreSearchContainer removeFromSuperview];
}
- (void) onVoiceKeywordCell_Down:(id)sender
{
    UIControl* cell = (UIControl*)sender;
    [cell setBackgroundColor:convertHexToDecimalRGBA(@"D9", @"F4", @"FF", 1.0)];
}
- (void) onVoiceKeywordCell_Up:(id)sender
{
    UIControl* cell = (UIControl*)sender;
    [cell setBackgroundColor:[UIColor whiteColor]];
}


- (void) reRecognize:(id)sender
{
        OMNavigationController *nc = [OMNavigationController sharedNavigationController];
        VoiceSearchViewController *prevsVC = (VoiceSearchViewController*)[nc.viewControllers objectAtIndexGC:nc.viewControllers.count-2];
        int prevsSearchType = prevsVC.currentSearchTargetType;
        [nc popToViewController:[nc.viewControllers objectAtIndexGC:nc.viewControllers.count-3] animated:NO];
    VoiceSearchViewController *vsvc = [self.storyboard instantiateViewControllerWithIdentifier:@"VoiceView"];
        [vsvc setCurrentSearchTargetType:prevsSearchType];
        [nc pushViewController:vsvc animated:NO];
    
}

- (void) closeClick:(id)sender
{
    // MIK.geun :: 20120813 // 음성검색 유사키워드 선택 팝업창 "닫기" 버튼에 대한 조건문 추가됨.
    //** 검색결과가 0보다 큰 경우라면 노멀한 상태로 판단, 0이면 검색 실패후 팝업으로 돌아온 상태로 판단.
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    int countPlace, countAddress, countPublicBs, countPublicBn, countPublicSs, countPublic, countTotal;
    countPlace =  [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountPlace"] intValue];
    countAddress = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountAddress"] intValue];
    countPublicBs = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountPublicBusStation"] intValue];
    countPublicBn = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountPublicBusNumber"] intValue];
    countPublicSs = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountPublicSubwayStation"] intValue];
    countPublic = countPublicBs + countPublicBn + countPublicSs;
    countTotal = countPlace + countAddress + countPublic;
    
    // 팝업창 띄운뒤 바로 닫기 창을 눌렀을 때  (검색결과가 0보다 큰 상태로 유지)
    if (countTotal > 0)
    {
        // 음성인식 키워드 선택 팝업 컨테이너 제거
        for (UIView *subview in _vwVoiceKeywordSelectorContainer.subviews)
        {
            [subview removeFromSuperview];
        }
        [_vwVoiceKeywordSelectorContainer removeFromSuperview];
    }
    // 검색결과가 0 이하인 경우는 무조건 현재 창(뷰컨트롤러) 닫고 검색화면으로 돌려야 한다.
    else
    {
        OMNavigationController *nc = [OMNavigationController sharedNavigationController];
        // 뷰컨트롤러에 쌓여있는 검색화면 찾기
        for (int i=(int)nc.viewControllers.count-1; i >= 0; i--)
        {
            UIViewController *prevSearchVC = [nc.viewControllers objectAtIndexGC:i];
            if ([prevSearchVC isKindOfClass:[SearchViewController class]] )
            {
                [nc popToViewController:prevSearchVC animated:NO];
                return;
            }
        }
        // 여기까지 왔으면 ,, 나도 모르겄다 무조건 2단계 전으로 이동..
        [nc popToViewController:[nc.viewControllers objectAtIndexGC:nc.viewControllers.count-3] animated:NO];
    }
}

- (void) searchVoiceKeyword:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    UIControl *vwCell = (UIControl*)sender;
    
    // 선택한 셀 배경 원래대로 돌리기
    [vwCell setBackgroundColor:[UIColor whiteColor]];
    
    // 선택한 키워드
    NSString *keyword = [oms.voiceSearchArray objectAtIndexGC:vwCell.tag];
    oms.keyword = keyword;
    
    //  기존검색결과 클리어
    [oms resetLocalSearchDictionary:@"Place"];
    [oms resetLocalSearchDictionary:@"Address"];
    [oms resetLocalSearchDictionary:@"PublicBusStation"];
    [oms resetLocalSearchDictionary:@"PublicBusNumber"];
    [oms resetLocalSearchDictionary:@"PublicSubwayStation"];
    
    // 장소검색먼저
    [[ServerConnector sharedServerConnection] requestSearchPlaceAndAddress:self action:@selector(didFinishSearch_Place:) key:oms.keyword mapX:[MapContainer sharedMapContainer_Main].kmap.centerCoordinate.x mapY:[MapContainer sharedMapContainer_Main].kmap.centerCoordinate.y s:@"p" sr:@"RANK" p_startPage:0 a_startPage:0 n_startPage:0 indexCount:15 option:1];
}

- (void) didFinishSearch_Place :(id)request
{
    // 장소검색 성공했으면 주소검색은 0로 카운트만 검색 / 장소검색 성공했으나 데이터 없으면 주소검색 15카운트검색
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        int countPlace = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountPlace"] intValue];
        
        // 장소 검색결과에 따라  실제데이터 or 카운트 처리
        int requestAddressCount = 15;
        if  ( countPlace > 0 ) requestAddressCount = 0;
        [[ServerConnector sharedServerConnection] requestSearchPlaceAndAddress:self action:@selector(didFinishSearch_Address:) key:oms.keyword mapX:[MapContainer sharedMapContainer_Main].kmap.centerCoordinate.x mapY:[MapContainer sharedMapContainer_Main].kmap.centerCoordinate.y s:@"an" sr:@"RANK" p_startPage:0 a_startPage:0 n_startPage:0 indexCount:requestAddressCount option:1];
        
    }
    else if([[OllehMapStatus sharedOllehMapStatus] getNetworkStatus] == OMReachabilityStatus_disconnected)
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_NetworkException", @"")];
    }
    // 검색중 오류 발생했으면 모든 검색 중단,
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}
- (void) didFinishSearch_Address :(id)request
{
    // 주소검색까지 성공했으면 버스정류장 검색
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        if([oms number5VaildCheck:oms.keyword] || [oms uniqueVaildCheck:oms.keyword])
        {
            [[ServerConnector sharedServerConnection] requestSearchPublicBusStationUnique:self action:@selector(didFinishSearch_PublicBusStation:) UniqueId:oms.keyword];
        }
        else
        {
            [[ServerConnector sharedServerConnection] requestSearchPublicBusStation:self action:@selector(didFinishSearch_PublicBusStation:) Name:oms.keyword ViewCnt:15 Page:0];
        }
    }
    else if([[OllehMapStatus sharedOllehMapStatus] getNetworkStatus] == OMReachabilityStatus_disconnected)
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_NetworkException", @"")];
    }
    // 검색중 오류 발생했으면 모든 검색 중단,
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}
- (void) didFinishSearch_PublicBusStation :(id)request
{
    // 버스정류장 검색 성공했으면 버스노선 검색
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        [[ServerConnector sharedServerConnection] requestSearchPublicBusNumber:self action:@selector(didFinishSearch_PublicBusNumber:) key:oms.keyword startPage:0 indexCount:15];
    }
    // 검색중 오류 발생했으면 모든 검색 중단,
    else if([[OllehMapStatus sharedOllehMapStatus] getNetworkStatus] == OMReachabilityStatus_disconnected)
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_NetworkException", @"")];
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}
- (void) didFinishSearch_PublicBusNumber :(id)request
{
    // 버스노선 검색 성공했으면 지하철 검색
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        if(keywordChange)
        {
            [[ServerConnector sharedServerConnection] requestSearchPublicSubwayStation:self action:@selector(didFinishSearchAll:) Name:oms.keyword];
        }
        else
            [[ServerConnector sharedServerConnection] requestSearchPublicSubwayStation:self action:@selector(didFinishSearch_PublicSubwayStation:) Name:oms.keyword];
        
    }
    // 검색중 오류 발생했으면 모든 검색 중단,
    else if([[OllehMapStatus sharedOllehMapStatus] getNetworkStatus] == OMReachabilityStatus_disconnected)
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_NetworkException", @"")];
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}
- (void) didFinishSearch_PublicSubwayStation :(id)request
{
    // 지하철검색 까지 성공햇으면 모든검색 종료 /// 결과에 따라 처리
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        // 검색결과 카운트 계산
        int countPlace, countAddress, countPublicBs, countPublicBn, countPublicSs, countPublic, countTotal;
        countPlace =  [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountPlace"] intValue];
        countAddress = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountAddress"] intValue];
        countPublicBs = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountPublicBusStation"] intValue];
        countPublicBn = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountPublicBusNumber"] intValue];
        countPublicSs = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountPublicSubwayStation"] intValue];
        countPublic = countPublicBs + countPublicBn + countPublicSs;
        countTotal = countPlace + countAddress + countPublic;
        
        // 검색결과 한개라도 존재하면 화면 새로 그림
        if (countTotal > 0)
        {
            OMNavigationController *nc = [OMNavigationController sharedNavigationController];
            [nc popViewControllerAnimated:NO];
            
            SearchResultViewController *srvc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchResultView"];
            [srvc setCurrentSearchTargetType:self.currentSearchTargetType];
            [srvc setSearchKeyword:oms.keyword];
            [nc pushViewController:srvc animated:NO];
        }
        // 경고메세지 노출
        else
        {
            // 검색결과가 없습니다.
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailed", @"")];
        }
        
    }
    // 검색중 오류 발생했으면 모든 검색 중단,
    else if([[OllehMapStatus sharedOllehMapStatus] getNetworkStatus] == OMReachabilityStatus_disconnected)
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_NetworkException", @"")];
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}

- (IBAction)multiMapBtnClick:(id)sender
{
    {
        switch (_topType)
        {
            case topSelectedType_place:
            {
                [MainViewController markingMultiPOI_RenderType:0 animated:NO];
            }
                break;
                // 주소일땐 구주소인지, 새주소인지?
            case topSelectedType_address:
            {
                switch (_addressType)
                {
                    case addressSearchType_old:
                    {
                        [MainViewController markingMultiPOI_RenderType:1 animated:NO];
                    }
                        break;
                    case addressSearchType_new:
                    {
                        [MainViewController markingMultiPOI_RenderType:4 animated:NO];
                    }
                        break;
                    default:
                        break;
                }
            }
                
            case topSelectedType_public:
            {
                switch (_commonRadioType) {
                    case commonRadioButtonType_busStation:
                    {
                        [MainViewController markingMultiPOI_RenderType:2 animated:NO];
                    }
                        break;
                    case commonRadioButtonType_subWay:
                    {
                        [MainViewController markingMultiPOI_RenderType:3 animated:NO];
                        
                    }
                        break;
                    default:
                        break;
                        
                }
            }
                break;
            default:
                break;
        }
        
    }
    
}
// 장소테이블에서 상세가자
- (void) generalDetail:(id)sender
{
    // 상세 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/search_result/detail"];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    // 마지막클릭한 타입, ID, didCode, 주소
    NSString *type = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellType"];
    NSString *masterID = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellId"];
    NSString *didCode = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellDidCode"];
    NSString *theme = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellTheme"];
    
    
    NSLog(@"masterID = %@ \n didCode = %@ \n type = %@ \n theme = %@", masterID, didCode, type, theme);
    // 기름
    if([type isEqualToString:@"OL"])
    {
        /**
         @MethodDescription
         GW. POI상세
         /v1/search/PoiInfo.json?POI_ID=%@
         @MethodParams
         didCode(DID_CODE) [POI_ID]
         @MethodMehotdReturn
         poi상세정보
         */
        
        
        //NSLog(@"DID_CODE : %@ 로 POI상세 API GO", oilID);
        [[ServerConnector sharedServerConnection] requestPoiDetailAtPoiId:self action:@selector(finishRequestoilDetail:) poiId:didCode];
    }
    // 영화
    else if ([type isEqualToString:@"MV"])
    {
        /**
         @MethodDescription
         GW. POI상세
         /v1/search/PoiInfo.json?POI_ID=%@
         @MethodParams
         didCode(DID_CODE) [POI_ID]
         @MethodMehotdReturn
         poi상세정보
         */
        
        [[ServerConnector sharedServerConnection] requestPoiDetailAtPoiId:self action:@selector(finishRequestMovieDetailAtPoiId:) poiId:didCode];
    }
    
    // 지하철
    else if ([type isEqualToString:@"TR"] && [theme rangeOfString:@"0406"].length > 0)
    {
        
        /**
         @MethodDescription
         GW. 지하철 상세
         /v1/masstransit/TrafficSubStationInfo.json?STID=%@
         @MethodParams
         masterId(ORG_DB_ID) [STID]
         @MethodMehotdReturn
         지하철 상세정보
         */
        
        [[ServerConnector sharedServerConnection] requestSubStation:self action:@selector(finishRequestSubwayDetail:) stationId:masterID];
        
    }
    // 버스(장소에서 버정이 나옴....)
    else if ([type isEqualToString:@"TR"] && [theme rangeOfString:@"0407"].length > 0)
    {
        
        /**
         @MethodDescription
         GW. 버스정류장 상세
         /v1/masstransit/BusStation.json?STID=%@
         @MethodParams
         masterId(ORG_DB_ID) [STID]
         @MethodMehotdReturn
         버스정류장 상세정보
         */
        
        
        [[ServerConnector sharedServerConnection] requestBusStationInfoStid:self action:@selector(finishRequestBusDetail:) stId:masterID];
    }
    // 버스(강제 타입 고정, 지하철과 버스 구분이 안되기 때문
    else if ([type isEqualToString:@"TR_BUS"])
    {
        
        /**
         @MethodDescription
         GW. 버스정류장 상세
         /v1/masstransit/BusStation.json?STID=%@
         @MethodParams
         masterId(ORG_DB_ID) [STID]
         @MethodMehotdReturn
         버스정류장 상세정보
         */
        
        [[ServerConnector sharedServerConnection] requestBusStationInfoStid:self action:@selector(finishRequestBusDetail:) stId:masterID];
        
    }
    // 와이파이(나중에 쓸듯?)
    else if ([type isEqualToString:@"WI"])
    {
    }
    
    // MP 포함해서 그 외....
    else {
        
        /**
         @MethodDescription
         GW. POI상세
         /v1/search/PoiInfo.json?POI_ID=%@
         @MethodParams
         masterId(ORG_DB_ID) [POI_ID]
         @MethodMehotdReturn
         poi상세정보
         */
        
        [[ServerConnector sharedServerConnection] requestPoiDetailAtPoiId:self action:@selector(finishRequestPoiDetailAtPoiId:) poiId:masterID];
        
    }
    
}
// 버정테이블에서 버정가자
- (void) busStationDetail:(id)sender
{
    // 상세 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/search_result/detail"];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    // 마지막클릭한 타입, ID, didCode, 주소
    
    NSString *masterID = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellId"];
    
    
    
    /**
     @MethodDescription
     GW. 버스정류장 상세
     /v1/masstransit/BusStation.json?STID=%@
     @MethodParams
     masterId(ORG_DB_ID) [STID]
     @MethodMehotdReturn
     버스정류장 상세정보
     */
    
    //[[ServerConnector sharedServerConnection] requestBusStation:self action:@selector(finishRequestBusDetail:) stationId:masterID];
    [[ServerConnector sharedServerConnection] requestBusStationInfoStid:self action:@selector(finishRequestBusDetail:) stId:masterID];
}
// 주소테이블에서 주소가자
- (void) addressDetail:(id)sender
{
    // 상세 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/search_result/detail"];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    // 마지막클릭한 타입, ID, didCode, 주소
    //NSString *type = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellType"];
    //NSString *masterID = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellId"];
    //NSString *didCode = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellDidCode"];
    //NSString *theme = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellTheme"];
    NSString *Addadd = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellTelAddress"];
    NSString *subAddDetail = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellSubDetail"];
    NSString *subSubAddDetail = stringValueOfDictionary(oms.searchLocalDictionary, @"LastExtendCellSubSubDetail");
    NSString *oldOrNew = [oms.searchLocalDictionary objectForKeyGC:@"AddressType"];
    
    // 마지막클릭한 x,y좌표
    double xx = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellX"] intValue];
    double yy = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellY"] intValue];
    
    Coord addressCrd = CoordMake(xx, yy);
    
    //NSLog(@"masterID = %@ \n didCode = %@ \n type = %@ \n theme = %@ \n X = %f \n Y = %f", masterID, didCode, type, theme, addressCrd.x, addressCrd.y);
    
    // 주소타입(프로퍼티로 때려박기)
    AddressPOIViewController *apc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddressPOIView"];
    
    apc.poiZibunAddress = Addadd;
    apc.poiCrd = addressCrd;
    apc.poiRoadAddress = subAddDetail;
    apc.oldOrNew = oldOrNew;

    if(![[subSubAddDetail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
        apc.poiHangAddress = subSubAddDetail;
    else
        apc.poiHangAddress = @"";
    
    [[OMNavigationController sharedNavigationController] pushViewController:apc animated:NO];
    //
    //        [apc release];
    
    
}
// 지하철테이블에서 지하철가자
- (void) subwayDetail:(id)sender
{
    // 상세 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/search_result/detail"];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    // 마지막클릭한 타입, ID, didCode, 주소
    NSString *masterID = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellId"];
    
    
    /**
     @MethodDescription
     GW. 지하철 상세
     /v1/masstransit/TrafficSubStationInfo.json?STID=%@
     @MethodParams
     masterId(ORG_DB_ID) [STID]
     @MethodMehotdReturn
     지하철 상세정보
     */
    
    [[ServerConnector sharedServerConnection] requestSubStation:self action:@selector(finishRequestSubwayDetail:) stationId:masterID];
    
}
// 일반상세 콜백
-(void)finishRequestPoiDetailAtPoiId:(id)request
{
    
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        if([oms.poiDetailDictionary count] <= 0)
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_POI_DetailView_NothingInfo", @"")];
            return;
        }
        else
        {
            // POI상세 선택 통계
            [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail"];
            //
            UIStoryboard *sboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            GeneralPOIDetailViewController *gpdvc = [sboard instantiateViewControllerWithIdentifier:@"GeneralPOIDetailView"];
            
            
            NSString *name = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
            [gpdvc setThemeToDetailName:name];
            
            [[OMNavigationController sharedNavigationController] pushViewController:gpdvc animated:YES];
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
// 영화상세 콜백
- (void)finishRequestMovieDetailAtPoiId:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        if([oms.poiDetailDictionary count] <= 0)
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_POI_DetailView_NothingInfo", @"")];
            return;
        }
        else
        {
            // POI상세 선택 통계
            [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail"];
            
            MoviePOIDetailViewController *mpdvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MoviePOIDetailView"];
            //            // ver3테스트3번버그(일반상세API에는 상세이름까지 없다...결과에서넘겨줘야됨 ㅡㅡ)
            NSString *name = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
            //
            [mpdvc setThemeToDetailName:name];
            //
            [[OMNavigationController sharedNavigationController] pushViewController:mpdvc animated:YES];
            
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
// 유가상세 콜백
-(void)finishRequestoilDetail:(id)request
{
    
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        if([oms.poiDetailDictionary count] <= 0)
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_POI_DetailView_NothingInfo", @"")];
            return;
        }
        else
        {
            
            // POI상세 선택 통계
            [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail"];
            
            UIStoryboard *sboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            OilPOIDetailViewController *opdvc = [sboard instantiateViewControllerWithIdentifier:@"OilPOIDetailView"];
            [[OMNavigationController sharedNavigationController] pushViewController:opdvc animated:YES];
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
// 버스정류장상세 콜백
- (void) finishRequestBusDetail:(id)request
{
    
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        if([oms.busStationNewDictionary count] <= 0)
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_POI_DetailView_NothingInfo", @"")];
            return;
        }
        
        [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail"];
        BusStationPOIDetailViewController *bspdvc = [self.storyboard instantiateViewControllerWithIdentifier:@"BusStationPOIDetailView"];
        
        [[OMNavigationController sharedNavigationController] pushViewController:bspdvc animated:NO];
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
// 버스노선 콜백
- (void)finishBusNumberDetail:(id)request
{
    
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        if([OllehMapStatus sharedOllehMapStatus].busNumberNewDictionary.count < 1)
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_POI_DetailView_NothingInfo", @"")];
            return;
        }
        
        BusLineViewController *blvc = [self.storyboard instantiateViewControllerWithIdentifier:@"BusLineView"];
        [[OMNavigationController sharedNavigationController] pushViewController:blvc animated:YES];
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
// 지하철상세 콜백
-(void)finishRequestSubwayDetail:(id)request
{
    
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        if([oms.subwayDetailDictionary count] <= 0)
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_POI_DetailView_NothingInfo", @"")];
            return;
        }
        else
        {
            // POI상세 선택 통계
            [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail"];
            
            SubwayPOIDetailViewController *spdvc = [self.storyboard instantiateViewControllerWithIdentifier:@"SubwayPOIDetailView"];
            [[OMNavigationController sharedNavigationController] pushViewController:spdvc animated:YES];
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

@end
