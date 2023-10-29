# ID-HtF Tests
This is the repository to keep track of types of ID-HtF (implementation-dependent but hard to fix) tests tests found by the NonDex Gradle plugin. These ID-HtF tests are flaky because an outside library it depends on makes false assumptions on under-determined Java APIs. **We do not label them "ID"**, because the source of flakiness is outside of the scope of the repository the tests belong to, and there is **NO** practical and efficient way to maintain test functionality without calling the "flaky" methods implemented by an outside source.

## Dataset
`ID-HtF.csv` records all these tests. The format is similar with those in the `idoft` repository, and in its last column it links each test to a source of flakiness that is explained in the corresponding `.md` file.
