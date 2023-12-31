# use github API to get a list of Gradle repos

import requests
import math
import sys

if __name__ == '__main__':
    if len(sys.argv) != 8:
        print("You need to provide your Github username, your token, min_stars, max_stars, earliest_created, latest_created and pages")
        sys.exit(1)
    username, token, min_stars, max_stars, earliest_created, latest_created, pages = sys.argv[1:]
    session = requests.Session()
    session.auth = (username,token)

    filter = "stars:" + min_stars + ".." + max_stars + "+" + "created:" + earliest_created + ".." + latest_created

    f = open("repos.txt", "x")

    for page in range(int(pages)):
        #r = session.get("https://api.github.com/search/repositories?q=gradle+in:topic+" + filter + "&per_page=100&sort=stars&order=desc&page=" + str(page + 1))
        r = session.get("https://api.github.com/search/repositories?q=gradlew+in:readme+stars:200..200000+&per_page=100&sort=stars&order=desc&page=" + str(page + 1))
        r = r.json()
        for item in r['items']:
            f.write(item["full_name"]+"\n")
    f.close()
