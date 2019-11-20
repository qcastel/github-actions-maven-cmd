# github action maven cmd

The GitHub Action for Maven wraps the Maven CLI to enable Maven cmd to be run from a docker image.
It uses JDK 11 and help you setting up the settings.xml for your private maven repository

# Usage

## Maven release

For a simple repo with not much protection and private dependency, you can do:

```
    - name: Build	
      uses: qcastel/github-actions-maven/actions/maven@master
      with:
        maven-args: "clean install"
```

If you got a private maven repo to setup in the settings.xml, you can do:
Note: we recommend putting those values in your repo secrets.

```
    - name: Build	
      uses: qcastel/github-actions-maven/actions/maven@master
      with:
        maven-repo-server-id: ${{ secrets.MVN_REPO_PRIVATE_REPO_USER }}
        maven-repo-server-username: ${{ secrets.MVN_REPO_PRIVATE_REPO_USER }}
        maven-repo-server-password: ${{ secrets.MVN_REPO_PRIVATE_REPO_PASSWORD }}
        maven-args: "clean install"
```



We welcome contributions! If your usecase is slightly different than us, just suggest a RFE or contribute to this repo directly.

# License
The Dockerfile and associated scripts and documentation in this project are released under the MIT License.
