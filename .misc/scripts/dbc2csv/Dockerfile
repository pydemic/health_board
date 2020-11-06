FROM r-base:4.0.3

WORKDIR /app

COPY setup.R dbc2csv.R ./

RUN Rscript setup.R

CMD ["Rscript", "/app/dbc2csv.R"]
