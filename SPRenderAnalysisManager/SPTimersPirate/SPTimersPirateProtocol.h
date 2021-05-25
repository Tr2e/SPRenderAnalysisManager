//
//  SPTimersPirateProtocol.h
//  biyao
//
//  Created by Tr2e on 2021/5/14.
//  Copyright © 2021 Tr2e. All rights reserved.
//

#ifndef SPTimersPirateProtocol_h
#define SPTimersPirateProtocol_h

@protocol SPTimersPirateProtocol <NSObject>
@required
+ (void)killAllTimers;
@optional
+ (void)reviveAllTimers;
@end

#endif /* SPTimersPirateProtocol_h */
