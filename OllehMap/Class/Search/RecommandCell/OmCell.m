//
//  OmCell.m
//  OllehMap
//
//  Created by 이제민 on 13. 9. 27..
//  Copyright (c) 2013년 이제민. All rights reserved.
//

#import "OmCell.h"

@implementation OmCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(20, 9, 320, 34)];
        _label.backgroundColor = [UIColor clearColor];
        [self addSubview:_label];
    }
    return self;
}
#pragma mark - setString
- (void)setString:(NSString *)str searchString:(NSString*)search
{
    UIFont *boldSystemFont = [UIFont systemFontOfSize:15];
    _label.font = boldSystemFont;
    
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    [_label setText:str afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        int rangeMax = 0;
        int forCount = [search length] < [str length] ? (int)[search length] : (int)[str length];
        for(int i=0; i<forCount;i++){
            NSString *a = [str substringWithRange:NSMakeRange(i, 1)];
            NSString *b = [search substringWithRange:NSMakeRange(i, 1)];
            
            //NSLog(@"추천검색어값 : %@, 텍필값 : %@", a, b);
            // 대소문자 무시
            if([a compare:b options:NSCaseInsensitiveSearch] == NSOrderedSame){
                rangeMax++;
                continue;
            }
            else {
                break;
            }
        }
        NSRange boldRange = NSMakeRange(0, rangeMax);
        
        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
        
        // 텍스트크기
        UIFont *boldSystemFont = [UIFont systemFontOfSize:15];
    	CTFontRef font = CTFontCreateWithName((CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        //    	if (font) {
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName
                                        value:(id)[[UIColor colorWithRed:242.0/250.0 green:32.0/250.0 blue:113.0/250.0 alpha:1] CGColor]
                                        range:boldRange];
        [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName
                                        value:(__bridge id)((CTFontRef)font)
                                        range:boldRange];
        CFRelease(font);
        //    	}
    	
    	return mutableAttributedString;
    }];
    
}
@end
