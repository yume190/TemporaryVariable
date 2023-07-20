#if swift(>=5.9)
@freestanding(codeItem)
public macro info(_ closure: () -> Void) = #externalMacro(
    module: "TemporaryVariablePlugin",
    type: "InfoMacro"
)
#endif
