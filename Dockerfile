FROM qcastel/maven-release:0.0.35

COPY ./mvn-action.sh /usr/local/bin
COPY ./settings.xml /usr/share/maven/conf
