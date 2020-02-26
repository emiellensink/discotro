//
//  ViewController.m
//  DT
//
//  Created by Emiel Lensink on 26/02/2020.
//  Copyright © 2020 Emiel Lensink. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLView.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    OpenGLView *glView = [[OpenGLView alloc] initWithFrame: self.view.bounds];
    [self.view addSubview:glView];
    [glView beginAnimation];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)viewDidAppear {
    [self.view enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];
}

- (void)viewDidLayout {
    OpenGLView *subView = self.view.subviews[0];
    subView.frame = self.view.bounds;
    [subView reshape];
}

@end
