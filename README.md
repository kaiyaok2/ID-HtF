# NonDex_Gradle_NOD_Tests
This is the repository to keep track of types of NOD (non-order-dependent) tests tests found by the NonDex Gradle plugin. These NOD tests are flaky because an outside library it depends on makes false assumptions on under-determined Java APIs. In other words, the source of flakiness is outside of the scope of the repository the tests belong to. 

## Dataset
`nondex-gradle-nod.csv` records all these tests. The format is similar with those in the `idoft` repository, and in its last column it links each test to a source of flakiness that is explained in the corresponding `.md` file.
