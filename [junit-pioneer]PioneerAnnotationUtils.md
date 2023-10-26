## Description:
The `junit-pioneer` project implements `@CartesianProductTest` that acts like an extension of the `Junit` `@Test`. Specifically, it supports three types of annotations that supports parametrizing a test using different repeatable inputs - `@CartesianValueSource`, `@CartesianEnumSource` and a set of range source annotations. Consider the following example - 
```
@CartesianProductTest
@CartesianValueSource(ints = { 1, 2 })
@CartesianValueSource(ints = { 3, 4 })
void checkScalarAddition(int x, int y) {
	// The test will be executed four times, each time with a unique choice of $(x,y) \in \{(1, 3), (1, 4), (2, 3), (2, 4)\}$.
}
```
This test passes with `NonDex`, since the one repeatable annotation `@CartesianValueSource` preserves order per Java Language Specification:
> If a declaration context or type context has multiple annotations of a repeatable annotation type T, then it is as if the context has no explicitly declared annotations of type T and one implicitly declared annotation of the containing annotation type of T. The implicitly declared annotation is called the container annotation, and the multiple annotations of type T which appeared in the context are called the base annotations. The elements of the (array-typed) value element of the container annotation are all the base annotations in the left-to-right order in which they appeared in the context.

However, consider a cartesian product test that uses multiple input-generating annotations:
```
enum GradleVersion {
    v5, v6,
}
@CartesianProductTest
@CartesianValueSource(strings = {"project1", "project2"})
@CartesianEnumSource(GradleVersion.class)
void checkGradleBuildMultiple(String projectName, GradleVersion gradleVersion) {
    // Check if Gradle v{5, 6} works on project{1, 2}
}
```
This test will be flaky under NonDex, since the cartesian product test makes use of `getAnnotations()` to parse the annotations with respect to a test. As `getAnnotations()` does **NOT** preserve a deterministic order, the `projectName` parameter might be linked to `GradleVersion`, and the type conflict will raise the following error:
```
org.junit.jupiter.api.extension.ParameterResolutionException: No ParameterResolver registered for parameter [java.lang.String arg0] in method [void checkGradleBuildMultiple(...)]
```



## Link to source of flakiness:
Line 273 in `PioneerAnnotationUtils.java`. Repository: https://github.com/junit-pioneer/junit-pioneer. SHA: 13c2c4d5ebc0f13382b1a5607fb697e87d0e5ce0

