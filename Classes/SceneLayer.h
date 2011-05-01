#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIColor.h>

@interface SceneLayer : CALayer {
}

@property (nonatomic, assign) CGFloat rotation_x;
@property (nonatomic, assign) CGFloat rotation_y;
@property (nonatomic, assign) CGFloat rotation_z;
@property (nonatomic, assign) CGFloat translation_x;
@property (nonatomic, assign) CGFloat translation_y;
@property (nonatomic, assign) CGFloat translation_z;

@end
