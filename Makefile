.PHONY: test db.start db.stop arbor.test

test: db.start arbor.test db.stop

db.start:
	docker-compose up -d
	sleep 5

db.stop:
	docker-compose down

arbor.test:
	ARBOR_DB_USER=postgres mix test

arbor.tdd:
	ARBOR_DB_USER=postgres mix test.watch
