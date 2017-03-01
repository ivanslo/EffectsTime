//
//  Helper.swift
//  EffectsTimeApp
//
//  Created by Ivan Slobodiuk
//  Copyright © 2017 sLab. All rights reserved.
//

import Foundation


class Helper {
    
    static func sampleBufferToUIImage(sampleBuffer: CMSampleBuffer) -> UIImage {
        /* 
         * This function gets a CMSampleBuffer (typical output from the video stream)
         * and converts it to an UIImage
         */
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        CVPixelBufferLockBaseAddress(imageBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer!)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!)
        
        let width = CVPixelBufferGetWidth(imageBuffer!)
        let height = CVPixelBufferGetHeight(imageBuffer!)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        let quartzImage = context!.makeImage()
        
        CVPixelBufferUnlockBaseAddress(imageBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return UIImage(cgImage: quartzImage!)
    }
}
