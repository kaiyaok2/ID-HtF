## Description:
- Gradle enforces developers to declare their excluded files (i.e. `.gitignore`) in the earliest file to be configured in the build lifecycle (i.e., setting scripts like `settings.gradle.kts`) , and disallows any change to the list of excluded files during the build. Then, in each build routine, Gradle stores the excluded files in a  `fileTree`. It is noticeable that projects likely do not specify such list, so a default one is assigned. Gradle then relies on an outside class `DirectoryScanner` (developed by `Ant`) to keep track of the list of these excluded files. However, the `DirectoryScanner` class implements its static `defaultExcludes` collection as a `HashSet`, and the getter to this collection is simply `toArray()`. 

During execution, Gradle simply does an `Arrays.equals()` to check if the Array representation of `defaultExcludes` remains the same during the build. It throws an error if the equality check fails, and it did since NonDex shuffled the `HashSet` iterator. Finally, it sorts the two Arrays to appear in the error message, so if we execute two consecutive NonDex-modified Surefire runs on a unit test that assumes a Gradle build succeeded, a sample error may appear: 
`org.gradle.api.InvalidUserCodeException: Cannot change default excludes during the build. They were changed from [foo, bar, xyz] to [foo, bar, xyz]. `

## Link to source of flakiness:
Line 102 in `PatternSpecFactory.java`. Repository: https://github.com/gradle/gradle. SHA: 30b58807bde3a1f541070f71c1e38505c0216cf7
(Notice that the two arrays can have permuted orders.)


## Additional Information:

The NonDex `ONE` mode does not report the error above - in `ONE` mode the order of the `defaultExcludes` HashSet is only changed in the first access (the build test gets executed for the first time), so consecutive NonDex runs does not "make the HashSet look different". However, in `FULL` mode, after the first access, all following (or repeated) build tests suffer once they go through the check for excluded files.
