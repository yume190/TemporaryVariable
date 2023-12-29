import XCTest
@testable import TemporaryVariablePlugin
import SwiftSyntaxMacrosTestSupport


final class InfoFailTests: XCTestCase {
    final func testWithFail() {
        assertMacroExpansion(
            "#info",
            expandedSource: "#info",
            diagnostics: [
                DiagnosticSpec(message: "Can't find trail closure", line: 1, column: 1)
            ],
            macros: [
                "info": InfoMacro.self,
            ]
        )
    }
}

final class InfoSkipTests: XCTestCase {
    final func testSkipWithoutBaseStaticFunction() {
        assertMacroExpansion(
        """
        func test() -> Int {
            #info {
                return .x()
            }
        }
        """,
        expandedSource:"""
        func test() -> Int {
            info {
                    return .x()
            }
        }
        """,
        macros: [
            "info": InfoMacro.self,
        ])
    }
    
    final func testWithoutReturn() {
        assertMacroExpansion(
        """
        func test() -> Int {
            #info {
                x()
            }
        }
        """,
        expandedSource:"""
        func test() -> Int {
            info {
                    x()
            }
        }
        """,
        macros: [
            "info": InfoMacro.self,
        ])
    }
    
    final func testSkipInnerFunction() {
        assertMacroExpansion(
        """
        #info {
            func a() -> Int {
                return x()
            }
            x()
        }
        """,
        expandedSource:"""
        info {
            func a() -> Int {
                return x()
            }
            x()
        }
        """,
        macros: [
            "info": InfoMacro.self,
        ])
    }
}

final class InfoTests: XCTestCase {
    final func testWithReturn() {
        assertMacroExpansion(
        """
        func test() -> Int {
            #info {
                return x()
            }
        }
        """,
        expandedSource:"""
        func test() -> Int {
            info {
                let __macro_local_7result0fMu_ = x()
                        return __macro_local_7result0fMu_
            }
        }
        """,
        macros: [
            "info": InfoMacro.self,
        ])
    }

    final func testNested() {
        assertMacroExpansion(
        """
        #info {
            let test = a(b(c(d())))
        }
        """,
        expandedSource:"""
        info {
            let __macro_local_7result0fMu_ = d()
            let __macro_local_7result1fMu_ = c(__macro_local_7result0fMu_)
            let __macro_local_7result2fMu_ = b(__macro_local_7result1fMu_)
                let test = a(__macro_local_7result2fMu_)
        }
        """,
        macros: [
            "info": InfoMacro.self,
        ])
    }

    final func testNested2() {
        assertMacroExpansion(
        """
        #info {
            let test1 = a(b(c(d())))
            let test2 = a(b(c(d())))
        }
        """,
        expandedSource:"""
        info {
            let __macro_local_7result0fMu_ = d()
            let __macro_local_7result1fMu_ = c(__macro_local_7result0fMu_)
            let __macro_local_7result2fMu_ = b(__macro_local_7result1fMu_)
                let test1 = a(__macro_local_7result2fMu_)
            let __macro_local_7result3fMu_ = d()
            let __macro_local_7result4fMu_ = c(__macro_local_7result3fMu_)
            let __macro_local_7result5fMu_ = b(__macro_local_7result4fMu_)
                let test2 = a(__macro_local_7result5fMu_)
        }
        """,
        macros: [
            "info": InfoMacro.self,
        ])
    }

    final func testPlain() {
        assertMacroExpansion(
        """
        #info {
            let test = a(b(), c(), d())
        }
        """,
        expandedSource:"""
        info {
            let __macro_local_7result0fMu_ = b()
            let __macro_local_7result1fMu_ = c()
            let __macro_local_7result2fMu_ = d()
                let test = a(__macro_local_7result0fMu_, __macro_local_7result1fMu_, __macro_local_7result2fMu_)
        }
        """,
        macros: [
            "info": InfoMacro.self,
        ])
    }

    final func testPlain2() {
        assertMacroExpansion(
        """
        #info {
            let test1 = a(b(), c(), d())
            let test2 = a(b(), c(), d())
        }
        """,
        expandedSource:"""
        info {
            let __macro_local_7result0fMu_ = b()
            let __macro_local_7result1fMu_ = c()
            let __macro_local_7result2fMu_ = d()
                let test1 = a(__macro_local_7result0fMu_, __macro_local_7result1fMu_, __macro_local_7result2fMu_)
            let __macro_local_7result3fMu_ = b()
            let __macro_local_7result4fMu_ = c()
            let __macro_local_7result5fMu_ = d()
                let test2 = a(__macro_local_7result3fMu_, __macro_local_7result4fMu_, __macro_local_7result5fMu_)
        }
        """,
        macros: [
            "info": InfoMacro.self,
        ])
    }
}
