# K8s BEL V0

## Steps

1. Create the cluster using the Kubespray tool.

2. After creating the cluster if you get any timeout error copy the config file to this particular location

```bash
cd 

mkdir .kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

3. Label all the nodes in the cluster according to a key value pair.



4. Give permission to this config file. For now I have given permission as chmod -R 777 but we can change it later

```bash
sudo chmod -R 777 .kube/
```

5. Now setup  a new VM for NFS-server

6. Install the nfs-server using the following steps.

``` bash
cd /

sudo apt update

sudo apt install nfs-kernel-server

sudo mkdir -p /mnt/nfs_share

sudo chown -R nobody:nogroup /mnt/nfs_share/

```


Check if ownership updated : 

`ls -la /mnt/nfs_share`

Give executable permission to the directory :

`sudo chmod 777 /mnt/nfs_share/`

Check the nfs server configuration file :

`cat /etc/exports`

Configure the NFS (Network File System) server by adding an entry for the nfs_share to the /etc/exports file. This will expose the folder and * means any ip can connect to this server folder or we can specify our custom IP there if you want.

`echo "/mnt/nfs_share *(rw,sync,no_subtree_check,insecure)" | sudo tee -a /etc/exports`

Check the nfs server configuration file , the new config will be added at end:

`cat /etc/exports`

Export the file : 

`sudo exportfs -a`

Restart the nfs server :

`sudo systemctl restart nfs-kernel-server`

Now nfs server is configured and up and running

7. Install the nfs client on all the worker VMs

```bash
sudo apt install nfs-common
```
We can mount directly from the pod itself

8. Now go inside each worker VM and create a folder. Inside this folder the persistent storage will be stored


```bash

cd /mnt

mkdir fabric

```

9. Now change the nfs ip according to the ip of the nfs and change it in the 1.pod/pv.yaml

10. Clone the git repo into master, worker1, worker2, worker3,worker4.

11. After cloning now go inside the worker 1 and copy the prerequisite0 folder to /mnt/fabric path.

VM1

```bash
cd <repo-name>

cd prerequisite-0

sudo cp -r . /mnt/fabric/
```

VM2
```bash
cd <repo-name>

cd prerequisite-1

sudo cp -r . /mnt/fabric/
```


VM3
```bash
cd <repo-name>

cd prerequisite-2

sudo cp -r . /mnt/fabric/
```

VM4
```bash
cd <repo-name>

cd prerequisite-3

sudo cp -r . /mnt/fabric/
```

12. Now deploy the nfs storage

```bash

kubectl apply -f 1.nfs/.

```

13. According to your label change the nodeselector.

14. After deploying the nfs you can remove the task-pv-pod as it is only for testing

15. Now create the fabric-ca for each org

```bash

kubectl apply -f 2.ca/.
```

16. Now copy the orderer ca certificates to other vms using the scp command

Syntax of scp
```bash
scp -r /path/to/local/directory user@remote_host:/path/to/remote/destination/

To copy the folder from remote machine to your machine

scp -r user@192.168.1.100:/path/to/remote/myfolder /path/to/local/destination/

```

Eg

```bash
scp -r organizations/fabric-ca/ordererOrg/ root@<ip>:/mnt/fabric/organizations/fabric-ca/

```

17. After copying all the certificates give permission to access these certificates using the chmod command in all the worker nodes which you have copied these certificates

```bash

cd /

cd mnt/fabric

sudo chmod -R 777 organizations/

```

18. Now we have to generate the certificates in order to generate the certifcates we have deploy the jobs. Execute this command

```bash

kubectl apply -f 3.certificates/.

```

19. Now we have to start the ordering service. Here we are also copying the ordering certificates to our nfs server. TO start the ordering service execute this command

```bash

kubectl apply -f 4.orderer/.

```

20. Now create the config map inside the config map we will be having the configuration of core.yaml and external chaincode scripts. To create the config map use this command.

```bash
kubectl apply -f 5.configmap/.

```

21. 