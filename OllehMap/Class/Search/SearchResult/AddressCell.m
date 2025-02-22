//
//  AddressCell.m
//  OllehMap
//
//  Created by 이 제민 on 12. 8. 7..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "AddressCell.h"
#import "MainViewController.h"

@implementation AddressCell
@synthesize segmentBar;
@synthesize addBgView;
@synthesize addressImg;
@synthesize addressStrImg;
@synthesize addressName;
@synthesize addressDistance;
@synthesize addressSinglePOI;
@synthesize addressBtnView;
@synthesize addressStart;
@synthesize addressDest;
@synthesize addressVisit;
@synthesize addressShare;
@synthesize addressDetail;
@synthesize subAddress;
@synthesize subAddressImg;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc
{
    [segmentBar release];
    [addBgView release];
    [addressImg release];
    [addressStrImg release];
    [addressName release];
    [addressDistance release];
    [addressSinglePOI release];
    [addressBtnView release];
    [addressStart release];
    [addressDest release];
    [addressVisit release];
    [addressShare release];
    [addressDetail release];
    [subAddress release];
    [subAddressImg release];
    [super dealloc];
}
- (IBAction)addressStartClick:(id)sender
{
    if([(UIButton *)sender tag] < 500)
    {
    // 출발지통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/search_result/start"];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    oms.currentMapLocationMode = MapLocationMode_None;
    NSString *place = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
    
    double x = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellX"] doubleValue];
    
    double y = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellY"] doubleValue];
    
    NSLog(@"%@, %f, %f", place, x, y);
    
    [oms.searchResultRouteStart reset];
    [oms.searchResultRouteStart setUsed:YES];
    [oms.searchResultRouteStart setIsCurrentLocation:NO];
    [oms.searchResultRouteStart setStrLocationName:place];
    [oms.searchResultRouteStart setCoordLocationPoint:CoordMake(x, y)];
    
    [[SearchRouteDialogViewController sharedSearchRouteDialog] showSearchRouteDialog];
    [mc.kmap setCenterCoordinate:oms.searchResultRouteStart.coordLocationPoint];
    }
}

- (IBAction)addressDestClick:(id)sender
{
    if([(UIButton *)sender tag] < 600)
    {
    // 도착지 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/search_result/dest"];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    NSString *place = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
    oms.currentMapLocationMode = MapLocationMode_None;
    double x = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellX"] doubleValue];
    
    double y = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellY"] doubleValue];
    
    NSLog(@"%@, %f, %f", place, x, y);
    
    [oms.searchResultRouteDest reset];
    [oms.searchResultRouteDest setUsed:YES];
    [oms.searchResultRouteDest setIsCurrentLocation:NO];
    [oms.searchResultRouteDest setStrLocationName:place];
    [oms.searchResultRouteDest setCoordLocationPoint:CoordMake(x, y)];
    
    [[SearchRouteDialogViewController sharedSearchRouteDialog] showSearchRouteDialog];
    
    [mc.kmap setCenterCoordinate:oms.searchResultRouteDest.coordLocationPoint];
    
    }
}

- (IBAction)addressVisitClick:(id)sender
{
    if([(UIButton *)sender tag] < 700)
    {
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    NSString *place = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
    oms.currentMapLocationMode = MapLocationMode_None;
    double x = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellX"] doubleValue];
    
    double y = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellY"] doubleValue];
    
    NSLog(@"%@, %f, %f", place, x, y);
    
    [oms.searchResultRouteVisit reset];
    [oms.searchResultRouteVisit setUsed:YES];
    [oms.searchResultRouteVisit setIsCurrentLocation:NO];
    [oms.searchResultRouteVisit setStrLocationName:place];
    [oms.searchResultRouteVisit setCoordLocationPoint:CoordMake(x, y)];
    
    [[SearchRouteDialogViewController sharedSearchRouteDialog] showSearchRouteDialog];
    
    [mc.kmap setCenterCoordinate:oms.searchResultRouteVisit.coordLocationPoint];
    }
}

- (IBAction)addressShareClick:(id)sender
{
    // 위치공유 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/search_result/share"];
    
    //MapContainer *mc = [MapContainer sharedMapContainer_Main];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    //NSString *place = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
    //NSString *poiId = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellDidCode"];
    double x = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellX"] doubleValue];
    
    double y = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellY"] doubleValue];
    
    NSString *Addadd = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellTelAddress"];
    
    
    
    if(!Addadd)
        Addadd = @"";
    
    // 새로운 url공유
    NSString *order = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendOrder"];
    [[ServerConnector sharedServerConnection] requestSearchURL:self action:@selector(finishShareBtnClick:) PX:(int)x PY:(int)y Query:oms.keyword SearchType:@"address" order:order];
    
    //[[ServerConnector sharedServerConnection] requestShortenURL:self action:@selector(finishShareBtnClick:) PX:(int)x PY:(int)y Level:mc.kmap.zoomLevel MapType:mc.kmap.mapType Name:place PID:@"" Addr:Addadd Tel:nil Type:@"ADDR" ID:@""];
}
// 위치공유버튼클릭
- (void) finishShareBtnClick:(id)request
{
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        
        NSString *name = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
        NSString *tel = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellTel"];
        NSString *addr = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellTelAddress"];
        
        if(tel == nil)
            tel = @"";
        
        if(addr == nil)
            addr = @"";
        
        [oms.shareDictionary setObject:name forKey:@"NAME"];
        
        [oms.shareDictionary setObject:addr forKey:@"ADDR"];
        [oms.shareDictionary setObject:tel forKey:@"TEL"];
        
        NSLog(@"단축URL : %@", [oms.shareDictionary objectForKeyGC:@"ShortURL"]);
        
        //[self.view addSubview:[ShareViewController instVC].view];
        
        
        [ShareViewController sharePopUpView:self.superview.superview.superview];
    }
    else if([[OllehMapStatus sharedOllehMapStatus] getNetworkStatus] == OMReachabilityStatus_disconnected)
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_NetworkException", @"")];
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_ShortURL_NotResponse", @"")];
    }
}


@end
