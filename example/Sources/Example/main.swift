import TemporaryVariable

func x() -> Int { 0 }
func a(_ v: Int) -> Int { v + 1 }
func b(_ v: Int) -> Int { v + 2 }
func c(_ v: Int) -> Int { v + 4 }
func d(_ v: Int) -> Int { v + 8 }

func test() -> Int {
    #info {
        return a(b(c(d(x()))))
    }
}

func test2() {
    #info {
        let a = a(b(c(d(x()))))
        print(a)
    }
}

func test3() -> Int {
    return info {
        return a(b(c(d(x()))))
    }
}

print(test())
test2()
print(test3())
