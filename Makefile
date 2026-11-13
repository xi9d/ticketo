.PHONY: up obs auth all down reset logs ps seed verify-seed baseline

up:
	docker compose up -d --wait

obs:
	docker compose --profile observability up -d --wait

auth:
	docker compose --profile auth up -d --wait

all:
	docker compose --profile observability --profile auth up -d --wait

down:
	docker compose down

reset:
	docker compose down -v
	docker compose up -d --wait
	$(MAKE) seed verify-seed

logs:
	docker compose logs -f

ps:
	docker compose ps --all

seed:
	docker compose exec -T postgres psql -U ticketo -d ticketo -v ON_ERROR_STOP=1 < docker/postgres/seed/seed.sql

verify-seed:
	docker compose exec -T postgres psql -U ticketo -d ticketo -v ON_ERROR_STOP=1 < docker/postgres/seed/verify.sql

baseline:
	bash ./scripts/baseline.sh $(LABEL)