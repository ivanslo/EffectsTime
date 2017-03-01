//
//  OpenCVHandler.h
//  EffectsTimeApp
//
//  Created by Ivan Slobodiuk
//  Copyright © 2017 sLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject

+ (void) processAndPresentFrame: (CMSampleBufferRef) videoFrame in: (UIImageView*) imageView apply: (uint8_t) effects;

@end
