//
//  UIWebView+JavaScriptAlert.h
//  bswkApp
//
//  Created by 南京夏恒 on 16/2/19.
//  Copyright © 2016年 南京夏恒. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (JavaScriptAlert)


-(void) webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;  
//
//- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id *)frame;


@end
