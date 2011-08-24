//
//  JOImageView.h
//  JOKit
//
//  Created by Jeffrey Oloresisimo on 11-07-27.
//  Copyright 2011 radelcom. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JOImageView : UIImageView {
	NSString*						imageName;
    NSMutableData*					imageData;
	UIActivityIndicatorView*		activityIndicator;
}

- (void)loadURL:(NSString*)imageURL;
- (void)loadURL:(NSString*)imageURL filename:(NSString*)filename;
- (void)loadURL:(NSString*)imageURL filename:(NSString*)filename placeholder:(NSString*)placeholder;

@end
