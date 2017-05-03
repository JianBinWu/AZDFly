//
//  UtilMacro.h
//  azdFly
//
//  Created by 吴剑斌 on 2017/5/2.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#ifndef UtilMacro_h
#define UtilMacro_h

//NSLog替代宏
#ifdef DEBUG

#define DMLog(...) NSLog(@"%@",[NSString stringWithFormat:__VA_ARGS__])
#define ERRORLog(...) NSLog(@"\n\n Error: \n method:%s \n file: %s \n line: %d \n %@ \n\n",__PRETTY_FUNCTION__,__FILE__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])

#else

#define DMLog(...) do {} while (0)
#define ERRORLog(...) do {} while (0)

#endif

#endif /* UtilMacro_h */
