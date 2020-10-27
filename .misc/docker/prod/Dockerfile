FROM pydemic/health_board:release AS release
FROM erlang:22.3.4-alpine

WORKDIR /app

COPY --from=release /app/_build/prod/rel/health_board .
COPY start.sh start.sh

CMD ["sh", "/app/start.sh"]
