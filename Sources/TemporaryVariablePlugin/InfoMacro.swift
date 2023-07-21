import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Idea
///
/// origin
///
/// ```
/// return something()
/// ```
///
/// to
///
/// ```
/// let result = something()
/// return result
/// ```
///
/// impl
///
/// ```
/// #info {
///     return something()
/// }
/// ```
public struct InfoMacro: CodeItemMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext)
        -> [CodeBlockItemSyntax] {
        guard let trail = node.trailingClosure else { return [] }
        let rewriter = InfoRewriter(trail.statements.count, context)
        let result = trail.statements.enumerated().map { index, block -> [CodeBlockItemSyntax] in
            rewriter.setupIndex(index)
            let newBlock = rewriter.visit(block)
            return rewriter.blocks + [newBlock]
        }

        return result.flatMap { $0 }
    }
}

/// target
///     FunctionCallExpr: `call()`
///     SubscriptExpr:    `list[0]`/`dict[key]`
final class InfoRewriter<Context: MacroExpansionContext>: SyntaxRewriter {
    private var allBlocks: [[CodeBlockItemSyntax]]
    var blocks: [CodeBlockItemSyntax] {
        allBlocks[index]
    }
    private var counter: Int = 0
    private var length: Int
    private(set) var index: Int = 0
    private let context: Context
    init(_ length: Int, _ context: Context) {
        self.length = length
        self.allBlocks = .init(repeating: [], count: length)
        self.context = context
    }

    final func setupIndex(_ index: Int) {
        self.index = index
    }

    private final func newVariable() -> TokenSyntax {
        defer { counter+=1}
        return self.context.makeUniqueName("result\(counter)")
    }

    /// input:
    ///   call(arg1(), arg2(), ...)
    /// output:
    ///   r0
    override final func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        let isWithouhtBase: Bool
        if let memberAccess = node.calledExpression.as(MemberAccessExprSyntax.self) {
            isWithouhtBase = memberAccess.base == nil
        } else {
            isWithouhtBase = false
        }

        return isWithouhtBase ? withoutBase(node) : withBase(node)
    }

    /// withBase:
    ///     x.call(...)
    ///     call(...)
    private final func withBase(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        /// call(r1, r2, ...)
        let newNode = node.with(\.argumentList, visit(node.argumentList))
            .with(\.leadingTrivia, .spaces(0))
            .with(\.trailingTrivia, .spaces(0))

        /// r0
        let variable = newVariable()
        /// let r0 = call(r1, r2, ...)
        self.allBlocks[index].append("""
        let \(variable) = \(newNode)
        """)

        /// r0
        return .init(IdentifierExprSyntax(identifier: variable))
    }

    /// withoutBase: .call(...)
    private final func withoutBase(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        /// .call(r1, r2, ...)
        let newNode = node.with(\.argumentList, visit(node.argumentList))
            .with(\.leadingTrivia, .spaces(0))
            .with(\.trailingTrivia, .spaces(0))

        return .init(newNode)
    }

    /// if Pattern is `= call(...)`
    override func visit(_ node: InitializerClauseSyntax) -> InitializerClauseSyntax {
        guard let functionCall = node.value.as(FunctionCallExprSyntax.self) else {
            return node
        }
        let newFunctionCall = functionCall.with(\.argumentList, visit(functionCall.argumentList))
        return node.with(\.value, .init(newFunctionCall))
    }
}
