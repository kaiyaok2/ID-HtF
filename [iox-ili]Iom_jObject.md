## Description:
In the constructor of `Iom_jObject`, the code loops through a `HashMap` named `attrv` that stores attribute value. To retrieve the $$k^{th}$$ attribute name, the function `getattrname()` is called, with $$k$$ being its input parameter. The function simply let `attrv.keySet().iterator()` iterate, and return the key when it's the $$k^{th}$$ iteration. In theory, each calls to `getattrname()` can get a different order in `attrv.keySet().iterator()`. Therefore, calling `getattrname(n)` for n = 1, 2, 3.... does not necessarily traverse everything in the `attrv` key set - it may retrieve the same attribute name with different choices of `n` and miss some other attribute names in `attrv`.

## Link to source of flakiness:
Line 246 in `Iom_jObject.java`. Repository: https://github.com/claeis/iox-ili.git. SHA: 186b3d7ece6f1c9c3a3ef6d478845c2dcc42c361


## Additional Information:

The above flakiness influences the `validator()` routine of `Validator.java` implemented in `https://github.com/claeis/ilivalidator.git`. A unit test that calls the `validator()` routine can be flaky under NonDex instrumentation.
