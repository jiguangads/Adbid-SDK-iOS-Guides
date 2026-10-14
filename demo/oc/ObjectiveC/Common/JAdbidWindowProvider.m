#import "JAdbidWindowProvider.h"

UIWindow *JAdbidKeyWindow(void) {
  for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
    if (scene.activationState != UISceneActivationStateUnattached && [scene isKindOfClass:UIWindowScene.class]) {
      for (UIWindow *window in ((UIWindowScene *)scene).windows)
        if (window.isKeyWindow) return window;
    }
  }
  return UIApplication.sharedApplication.delegate.window;
}
