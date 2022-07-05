  name: postgresql-pv
spec:
  storageClassName: regionalpd-storageclass
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 300Gi
EOF




cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
 name: postgres
spec:
 strategy:
   rollingUpdate:
     maxSurge: 1
     maxUnavailable: 1
   type: RollingUpdate
 replicas: 1
 selector:
   matchLabels:
     app: postgres
 template:
   metadata:
     labels:
       app: postgres
   spec:
     containers:
       - name: postgres
         image: postgres:10
         resources:
           limits:
             cpu: "1"
             memory: "3Gi"
           requests:
             cpu: "1"
             memory: "2Gi"
         ports:
           - containerPort: 5432
         env:
           - name: POSTGRES_PASSWORD
             value: password
           - name: PGDATA
             value: /var/lib/postgresql/data/pgdata
         volumeMounts:
           - mountPath: /var/lib/postgresql/data
             name: postgredb
     volumes:
       - name: postgredb
         persistentVolumeClaim:
           claimName: postgresql-pv
EOF





cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Service
metadata:
  name: postgres
spec:
  ports:
    - port: 5432
  selector:
    app: postgres
  clusterIP: None
EOF


kubectl get pvc,pv




kubectl get deploy,pods




POD=`kubectl get pods -l app=postgres -o wide | grep -v NAME | awk '{print $1}'`

kubectl exec -it $POD -- psql -U postgres






create database gke_test_regional;

\c gke_test_regional;

CREATE TABLE test(
   data VARCHAR (255) NULL
);

insert into test values
  ('Learning GKE is fun'),
  ('Databases on GKE are easy');






select * from test;


\q



kubectl get pods -l app=postgres -o wide



CORDONED_NODE=`kubectl get pods -l app=postgres -o wide | grep -v NAME | awk '{print $7}'`

echo ${CORDONED_NODE}

gcloud compute instances list --filter="name=${CORDONED_NODE}"




kubectl cordon ${CORDONED_NODE}

kubectl get nodes




POD=`kubectl get pods -l app=postgres -o wide | grep -v NAME | awk '{print $1}'`

kubectl delete pod ${POD}




kubectl get pods -l app=postgres -o wide



NODE=`kubectl get pods -l app=postgres -o wide | grep -v NAME | awk '{print $7}'`

echo ${NODE}

gcloud compute instances list --filter="name=${NODE}"





POD=`kubectl get pods -l app=postgres -o wide | grep -v NAME | awk '{print $1}'`

kubectl exec -it $POD -- psql -U postgres




\c gke_test_regional;

select * from test;

\q






kubectl uncordon $CORDONED_NODE




kubectl delete pvc postgresql-pv
kubectl delete deploy postgres





kubectl get nodes
kubectl uncordon $CORDONED_NODE
kubectl delete pvc postgresql-pv
kubectl delete deploy postgres
gcloud container clusters resize  k8s-storage --node-pool=default-pool --num-nodes=2 --region us-central1
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql
  labels:
    app: mysql
data:
  primary.cnf: |
    # Apply this config only on the primary.
    [mysqld]
    log-bin
  replica.cnf: |
    # Apply this config only on replicas.
    [mysqld]
    super-read-only
EOF

cat <<EOF | kubectl create -f -
# Headless service for stable DNS entries of StatefulSet members.
# Headless service for stable DNS entries of StatefulSet members.
apiVersion: v1
kind: Service
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  ports:
  - name: mysql
    port: 3306
  clusterIP: None
  selector:
    app: mysql
---
# Client service for connecting to any MySQL instance for reads.
# For writes, you must instead connect to the primary: mysql-0.mysql.
apiVersion: v1
kind: Service
metadata:
  name: mysql-read
  labels:
    app: mysql
spec:
  ports:
  - name: mysql
    port: 3306
  selector:
    app: mysql
EOF

apiVersion: apps/v1
kind: StatefulSet
metadata:
spec:
gcloud container clusters resize  k8s-storage --node-pool=default-pool --num-nodes=2 --region us-central1
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql
  labels:
    app: mysql
data:
  primary.cnf: |
    # Apply this config only on the primary.
    [mysqld]
    log-bin
  replica.cnf: |
    # Apply this config only on replicas.
    [mysqld]
    super-read-only
EOF

cat <<EOF | kubectl create -f -
# Headless service for stable DNS entries of StatefulSet members.
# Headless service for stable DNS entries of StatefulSet members.
apiVersion: v1
kind: Service
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  ports:
  - name: mysql
    port: 3306
  clusterIP: None
  selector:
    app: mysql
---
# Client service for connecting to any MySQL instance for reads.
# For writes, you must instead connect to the primary: mysql-0.mysql.
apiVersion: v1
kind: Service
metadata:
  name: mysql-read
  labels:
    app: mysql
spec:
  ports:
  - name: mysql
    port: 3306
  selector:
    app: mysql
EOF

apiVersion: apps/v1
kind: StatefulSet
metadata:
spec:
apiVersion: apps/v1
kind: StatefulSet
metadata:
spec:
nano mysql-statefulset.yaml
kubectl apply -f https://k8s.io/examples/application/mysql/mysql-statefulset.yaml
watch kubectl get statefulset,pvc,pv,pods -l app=mysql
kubectl get  pods
kubectl run mysql-client --image=mysql:5.7 -i --rm --restart=Never --  mysql -h mysql-0.mysql <<EOFCREATE DATABASE test;
CREATE TABLE test.messages (message VARCHAR(250));
INSERT INTO test.messages VALUES ('hello');
EOF

kubectl run mysql-client --image=mysql:5.7 -i -t --rm --restart=Never --  mysql -h mysql-read -e "SELECT * FROM test.messages"
Waiting for pod default/mysql-client to be running, status is Pending, pod ready: false
+---------+
| message |
+---------+
| hello   |
+---------+
pod "mysql-client" deleted
kubectl run mysql-client --image=mysql:5.7 -i --rm --restart=Never --  mysql -h mysql-0.mysql <<EOFCREATE DATABASE test;
CREATE TABLE test.messages (message VARCHAR(250));
INSERT INTO test.messages VALUES ('hello');
EOF

kubectl run mysql-client --image=mysql:5.7 -i -t --rm --restart=Never --  mysql -h mysql-read -e "SELECT * FROM test.messages"
kubectl delete pod mysql-1
watch kubectl get statefulset,pvc,pv,pods -l app=mysql
kubectl scale statefulset mysql  --replicas=5
kubectl get pods -l app=mysql --watch
kubectl run mysql-client --image=mysql:5.7 -i -t --rm --restart=Never --  mysql -h mysql-3.mysql -e "SELECT * FROM test.messages"
Waiting for pod default/mysql-client to be running, status is Pending, pod ready: false
+---------+
| message |
+---------+
| hello   |
+---------+
pod "mysql-client" deleted
kubectl scale statefulset mysql --replicas=3
kubectl get pvc -l app=mysql
kubectl delete pod mysql-client-loop --now
kubectl delete statefulset mysql
gcloud container clusters delete k8s-storage
gcloud container clusters delete k8s-storage --region us-central1
cd ~/ycit019_2022/
git pull       # Pull latest Mod10_assignment
export student_name=(neural-land-303323)
cd ~/A-ElGindi
dir
git pull                              # Pull latest code from you repo
cp -r ~/ycit019_2022/Mod10_assignment/ .
git status 
git add .
git commit -m "adding `Mod10_assignment` with kubernetes YAML manifest"
git push origin master
git remote add origin https://github.com/A-ElGindi/A-ElGindi.git
git branch -M main
git push -u origin main
git remote add origin https://github.com/A-ElGindi/A-ElGindi.git
git branch -M main
git push origin master
git push -u origin main
echo "# A-ElGindi" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/A-ElGindi/A-ElGindi.git
git push -u origin main
git remote add origin https://github.com/A-ElGindi/A-ElGindi.git
git branch -M main
git push -u origin main
git remote add origin https://github.com/A-ElGindi/A-ElGindi.git
git branch -M main
git push -u origin main
git remote add origin https://github.com/A-ElGindi/A-ElGindi.git
git branch -M main
git push -u origin main
git remote add origin https://github.com/A-ElGindi/A-ElGindi.git
git branch -M main
git push -u origin main
echo "# A-ElGindi" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/A-ElGindi/A-ElGindi.git
git push -u origin main
git remote add origin https://github.com/A-ElGindi/A-ElGindi.git
git branch -M main
git push -u origin main
git remote add origin https://github.com/A-ElGindi/A-ElGindi.git
git branch -M main
git push -u origin main
git remote add origin https://github.com/A-ElGindi/A-ElGindi.git
git push -u origin main
gcloud services enable container.googleapis.com
gcloud container clusters create k8s-networking --zone us-central1-c --enable-ip-alias --create-subnetwork="" --network=default --enable-dataplane-v2 --num-nodes 2
gcloud container clusters get-credentials k8s-networking --zone us-central1-c
cd ~/$student_name-notepad/Mod10_assignment/deploy
edit gowebapp-mysql-pvc.yaml
kubectl apply -f gowebapp-mysql-pvc.yaml
kubectl get pvc
kubectl get pv
gcloud compute disks list
cd ~/$student_name-notepad/Mod10_assignment/deploy
edit gowebapp-mysql-deployment.yaml
cd ~/$student_name-notepad/Mod10_assignment/deploy/
kubectl apply -f secret-mysql.yaml              #Create Secret
kubectl apply -f gowebapp-mysql-service.yaml    #Create Service
kubectl apply -f gowebapp-mysql-deployment.yaml #Create Deployment
cd ~/$student_name/Mod10_assignment/deploy/
kubectl apply -f secret-mysql.yaml              #Create Secret
kubectl apply -f gowebapp-mysql-service.yaml    #Create Service
kubectl apply -f gowebapp-mysql-deployment.yaml #Create Deployment
dir
cd /Mod10_assignment
cd ~/Mod10_assignment
dir
cd ~/deploy
cd deploy
kubectl apply -f secret-mysql.yaml              #Create Secret
kubectl apply -f gowebapp-mysql-service.yaml    #Create Service
kubectl apply -f gowebapp-mysql-deployment.yaml #Create Deployment
cd ..
kubectl get pods
cd ~/Mod10_assignment
cd deploy
kubectl get pods
cd ..
kubectl get pods
cd ..
kubectl get pods
kubectl get describe $POD
cd ~/Mod10_assignment/gowebapp/config/
kubectl create configmap gowebapp --from-file=webapp-config-json=config.json
kubectl describe configmap gowebapp
cd ~/Mod10_assignment/deploy/
kubectl apply -f gowebapp-service.yaml    #Create Service
kubectl apply -f gowebapp-deployment.yaml #Create Deployment
kubectl get pods
kubectl get svc gowebapp -o wide
EXTERNAL-IP:9000
#TODO delete the gowebapp service
cd ~/Mod10_assignment/deploy/
edit gowebapp-service.yaml
kubectl apply -f gowebapp-service.yaml   #Re-Create the service
edit gowebapp-ingress.yaml
kubectl apply -f gowebapp-ingress.yaml   #Create Ingress
cd ..
kubectl apply -f gowebapp-ingress.yaml   #Create Ingress
edit gowebapp-ingress.yaml
kubectl apply -f gowebapp-ingress.yaml   #Create Ingress
kubectl describe ingress gowebapp-ingress
dir
kubectl get ing gowebapp-ingress
kubectl get ing gowebapp-ingress.yaml
cd ~/Mod10_assignment/deploy/
edit default-deny.yaml
kubectl apply -f default-deny.yaml   # deny-all Ingress Traffic inside Namespace
kubectl describe netpol default-deny
cd ~/Mod10_assignment/deploy/
edit gowebapp-mysql-netpol.yaml
kubectl apply -f gowebapp-mysql-netpol.yaml   # `mysql` pod can be accessed from the `gowebapp` pod
kubectl describe netpol backend-policy
edit gowebapp-netpol.yaml
kubectl apply -f gowebapp-netpol.yaml  # `gowebapp` pod from Internet on CIDR: `35.191.0.0/16` and `130.211.0.0/22`
kubectl describe netpol frontend-policy
kubectl get ing gowebapp-ingress
cd ..
kubectl get ing gowebapp-ingress
git add .
git commit -m "k8s manifests for Hands-on Assignment 6"
git push origin master
git push u origin master
git push -u origin master
git push origin master
git push -u origin master
git push -u origin master 
gcloud container clusters delete k8s-scaling
gcloud container clusters delete k8s-scaling --zone us-central1-c
gcloud container clusters delete k8s-scaling --zone us-central1
gcloud container clusters delete k8s-networking --zone us-central1-c
git add .
git commit -m "adding DOCKREFILEs and Readme"
git push origin master
git add .
git commit -m "adding docker-compose.yml"
git add .
git commit -m "k8s manifests"
git add .
git commit -m "k8s manifests for Hands-on Assignment 4"
