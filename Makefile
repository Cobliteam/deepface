test:
	cd tests && python -m pytest . -s --disable-warnings

lint:
	python -m pylint deepface/ --fail-under=10

coverage:
	pip install pytest-cov && cd tests && python -m pytest --cov=deepface

generate_docker_image:
	docker build -f ./Dockerfile . --progress=plain -t deepface

deploy_to_prod:
	@echo "****** Deploying origin/master commit to prod cluster"
	@read -p "Are you sure you want to continue? [press enter to continue or ctrl+c to exit]" ctn
	helm upgrade --install deepface deploy/helm --namespace coblicam --kube-context cobli-prod
