//
//  MainViewController.m
//  iOSTesting
//
//  Created by  Anson Ng on 27/12/2017.
//  Copyright © 2017 Yahoo. All rights reserved.
//

#import "MainViewController.h"
#import "EAImage360Library.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (strong, nonatomic) EAImage360Library *image360Library;

@end

@implementation MainViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.image360Library.previewLayer.frame =  self.previewView.bounds;
    [self.previewView.layer addSublayer:self.image360Library.previewLayer];
    [self.image360Library startCamera];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.image360Library = [[EAImage360Library alloc] init];
    [self.image360Library initCamera];
    self.image360Library.delegate = self;
}

- (void)showMessage:(NSString *)string
{
    dispatch_async( dispatch_get_main_queue(), ^{
        self.errorLabel.text = string;
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.errorLabel.text = @"";
    });
}
- (void)image360Library:(EAImage360Library *)library error:(NSError *)error
{
    [self showMessage:[NSString stringWithFormat:@"%@", error]];

}
- (void)willGenerateImagesByImage360Library:(EAImage360Library *)eaImage360Library
{
    [self showMessage:@"willGenerateImagesByImage360Library"];

}
- (void)didGenerateImagesByImage360Library:(EAImage360Library *)eaImage360Library images:(NSArray <UIImage *> *)images
{

    [self showMessage:@"didGenerateImagesByImage360Library"];

}
- (IBAction)tapRecord:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.image360Library startCaptureVideo];

    } else {
        [self.image360Library stopCaptureVideo];
    }
    
}
@end
