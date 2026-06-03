# XAlert 使用说明

`XAlert` 是新的 Swift 弹窗组件实现，最低支持 iOS 13。组件按 Scene 管理弹窗，支持 Alert、Sheet、Banner、多方向展示、队列、优先级、按 lane 并发展示，以及 Objective-C 兼容调用。

## Swift 示例

```swift
XAlert.alert(from: self)
    .title("标题")
    .message("内容")
    .action("确定")
    .show()
```

```swift
XAlert.sheet(from: self)
    .title("操作")
    .message("Sheet 支持独立取消按钮")
    .action("普通操作")
    .destructive("删除")
    .cancel("取消")
    .show()
```

## 多方向展示

```swift
XAlert.make()
    .contentStyle(.banner)
    .presentationStyle(.top)
    .displayMode(.immediate)
    .title("顶部提示")
    .show()
```

## 动画配置

组件默认会根据展示方向使用更自然的弹性动画：居中弹窗使用弹性缩放，边缘弹窗使用弹性滑入。业务方也可以分别配置出现和消失效果：

```swift
XAlert.alert(from: self)
    .title("标题")
    .message("内容")
    .animation {
        $0.present.style = .springScale
        $0.present.duration = 0.36
        $0.present.springDamping = 0.82

        $0.dismiss.style = .fadeScale
        $0.dismiss.duration = 0.18
    }
    .show()
```

```swift
XAlert.sheet(from: self)
    .title("操作")
    .animation {
        $0.present.style = .springSlide
        $0.dismiss.style = .slide
    }
    .cancel("关闭")
    .show()
```

## 拖拽关闭

顶部和底部方向的弹窗可以开启拖拽关闭。顶部弹窗向上拖动关闭，底部弹窗向下拖动关闭；未达到关闭阈值时会弹回原位。

```swift
XAlert.make()
    .contentStyle(.banner)
    .presentationStyle(.top)
    .dimMode(.none)
    .interactiveDismissEnabled(true)
    .title("可拖拽 Banner")
    .message("向上拖动可以关闭")
    .show()
```

```swift
XAlert.sheet(from: self)
    .interactiveDismiss {
        $0.isEnabled = true
        $0.velocityThreshold = 750
        $0.distanceThresholdRatio = 0.33
    }
    .title("可拖拽 Sheet")
    .message("向下拖动可以关闭")
    .cancel("取消")
    .show()
```

## 同时展示 Alert 和 Sheet

Alert 默认在 `.center` lane，Sheet 默认在 `.bottom` lane，不同 lane 默认互不阻塞。

```swift
XAlert.alert(from: self)
    .displayMode(.immediate)
    .title("居中 Alert")
    .show()

XAlert.sheet(from: self)
    .displayMode(.immediate)
    .title("底部 Sheet")
    .cancel("关闭")
    .show()
```

## Objective-C 示例

```objc
[[[[XAlertObjC alert] title:@"标题"] message:@"内容"] action:@"确定" handler:nil] show];
```

## 构建说明

由于组件依赖 UIKit，Swift Package 需要使用 iOS destination 构建。直接 `swift build` 会按 macOS 构建，无法找到 UIKit。
