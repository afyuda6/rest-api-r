FROM r-base:4.4.2

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 PORT=8080

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /rest-api-r

COPY . /rest-api-r

RUN R -e "install.packages(c('httpuv', 'DBI', 'RSQLite', 'jsonlite'))"

EXPOSE 8080

CMD ["Rscript", "main.r"]