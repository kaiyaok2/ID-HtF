./gradlew nondexTest -i >  NonDexFullInfo.log
GIDErrorString="Cannot change default excludes during the build. They were changed from"
grep -r "$GIDErrorString" NonDexFullInfo.log > NonDexGID.log
GIDnum=$(wc -l <  NonDexGID.log)
tac NonDexFullInfo.log > reversedFullInfo.log
./gradlew nondexTest >  NonDex.log
grep -v " PASSED" NonDex.log > tmpfile && mv tmpfile NonDex.log
sed -i '' 's/ \> /\./g'  NonDex.log
sed -i '' 's/ \> /\./g'  reversedFullInfo.log
[ -e  NonDexReportedTests.txt ] && rm  NonDexReportedTests.txt
[ -e  RemainingTestsFailingReasons.tmp ] && rm  RemainingTestsFailingReasons.tmp
sed -n -e '/Across all seeds:/,/Test results can be found at: / p'  NonDex.log | sed -e '1d;$d' | gcut -f1 -d' ' --complement | tr -d '()'| while read line;do echo ${line};done >  NonDexReportedTests.txt
testNum=$(wc -l <  NonDexReportedTests.txt)
if [[ "$GIDnum" -gt "0" ]]; then
    if [[ "$testNum" -gt "0" ]]; then
        info=" is extremely likely an ID-HtF test due to Gradle flakiness"
        echo It is extremely likely that there are ID-HtF tests due to Gradle flakiness
        cp NonDexReportedTests.txt remainingTests.tmp
        echo "" >> remainingTests.tmp
        workingOnInstance=1
        cat reversedFullInfo.log | while read line; do
            if [[ "$line" = *"$GIDErrorString"* ]]; then
                workingOnInstance=$((workingOnInstance-1))
            fi
            if [[ "$workingOnInstance" -lt "1" ]]; then
                trimmedLine=$(echo "$line" | awk '{$NF="";sub(/[ \t]+$/,"")}1')
                if [[ -n "${trimmedLine// /}" ]]; then
                    index=0;while  [[ $index -le $testNum ]]; do
                        testAtIndex=$(sed -n "${index}p"  remainingTests.tmp)
                        if [[ "$testAtIndex" = *"$trimmedLine"* ]]; then
                            echo "${testAtIndex}${info}"
                            grep -v "$testAtIndex" remainingTests.tmp > tmpfile && mv tmpfile remainingTests.tmp
                            workingOnInstance=1
                            break
                        fi
                        camelCaseTrimmedLine=$( echo "$trimmedLine" | awk 'BEGIN{OFS=""};{for(j=1;j<=NF;j++){ if(j!=1){$j=toupper(substr($j,1,1)) substr($j,2) }}}1')
                        if [[ "$testAtIndex" = *"$camelCaseTrimmedLine"* ]]; then
                            echo "${testAtIndex}${info}"
                            grep -v "${testAtIndex}" remainingTests.tmp > tmpfile && mv tmpfile remainingTests.tmp
                            workingOnInstance=1
                            break
                        fi
                        index=$((index+1));
                    done
                fi
            fi
        done
    fi
fi
head -n -1 remainingTests.tmp > tmpfile && mv tmpfile remainingTests.tmp
echo $(wc -l <  remainingTests.tmp)
touch RemainingTestsFailingReasons.tmp
if [[ "$testNum" -gt "0" ]]; then
    logLength=$(wc -l <  NonDex.log)
    cat  remainingTests.tmp | while read line; do
        found=1
        lineNum=0;while  [[ $lineNum -le $logLength ]]; do
            curLine=$(sed -n "${lineNum}p"  NonDex.log)
            if [[ "$found" -le "0" ]]; then
                echo "$curLine" >>  RemainingTestsFailingReasons.tmp
                break
            fi
            trimmedCurLine=$(echo "$curLine" | awk '{$NF="";sub(/[ \t]+$/,"")}1')
            if [[ -n "${trimmedCurLine// /}" ]]; then 
                if [[ "$line" = *"$trimmedCurLine"* ]]; then
                    found=$((found-1))
                fi
                camelCaseTrimmedCurLine=$( echo "$trimmedCurLine" | awk 'BEGIN{OFS=""};{for(j=1;j<=NF;j++){ if(j!=1){$j=toupper(substr($j,1,1)) substr($j,2) }}}1')
                if [[ "$line" = *"$camelCaseTrimmedCurLine"* ]]; then
                    found=$((found-1))
                fi
            fi
        lineNum=$((lineNum+1));
        done
    done
fi
remainingTestNum=$(wc -l <  remainingTests.tmp)
x=1;while  [[ $x -le $remainingTestNum ]]; do
    cur=$(sed -n "${x}p"  RemainingTestsFailingReasons.tmp)
    status=0
    for substr in 'AssertionFailedError' 'AssertionError' 'VerificationException' 'ComparisonFailure' 'Condition not satisfied'; do
        if [[ "$cur" = *"$substr"* ]]; then
            gsed -i "${x}s/$/ is likely a normal ID test/"  remainingTests.tmp
            status=$((status+1))
        fi
    done
    if [[ "$status" -eq "0" ]]; then
        gsed -i "${x}s/$/ is likely ID-HtF/"  remainingTests.tmp
    fi
    x=$((x+1));
done
cat remainingTests.tmp
rm remainingTests.tmp
rm NonDexReportedTests.txt
rm RemainingTestsFailingReasons.tmp