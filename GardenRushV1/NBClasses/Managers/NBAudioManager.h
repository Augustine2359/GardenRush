//
//  NBAudioManager.h
//  ElementArmy1.0
//
//  Created by Augustine on 25/4/13.
//
//

#import <Foundation/Foundation.h>

@interface NBAudioManager : NSObject

+ (NBAudioManager *)sharedInstance;
- (NSInteger)bgmVolume;
- (BOOL)isMute;

- (void)playSoundEffect:(NSString *)soundEffect;
- (void)playBGM:(NSString *)bgmString;
- (void)stopBGM;

- (void)decreaseBGMVolume;
- (void)increaseBGMVolume;
- (void)toggleMute;

@end
