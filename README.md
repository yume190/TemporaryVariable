# TemporaryVariable

---

`TemporaryVariable` provide a macro `#info {...}`. It capture most function calls and assign them to temporary variables.

### Usage

Most of the time we will write the following code.

```swift
func test() -> Int {
    return x()
}
```

Usually we need a temporary variable to facilitate our debugging

```swift
func test() -> Int {
    let result = x()
    return result
}
```

Now. You can use `#info {...}`

```swift
import TemporaryVariable
func test() -> Int {
    #info {
        return x()
    }
}
```

The expanded code

```swift
import TemporaryVariable
// public func info<T>(_ closure: () -> T) -> T {
//     return closure()
// }

func test() -> Int {
    info {
        let __macro_local_7result0fMu_ = x()
        return __macro_local_7result0fMu_
    }
}
```
