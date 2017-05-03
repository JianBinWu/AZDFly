//
//  AppMacro.h
//  azdFly
//
//  Created by 吴剑斌 on 2017/5/3.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#ifndef AppMacro_h
#define AppMacro_h

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000 // 当前Xcode支持iOS8及以上
#define KScreen_Width ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?[UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale:[UIScreen mainScreen].bounds.size.width)
#define KScreen_Height ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?[UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale:[UIScreen mainScreen].bounds.size.height)
#define KScreen_Size ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?CGSizeMake([UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale,[UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale):[UIScreen mainScreen].bounds.size)
#else
#define KScreen_Width [UIScreen mainScreen].bounds.size.width
#define KScreen_Height [UIScreen mainScreen].bounds.size.height
#define KScreen_Size [UIScreen mainScreen].bounds.size
#endif

#define iPhone3_5 (KScreen_Height==480)
#define iPhone4_0 (KScreen_Height==568)
#define iPhone4_7 (KScreen_Height==667)
#define iPhone5_5 (KScreen_Height==736)



#endif /* AppMacro_h */
