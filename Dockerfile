FROM qcastel/maven-release:0.0.44

COPY ./mvn-action.sh /usr/local/bin
COPY ./settings.xml /usr/share/maven/conf

# Installer PostgreSQL et postgresql-client
RUN apk add --no-cache postgresql postgresql-client postgresql-contrib

# Créer le répertoire de données PostgreSQL
RUN mkdir -p /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/lib/postgresql/data

# Initialiser la base de données PostgreSQL
USER postgres
RUN initdb -D /var/lib/postgresql/data

# Configurer PostgreSQL pour accepter les connexions locales (trust pour simplifier)
RUN echo "host all all 127.0.0.1/32 trust" >> /var/lib/postgresql/data/pg_hba.conf && \
    echo "host all all ::1/128 trust" >> /var/lib/postgresql/data/pg_hba.conf && \
    echo "local all all trust" >> /var/lib/postgresql/data/pg_hba.conf && \
    echo "listen_addresses='*'" >> /var/lib/postgresql/data/postgresql.conf

# Revenir à root pour le reste
USER root

# Copier le code source
WORKDIR /github/workspace
COPY . /github/workspace

# Installer su-exec pour changer d'utilisateur
RUN apk add --no-cache su-exec
