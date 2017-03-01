//
//  OpenCVHandler.m
//  EffectsTimeApp
//
//  Created by Ivan Slobodiuk
//  Copyright © 2017 sLab. All rights reserved.
//


// Important! OpenCV headers should go before any other Apple Header.
// It seams they have some conflicts with new compiler versions.
#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/imgcodecs/ios.h>

#import "OpenCVWrapper.h"
#import "Effects.h"

@implementation OpenCVWrapper

+ (void) processAndPresentFrame: (CMSampleBufferRef) videoFrame in: (UIImageView*) imageView apply: (uint8_t) effects
{
    CVImageBufferRef buffer = CMSampleBufferGetImageBuffer(videoFrame);
    
    CVPixelBufferLockBaseAddress( buffer, 0);
    
        size_t height       = CVPixelBufferGetHeight( buffer );
        size_t bytesPerRow  = CVPixelBufferGetBytesPerRow( buffer );
        /*
         * Calculate the extendedWidth is necessary because in some capture resolutions
         * there are more bytes per row.
         * I.e: in portrait mode, capturing at 1080x1920 each row has 1088 bytes not 1080.
         */
        size_t extendedWidth = bytesPerRow / sizeof( uint32_t );
        
        cv::Mat ocv_image = cv::Mat((int)height,
                                (int)extendedWidth,
                                CV_8UC4,
                                CVPixelBufferGetBaseAddressOfPlane( buffer, 0 ));
    
    CVPixelBufferUnlockBaseAddress( buffer , 0);

    /* OpenCV Image Transformation */
    cvtColor(ocv_image, ocv_image, CV_BGRA2RGB);
    cv::Mat ocv_image_helper;
    
    if( effects & EffectFlipX )
    {
        ocv_image_helper = ocv_image; // this is not expensive. It doesn't perform a deep copy
        cv::flip(ocv_image, ocv_image_helper, 1);
    }
    if( effects & EffectInvertColor )
    {
        ocv_image_helper = ocv_image;
        bitwise_not(ocv_image, ocv_image_helper);
    }
    
    UIImage* image = MatToUIImage(ocv_image);
    
    /* 
     * we always apply this kind of operations from the main thread
     */
    dispatch_async( dispatch_get_main_queue(), ^{
        [imageView setImage: image];
    });
}

@end
