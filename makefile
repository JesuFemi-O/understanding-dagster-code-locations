.PHONY: network postgres build run webserver daemon open clean all

network:
	docker network create dagster-poc-network || true

postgres: network
	docker run -d --name dagster-poc-postgres \
	-e POSTGRES_USER=postgres \
	-e POSTGRES_PASSWORD=postgres \
	-e POSTGRES_DB=dagster_poc \
	-p 5432:5432 \
	--network dagster-poc-network \
	postgres:latest || true

build:
	cd finance_code_location && docker build -t finance_svc:dev . && cd ..
	cd marketing_code_location && docker build -t maketing_svc:dev . && cd ..
	cd ml_code_location && docker build -t ml_svc:dev . && cd ..
	docker build -t dagster_web_daemon_svc:dev .

run: build
	@echo "Starting code location services..."
	docker run -d -e DAGSTER_POSTGRES_USER=postgres -e DAGSTER_POSTGRES_PASSWORD=postgres \
	-e DAGSTER_POSTGRES_DB=dagster_poc -e DAGSTER_CURRENT_IMAGE=finance_svc:dev \
	-p 4000:4000 --network dagster-poc-network finance_svc:dev \
	dagster api grpc -h 0.0.0.0 -p 4000 --module-name definitions

	docker run -d -e DAGSTER_POSTGRES_USER=postgres -e DAGSTER_POSTGRES_PASSWORD=postgres \
	-e DAGSTER_POSTGRES_DB=dagster_poc -e DAGSTER_CURRENT_IMAGE=maketing_svc:dev \
	-p 4001:4000 --network dagster-poc-network maketing_svc:dev \
	dagster api grpc -h 0.0.0.0 -p 4000 --module-name definitions

	docker run -d -e DAGSTER_POSTGRES_USER=postgres -e DAGSTER_POSTGRES_PASSWORD=postgres \
	-e DAGSTER_POSTGRES_DB=dagster_poc -e DAGSTER_CURRENT_IMAGE=ml_svc:dev \
	-p 4002:4000 --network dagster-poc-network ml_svc:dev \
	dagster api grpc -h 0.0.0.0 -p 4000 --module-name definitions

webserver: run
	@echo "Starting the Dagster Webserver..."
	docker run -d -e DAGSTER_POSTGRES_USER=postgres -e DAGSTER_POSTGRES_PASSWORD=postgres \
	-e DAGSTER_POSTGRES_DB=dagster_poc \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-p 3000:3000 --network dagster-poc-network \
	dagster_web_daemon_svc:dev \
	dagster-webserver -h 0.0.0.0 -p 3000 -w workspace.yaml

daemon: webserver
	@echo "Starting the Dagster Daemon..."
	docker run -d --name poc_daemon -e DAGSTER_POSTGRES_USER=postgres -e DAGSTER_POSTGRES_PASSWORD=postgres \
	-e DAGSTER_POSTGRES_DB=dagster_poc \
	-v /var/run/docker.sock:/var/run/docker.sock \
	--network dagster-poc-network dagster_web_daemon_svc:dev \
	dagster-daemon run

open:
	open http://localhost:3000 || xdg-open http://localhost:3000

clean:
	@echo "Stopping and removing all containers..."
	@if [ -n "$$(docker ps -q --filter network=dagster-poc-network)" ]; then \
		docker stop $$(docker ps -q --filter network=dagster-poc-network); \
	fi
	@if [ -n "$$(docker ps -aq --filter network=dagster-poc-network)" ]; then \
		docker rm -f $$(docker ps -aq --filter network=dagster-poc-network); \
	fi
	@echo "Removing the network..."
	@if docker network inspect dagster-poc-network >/dev/null 2>&1; then \
		docker network rm dagster-poc-network; \
	fi
	@echo "Removing images..."
	docker rmi -f finance_svc:dev maketing_svc:dev ml_svc:dev dagster_web_daemon_svc:dev || true

all: postgres build run webserver daemon
