//
//  ViewController.m
//  HotSpotHelper
//
//  Created by Paresh Vaghela on 15/02/17.
//  Copyright © 2017 Paresh Vaghela. All rights reserved.
//

#import "ViewController.h"

#import "NSString+HTML.h"
@interface ViewController ()


@end

@implementation ViewController

-(NSString *)convertHTML:(NSString *)html {
    
    NSScanner *myScanner;
    NSString *text = nil;
    myScanner = [NSScanner scannerWithString:html];
    
    while ([myScanner isAtEnd] == NO) {
        
        [myScanner scanUpToString:@"<" intoString:NULL] ;
        
        [myScanner scanUpToString:@">" intoString:&text] ;
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    //
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return html;
}
-(void)testing{
    // https://jionet.jio.in/jionetportal/otp/welcomeLink
    // http://10.135.25.221:10020
    //http://10.135.25.221:10022/portal/custom/login?UserName=pankaj&Lb=8&button=Login&Password=Token4Auth%40RJIL&Mode=VALID
    /*
     <div id='WISPrHome' style='display:none'><!-- <WISPAccessGatewayParam xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:noNamespaceSchemaLocation='http://www.acmewisp.com/WISPAccessGatewayParam.xsd'><Redirect><AccessProcedure>1.0</AccessProcedure><AccessLocation>12</AccessLocation><LocationName>ACMEWISP,Gate_14_Terminal_C_of_Newark_Airport</LocationName><LoginURL>http://10.135.25.221:10022/portal/custom/login</LoginURL><AbortLoginURL>http://10.135.25.221:10022/portal/custom/logout</AbortLoginURL><MessageType>100</MessageType><ResponseCode>0</ResponseCode></Redirect></WISPAccessGatewayParam> --></div>
     */
    //    NSError* errorHtml = nil;
    //    NSString *path = [[NSBundle mainBundle] pathForResource: @"Wisper" ofType: @"html"];
    //    NSString *res = [NSString stringWithContentsOfFile: path encoding:NSUTF8StringEncoding error: &errorHtml];
    //NSLog(@"%@",[self convertHTML:res]);
    
    // NSString *summary = [res stringByEncodingHTMLEntities];
    
    NSURL *url = [NSURL URLWithString:@"http://clients3.google.com/generate_204"];
    //NSData *receivedData = [NSData dataWithContentsOfURL:url];
    
    /*unsigned char* bytes = (unsigned char*) [receivedData bytes];
     
     for(int i=0;i< [receivedData length];i++)
     {
     NSString* op = [NSString stringWithFormat:@"%d:%X",i,bytes[i],nil];
     NSLog(@"%@", op);
     }
     
     NSCharacterSet *charsToRemove = [NSCharacterSet characterSetWithCharactersInString:@"< >"];
     NSString *someString = [[receivedData description] stringByTrimmingCharactersInSet:charsToRemove];
     NSString *someString1 = [NSString stringWithFormat:@"%@", receivedData];
     
     NSData *htmlData = [NSData dataWithContentsOfURL:url];
     NSAttributedString *attrString = [[NSAttributedString alloc] initWithData:htmlData options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
     */
    //[yourLabel setAttributedText:attrString];
    
    //NSString *myString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",myString);
    NSMutableURLRequest *urlReq=[NSMutableURLRequest requestWithURL:url];
    
    NSHTTPURLResponse *response;
    
    NSError *error = nil;
    
    //NSData *receivedData = [NSURLConnection connectionWithRequest:urlReq delegate:self];
    
     NSData *receivedData = [NSURLConnection sendSynchronousRequest:urlReq
     returningResponse:&response
     error:&error];
     if(error!=nil)
     {
     NSLog(@"web service error:%@",error);
     }
     else
     {
     if(receivedData !=nil)
     {
     //NSString *redirectURL = [[response allHeaderFields] objectForKey:@"Location"];
     
     //response.statusCode
     //NSInteger statusCode = response.statusCode;
     NSString *myString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
     NSLog(@"Status code =%ld Response %@",response.statusCode,myString);
     
         
         }
     }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // This is test...
    dispatch_queue_t _helperQueue = dispatch_queue_create("JioHotspotHelperQueue", DISPATCH_QUEUE_SERIAL);
    NSDictionary<NSString *,NSObject *> *options = @{
                                                     kNEHotspotHelperOptionDisplayName : @"Use Paresh app to login"
                                                     };
   // [NEHotspotHelper registerWithOptions:options queue:_helperQueue handler:self.helperHandler];
    
    BOOL isAvailable = [NEHotspotHelper registerWithOptions:options queue:_helperQueue handler: ^(NEHotspotHelperCommand * cmd) {
        
        
//        if(cmd.commandType == kNEHotspotHelperCommandTypeEvaluate || cmd.commandType == kNEHotspotHelperCommandTypeFilterScanList  || cmd.commandType == kNEHotspotHelperCommandTypeAuthenticate) {
            if (cmd.commandType == kNEHotspotHelperCommandTypeFilterScanList) {
                NSMutableArray *networks = [NSMutableArray new];
                for (NEHotspotNetwork *network in cmd.networkList) {
                    NSLog(@"Networkd SSID - %@",network.SSID);
                    if ([network.SSID isEqualToString:@"JioNet"]) {
                        [network setConfidence:kNEHotspotHelperConfidenceHigh];
                        [networks addObject:network];
                    }
                }
                NEHotspotHelperResponse *result = [cmd createResponse:kNEHotspotHelperResultSuccess];
                [result setNetworkList:[NSArray arrayWithArray:networks]];
                [result deliver];
            }
            if (cmd.commandType == kNEHotspotHelperCommandTypeEvaluate) {
                NSLog(@"Evaluate");
                NEHotspotNetwork *network = cmd.network;
                if ([network.SSID isEqualToString:@"JioNet"]) {
                    
                    [network setConfidence:kNEHotspotHelperConfidenceHigh];
                    NEHotspotHelperResponse *result = [cmd createResponse:kNEHotspotHelperResultSuccess];
                    [result setNetwork:network];
                    [result deliver];
                }
            }
            if (cmd.commandType == kNEHotspotHelperCommandTypeAuthenticate) {
                
                NSLog(@"COMMAND TYPE In Auth ***********:   %ld \n\n\n\n\n\n", (long)cmd.commandType);
            }
            if (cmd.commandType == kNEHotspotHelperCommandTypePresentUI) {
                
                NSLog(@"COMMAND TYPE In Present UI ***********:   %ld \n\n\n\n\n\n", (long)cmd.commandType);
                
            }
            if (cmd.commandType == kNEHotspotHelperCommandTypeMaintain) {
                
                NSLog(@"COMMAND TYPE In Maintain ***********:   %ld \n\n\n\n\n\n", (long)cmd.commandType);
                
            }
        //}
    }];
    

}

#pragma mark network detection
- (NEHotspotNetwork *)networkLatched
{
    NSArray *interfaces = [NEHotspotHelper supportedNetworkInterfaces];
    NEHotspotNetwork *networkLatched;
    for (NEHotspotNetwork *network in interfaces) {
        networkLatched = network;
    }
    return networkLatched;
}

- (void) requestCommandRegeneration {
    //[self.cpHandler requestCommandRegeneration];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
