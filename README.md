# CountdownTimer

全局倒计时工具，可以维护任意多个倒计时

### 使用方法：

1. 把`CountdownTimer.swift`文件拖进项目

2. 在`CountdownTimer.swift`的枚举`CountDownKey`中添加定时器
> 每个枚举值代表一个可供使用的定时器
```swift
enum CountDownKey: CaseIterable {
  case test1
  case test2
  // 当需要一个倒计时的时候就在这里加一个key
}

```

3. 开启一个定时器，
> 当闭包中要使用self的时候，记得加[weak self]
```swift
CountdownTimer.startTimer(key: .test1, count: 60) { (count, finish) in
  print(count) // 倒计时数字
  print(finish) // 是否完成倒计时
}
```

4. 手动停止某个定时器. 
> 手动停止或倒计时完，此定时器都会被移除，除非再次开启
```swift
CountdownTimer.stopTimer(key: .test1)
```

5. 继续某个定时器
> - 已经被停止的定时器是无法继续的，因为停止的定时器会被移除
> - 这个方法的作用是当开始定时器的页面被销毁，又想继续某个定时器的时候使用
```swift
CountdownTimer.continueTimer(key: .test1) { (count, finish) in
  print(count) // 倒计时数字
  print(finish) // 是否完成倒计时
}
```
