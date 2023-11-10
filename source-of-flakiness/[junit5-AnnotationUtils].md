## Description:
The function `findRepeatableAnnotations()` in `AnnotationUtils.java` is in charge of finding the repeatable annotations of a certain type when given an annotated element. It attempts to maintain original order of a type of repeatable annotation by storing its found annotations in a `LinkedHashSet` named `found`. However, while retrieving annotations that are directly present or meta-present on directly present annotations, it looped through the array returned by a call to `getDeclaredAnnotations()`. As `getDeclaredAnnotations()` does not guarantee order, elements with multiple repeatable annotations will suffer if the order of the repeatable annotations matters. (In general, the order of the annotations in the container annotation shall be the same as the order of declaration of the repeatable annotations.)

## Link to source of flakiness:
- Lines 320 and 324 in `AnnotationUtils.java`. Repository: https://github.com/junit-team/junit5. SHA: 1d89dd3206a4edbfb829880af208cd2dfb49ed78


## Sample Failing Test:
```
private static class ModuleVersion6 extends AbstractModuleVersionStringRetrieverExtension {
    @Override
    public String getModuleVersionString(String module) {
        return "6.0";
    }
}
@MaxSupportedVersion(module = "module", version = "6.0")
@ExtendWith(ModuleVersion6.class)
@ExampleTests
@SuppressWarnings({"java:S5810", "java:S2699", "java:S5790"})
static class ClassExample6 {
    @Test
    void test() {
    }
}

@Test
void annotated_class_6() {
    val tests = executeTestsForClass(ClassExample6.class).testEvents();
    tests.assertStatistics(stats -> stats.succeeded(1));
}
```
Notice that `@MaxSupportedVersion` uses `@ExtendWith` as a meta-annotation. Therefore, `findRepeatableAnnotations()` can put `@MaxSupportedVersion(module = "module", version = "6.0")` after `@ExtendWith(ModuleVersion6.class)` under NonDex instrumentation (after shuffling `getDec laredAnnotations()`), so the test errors out in the check done by `@MaxSupportedVersion`.

## Sample part of stacktrace produced by NonDex Debug for reference:
```
TEST: name.remal.gradle_plugins.toolkit.testkit.MaxSupportedVersionTest.annotated_class_6
java.base/java.lang.Thread.getStackTrace(Thread.java:1602)
java.base/edu.illinois.nondex.common.NonDex.printStackTraceIfUniqueDebugPoint(NonDex.java:165)
java.base/edu.illinois.nondex.common.NonDex.shouldExplore(NonDex.java:136)
java.base/edu.illinois.nondex.common.NonDex.getPermutation(NonDex.java:106)
java.base/edu.illinois.nondex.shuffling.ControlNondeterminism.shuffle(ControlNondeterminism.java:93)
java.base/java.lang.Class.getDeclaredAnnotations(Class.java:3713)
org.junit.platform.commons.util.AnnotationUtils.findRepeatableAnnotations(AnnotationUtils.java:320)
org.junit.platform.commons.util.AnnotationUtils.findRepeatableAnnotations(AnnotationUtils.java:291)
org.junit.jupiter.engine.descriptor.ExtensionUtils.streamExtensionTypes(ExtensionUtils.java:169)
org.junit.jupiter.engine.descriptor.ExtensionUtils.populateNewExtensionRegistryFromExtendWithAnnotation(ExtensionUtils.java:74)
org.junit.jupiter.engine.descriptor.ClassBasedTestDescriptor.prepare(ClassBasedTestDescriptor.java:149)
org.junit.jupiter.engine.descriptor.ClassBasedTestDescriptor.prepare(ClassBasedTestDescriptor.java:84)
org.junit.platform.engine.support.hierarchical.NodeTestTask.lambda$prepare$2(NodeTestTask.java:123)
org.junit.platform.engine.support.hierarchical.ThrowableCollector.execute(ThrowableCollector.java:73)
org.junit.platform.engine.support.hierarchical.NodeTestTask.prepare(NodeTestTask.java:123)
org.junit.platform.engine.support.hierarchical.NodeTestTask.execute(NodeTestTask.java:90)
java.base/java.util.ArrayList.forEach(ArrayList.java:1541)
org.junit.platform.engine.support.hierarchical.SameThreadHierarchicalTestExecutorService.invokeAll(SameThreadHierarchicalTestExecutorService.java:41)
org.junit.platform.engine.support.hierarchical.NodeTestTask.lambda$executeRecursively$6(NodeTestTask.java:155)
org.junit.platform.engine.support.hierarchical.ThrowableCollector.execute(ThrowableCollector.java:73)
org.junit.platform.engine.support.hierarchical.NodeTestTask.lambda$executeRecursively$8(NodeTestTask.java:141)
org.junit.platform.engine.support.hierarchical.Node.around(Node.java:137)
org.junit.platform.engine.support.hierarchical.NodeTestTask.lambda$executeRecursively$9(NodeTestTask.java:139)
org.junit.platform.engine.support.hierarchical.ThrowableCollector.execute(ThrowableCollector.java:73)
org.junit.platform.engine.support.hierarchical.NodeTestTask.executeRecursively(NodeTestTask.java:138)
org.junit.platform.engine.support.hierarchical.NodeTestTask.execute(NodeTestTask.java:95)
org.junit.platform.engine.support.hierarchical.SameThreadHierarchicalTestExecutorService.submit(SameThreadHierarchicalTestExecutorService.java:35)
org.junit.platform.engine.support.hierarchical.HierarchicalTestExecutor.execute(HierarchicalTestExecutor.java:57)
org.junit.platform.engine.support.hierarchical.HierarchicalTestEngine.execute(HierarchicalTestEngine.java:54)
org.junit.platform.launcher.core.EngineExecutionOrchestrator.execute(EngineExecutionOrchestrator.java:147)
org.junit.platform.launcher.core.EngineExecutionOrchestrator.execute(EngineExecutionOrchestrator.java:127)
org.junit.platform.testkit.engine.EngineTestKit.executeUsingLauncherOrchestration(EngineTestKit.java:263)
org.junit.platform.testkit.engine.EngineTestKit.execute(EngineTestKit.java:244)
name.remal.gradle_plugins.toolkit.testkit.AbstractJupiterTestEngineTests.executeTests(AbstractJupiterTestEngineTests.java:52)
name.remal.gradle_plugins.toolkit.testkit.AbstractJupiterTestEngineTests.executeTests(AbstractJupiterTestEngineTests.java:48)
name.remal.gradle_plugins.toolkit.testkit.AbstractJupiterTestEngineTests.executeTestsForClass(AbstractJupiterTestEngineTests.java:41)
name.remal.gradle_plugins.toolkit.testkit.MaxSupportedVersionTest.annotated_class_6(MaxSupportedVersionTest.java:46)
```
