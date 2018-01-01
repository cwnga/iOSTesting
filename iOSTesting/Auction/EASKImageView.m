//
//  EASKImageView.m
//  ECAuctionApp
//
//  Created by Anson Ng on 1/11/17.
//  Copyright © 2017 Yahoo. All rights reserved.
//

#import "EASKImageView.h"
#import <SpriteKit/SpriteKit.h>

@interface EASKImageView ()

@property (strong, nonatomic) SKView *skView;
@property (strong, nonatomic) SKSpriteNode *imageNode;
@property (strong, nonatomic) SKScene *skScene;

@end

@implementation EASKImageView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    self.backgroundColor = [SKColor clearColor];
    self.skView = [[SKView alloc] initWithFrame:self.bounds];
    self.skView.backgroundColor = [SKColor clearColor];
    [self addSubview:self.skView];
    self.skView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageNode = [SKSpriteNode spriteNodeWithTexture:nil];
    self.imageNode.size = self.bounds.size;

    self.skScene = [SKScene sceneWithSize:self.skView.bounds.size];
    self.skScene.backgroundColor = [SKColor clearColor];
    self.skScene.scaleMode = SKSceneScaleModeAspectFill;
    [self.skScene addChild:self.imageNode];
    [self.skView presentScene:self.skScene];
}

- (void)setImage:(UIImage *)image
{
    if (!image) {
        self.hidden = YES;
        image = [[UIImage alloc] init];
    } else {
        self.hidden = NO;
    }
    _image = image;
    [self updateImageScale];
}

- (void)updateImageScale
{
    if (_image.size.width > 0 && _image.size.height > 0) {
        self.imageNode.texture = [SKTexture textureWithImage:_image];
        self.imageNode.size = _image.size;
        CGFloat scale = MAX(CGRectGetWidth(self.frame) / _image.size.width, CGRectGetHeight(self.frame) / _image.size.height);
        self.imageNode.size = CGSizeMake(_image.size.width * scale, _image.size.height * scale);
    } else {
        [self.imageNode setScale:1.0f];
    }
    self.imageNode.position =  CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.skScene.size = self.bounds.size;
    [self updateImageScale];
}

@end
