# deepface - Cobli Fork
Deepface original readme can be found here: https://github.com/serengil/deepface

### Building image
After making some update on the code or dependencies, you must generate a new image:
```
make generate_docker_image
```

Then run docker for your new image, commit it to a tag from ECR and push it.
```
docker run deepface
docker commit <your-container> 911383825788.dkr.ecr.us-east-1.amazonaws.com/cobli-internal/deepface:<your-tag>
docker push 911383825788.dkr.ecr.us-east-1.amazonaws.com/cobli-internal/deepface:<your-tag>
```

Finally, update `appImageVersion` to <your-tag> in values.yaml and run:
```
make deploy_to_prod
```
