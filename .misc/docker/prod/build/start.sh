#!/bin/sh
set -e

/app/bin/health_board eval "HealthBoard.Release.Repo.migrate"
/app/bin/health_board start
