//
//  PdLibTestViewController.h
//  PdLibTest
//
//  Created by Bryan Summersett on 11/9/09.
//  Copyright NatIanBryan 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdController.h"

@interface PdLibTestViewController : UIViewController {
    PdController        *pdController;
    UITextField         *textField;
}

@property (retain) IBOutlet UITextField* textField;
@end

