//
//  Effects.h
//  EffectsTimeApp
//
//  Created by Ivan Slobodiuk
//  Copyright © 2017 sLab. All rights reserved.
//

#ifndef Effects_h
#define Effects_h


/* 
 * Supported effects for applying to the images
 */

typedef NS_ENUM(uint8_t, Effects)
{
    EffectNone          = 0b00000000,
    EffectFlipX         = 0b00000001,
    EffectInvertColor   = 0b00000010
};

#endif /* Effects_h */
