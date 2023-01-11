# ark_pentaho

## How to build:

./get-artifacts.sh

python -m SimpleHTTPServer 8000

note: modify BUILD_SERVER in ./Dockerfile to match ip address where artifacts are being hosted

docker build -t 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_pentaho:latest .

docker push 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_pentaho:latest

## How to run: (Helm)

helm repo add arkcase https://arkcase.github.io/ark_helm_charts/

helm install ark-pentaho-ce arkcase/ark-pentaho-ce

helm uninstall ark-pentaho-ce

## How to run: (Kubernetes)

kubectl create -f pod_ark_pentaho.yaml

Look around shell

kubectl exec -it pod/ark-pentaho -- bash

Webrowser to http://server:8080/

kubectl --namespace default port-forward pod/ark-pentaho 2002 8080:8080 --address='0.0.0.0'

kubectl delete -f pod_ark_pentaho.yaml

## How to run: (Docker)

docker run --name ark_pentaho -d 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_pentaho:latest

docker exec -it ark_pentaho /bin/bash

docker stop ark_pentaho

docker rm ark_pentaho
