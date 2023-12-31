function download_build() {
  user=$(dirname $1)
  repo=$(basename $1)
  dir=github.com/${user}/${repo}
  echo "$user $repo"
  mkdir -p ${dir}
  if [[ -f ${dir}/build.gradle ]]; then
    echo file ${dir}/build.gradle already exist
  else
    (
      cd ${dir}
      curl -f -O -s https://raw.githubusercontent.com/${user}/${repo}/master/build.gradle
    )
  fi
  if [ $? == 0 ]; then
    echo "ANDROID!!!"
    grep -i android ${dir}/build.gradle
    if [ $? == 1 ]; then
        echo $user/$repo >> repos_refined2.txt
    fi
  fi
}

touch repos_refined2.txt
for f in $(cat $1); do
    echo ========== trying to dowload $f
    download_build $f
done