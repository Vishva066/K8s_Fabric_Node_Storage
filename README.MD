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

11. Now deploy the nfs storage

```bash

kubectl apply -f 1.nfs/.

```

12. According to your label change the nodeselector.