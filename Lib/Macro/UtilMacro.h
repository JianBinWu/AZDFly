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

#define DMLog(...) printf("%s\n",[[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#define ERRORLog(...) printf("\n\n Error: \n method:%s \n file: %s \n line: %d \n %s \n\n",__PRETTY_FUNCTION__,__FILE__,__LINE__,[[NSString stringWithFormat:__VA_ARGS__] UTF8String])

#else

#define DMLog(...) do {} while (0)
#define ERRORLog(...) do {} while (0)

#endif

#define WeakRef(__obj) __weak typeof(self) __obj = self
#define WeakReturn(__obj) if(__obj == nil) return;

#define DEGREE(x) ((x)*180.0/M_PI)
#define RADIAN(x) ((x)*M_PI/180.0)

#endif /* UtilMacro_h */
