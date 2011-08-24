//
//  JOImageView.m
//  JOKit
//
//  Created by Jeffrey Oloresisimo on 11-07-27.
//  Copyright 2011 radelcom. All rights reserved.
//

#import "JOImageView.h"

@interface JOImageView ()


@property (nonatomic, retain) NSString* imageName;

- (void)loadImage:(NSString*)name;
- (BOOL)saveImage:(NSData*)data;
- (BOOL)verifyFilename:(NSString*)filename;

@end

@implementation JOImageView

@synthesize imageName;

- (id)init {
    if ((self = [super init])) {
		[self awakeFromNib];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self awakeFromNib];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	activityIndicator.center = CGPointMake(frame.size.width/2, frame.size.height/2);
}

- (void)awakeFromNib {
	[super awakeFromNib];
	self.contentMode = UIViewContentModeScaleAspectFit;
	imageData = [[NSMutableData alloc] init];
	activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityIndicator.hidesWhenStopped = YES;
	activityIndicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
	[self addSubview:activityIndicator];
}

#pragma mark - 
#pragma mark PRIVATE
- (BOOL)saveImage:(NSData*)data {
	NSString* fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.imageName];    
	return [data writeToFile:fullPath atomically:YES];
}

- (void)loadImage:(NSString*)filename {  
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator* dirEnum = [fileManager enumeratorAtPath:NSTemporaryDirectory()];
    
    NSString* file;
    while ((file = [dirEnum nextObject])) {
        if ([file hasPrefix:filename]) {
            NSString* fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:file];    
            self.image = [UIImage imageWithContentsOfFile:fullPath];
        }
    }
    
	[activityIndicator stopAnimating];
}

- (BOOL)verifyFilename:(NSString*)filename {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator* dirEnum = [fileManager enumeratorAtPath:NSTemporaryDirectory()];
    
    NSString* file;
    while ((file = [dirEnum nextObject])) {
        if ([file hasPrefix:filename]) {
            filename = file;
            return YES;
        }
    }
    return NO;
}

#pragma mark - 
#pragma mark PUBLIC
- (void)loadURL:(NSString*)imageURL {
    [self loadURL:imageURL filename:nil placeholder:nil];
}

- (void)loadURL:(NSString*)imageURL filename:(NSString*)filename {
    [self loadURL:imageURL filename:filename placeholder:nil];
}

- (void)loadURL:(NSString*)imageURL placeholder:(NSString*)placeholder {
    [self loadURL:imageURL filename:nil placeholder:placeholder];
}

- (void)loadURL:(NSString*)imageURL filename:(NSString*)filename placeholder:(NSString*)placeholder {
	self.image = [UIImage imageNamed:placeholder];	
	[activityIndicator startAnimating];
    
	if (filename && [self verifyFilename:filename]) {
		[self loadImage:filename];
	} else {
        self.imageName = filename;
		NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]
												 cachePolicy:NSURLRequestUseProtocolCachePolicy
											 timeoutInterval:60.0];
		
		[NSURLConnection connectionWithRequest:request delegate:self];
	}
}

#pragma mark -
#pragma mark NSURLConnectionDelegate
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
    NSLog(@"%@",response.suggestedFilename);
	if (imageName == nil && [self verifyFilename:response.suggestedFilename]) {
		[activityIndicator stopAnimating];
        [connection cancel];
		[self loadImage:response.suggestedFilename];
	} else  {
        if ([[imageName componentsSeparatedByString:@"."] count] == 1) {
            self.imageName = [imageName stringByAppendingPathExtension:[[response.suggestedFilename componentsSeparatedByString:@"."] lastObject]];
        } else {
            self.imageName = response.suggestedFilename;
        }
        
		[imageData setLength:0];
	}
}
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    [imageData appendData:data];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {    
	[activityIndicator stopAnimating];
	if ([self verifyFilename:self.imageName]) {
		[self loadImage:self.imageName];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection {
	// save
    if ([self saveImage:imageData]) {
		self.image = [UIImage imageWithData:imageData];	
	}
	[activityIndicator stopAnimating];	
}

- (void)dealloc {
	[imageName release];
	[imageData release];
	[activityIndicator release];
    [super dealloc];
}


@end

