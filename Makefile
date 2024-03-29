.PHONY:  build-start-container-dev build-start-container-prod stop-container

SERVICE=MPESA-B2B-API-WRAPPER
DB=${DATABASE_URL}

build-start-container-dev:
	@echo "Build images then create and start containers (DEV MODE)"
	docker compose up -d --build

build-start-container-prod:
ifeq ($(DB),)
	@echo "DATABASE_URL must be set!"
	@echo "Usage: make build-start-container-prod DATABASE_URL=url_to_your_prod_db"
else
	@echo "About to spawn a ${SERVICE} containerized service (PROD MODE) 🤭"
	@echo "PRODUCTION DATABASE 🗄️  ~> ${DATABASE_URL}"
	DATABASE_URL=${DATABASE_URL} docker compose -f compose-prod.yaml up -d --build
endif

stop-container:
	@echo "Stopping and removing containers, networks and volumes"
	docker compose down --remove-orphans -v