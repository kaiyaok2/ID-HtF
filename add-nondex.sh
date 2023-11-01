cd $1
buildFile=$(./gradlew properties | grep buildFile | awk '{print $2}')
./gradlew projects | grep "No sub-projects" | sub=$?
grep "edu.illinois.nondex" ${buildFile}
if [ $? != 0 ]; then
	if [ "$sub" == 0 ]; then
		echo "\napply plugin: 'edu.illinois.nondex'" >> ${buildFile}
	else
        for p in ${projects}; do
			subBuildFile=$(./gradlew :$p:properties | grep buildFile | awk '{print $2}')
			sed -i 's/^\( \|\t\)*test /tasks.withType(Test) /' ${subBuildFile};
		done
        projects=$(./gradlew projects | grep Project | cut -f3 -d" " | tr -d "':")
		echo "\nsubprojects {\n    apply plugin: 'edu.illinois.nondex'\n}" >> ${buildFile}
	fi
    echo "buildscript {
        repositories {
            maven {
                url = uri('https://plugins.gradle.org/m2/')
            }
        }
        dependencies {
            classpath('edu.illinois:plugin:2.1.1')
        }
    }
    $(cat ${buildFile})" > ${buildFile}
fi
sed -i '' 's/^\( \|\t\)*test /tasks.withType(Test) /' ${buildFile}