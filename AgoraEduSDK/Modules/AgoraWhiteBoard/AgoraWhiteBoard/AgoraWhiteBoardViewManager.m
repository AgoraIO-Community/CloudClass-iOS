//
//  AgoraWhiteBoardViewManager.m
//  AgoraWhiteBoard
//
//  Created by SRS on 2020/7/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraWhiteBoardViewManager.h"

@implementation AgoraWhiteBoardViewManager

- (void)setBoardView:(WhiteBoardView *)boardView {
    _boardView = boardView;
    [self initControlView];
}

- (void)initControlView {
    
    NSBundle *baseBundle = [NSBundle bundleForClass:AgoraWhiteBoardViewManager.class];
    WhiteBoardPageControlView *pageView = [baseBundle loadNibNamed:@"WhiteBoardPageControlView" owner:self options:nil].firstObject;
    pageView.hidden = YES;
    [self.boardView addSubview:pageView];
    self.pageControlView = pageView;
    
    WhiteBoardToolControlView *toolView = [baseBundle loadNibNamed:@"WhiteBoardToolControlView" owner:self options:nil].firstObject;
    toolView.hidden = YES;
    [self.boardView addSubview:toolView];
    self.toolControlView = toolView;

    WhiteBoardColorControlView *colorView = [baseBundle loadNibNamed:@"WhiteBoardColorControlView" owner:self options:nil].firstObject;
    colorView.hidden = YES;
    [self.boardView addSubview:colorView];
    self.colorControlView = colorView;
    
    [self updateSubviewLayouts];
}

- (void)updateSubviewLayouts {

    {
        self.pageControlView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.pageControlView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:224];
        [self.pageControlView addConstraint:widthConstraint];
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.pageControlView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:46];
        [self.pageControlView addConstraint:heightConstraint];
        
        [self.boardView addConstraints:@[
            [NSLayoutConstraint constraintWithItem:self.pageControlView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.boardView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10],
            
            [NSLayoutConstraint constraintWithItem:self.pageControlView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.boardView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10],
        ]];
    }

    {
        self.toolControlView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.toolControlView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:46];
        [self.toolControlView addConstraint:widthConstraint];
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.toolControlView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:214];
        [self.toolControlView addConstraint:heightConstraint];
        
        [self.boardView addConstraints:@[
            [NSLayoutConstraint constraintWithItem:self.toolControlView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.boardView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10],
            
            [NSLayoutConstraint constraintWithItem:self.toolControlView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.boardView attribute:NSLayoutAttributeTop multiplier:1.0 constant:10],
        ]];
    }

    {
    self.colorControlView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.colorControlView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:220];
        [self.colorControlView addConstraint:widthConstraint];
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.colorControlView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:124];
        [self.colorControlView addConstraint:heightConstraint];
        
        [self.boardView addConstraints:@[
            [NSLayoutConstraint constraintWithItem:self.colorControlView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.toolControlView attribute:NSLayoutAttributeRight multiplier:1.0 constant:5],
            [NSLayoutConstraint constraintWithItem:self.colorControlView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.toolControlView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-124]
        ]];
    }
}

@end
