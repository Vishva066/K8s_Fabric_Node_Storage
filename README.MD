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
scp -r organizations/fabric-ca/ordererOrg/ca-cert.pem root@<ip>:/mnt/fabric/organizations/fabric-ca/ordererOrg/

scp  organizations/fabric-ca/ordererOrg/tls-cert.pem root@<ip>:/mnt/fabric/organizations/fabric-ca/ordererOrg/

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

21. Now start the peers. To start the peers execute this command

```bash
kubectl apply -f 6.peers/.

```

22. Now we have to create the genesis block. To create the genesis block execute these commands.

```bash
kubectl apply -f 7.artifacts/job-genesis.yaml

```

Next create the channel and join the orderers to the channel

```bash
kubectl apply -f 7.artifacts/job-osn.yaml

kubectl apply -f 7.artifacts/job-osn2.yaml

kubectl apply -f 7.artifacts/job-osn3.yaml
```

23. Now we have to join the peers to channel. For that we have to go inside the peer container and execute the following commands

There are two ways you can enter into a peer container inside a pod 

- Using LENS IDE
    - Go to LENS IDE in the sidebar there will be a section called workloads in that select the pod section. In that section select the pod of manufacturer and press the shell icon
- Using CLI
    - Execute this command 

    ```bash
    kubectl exec -it <pod-name> -- bash
    ```

24. Now inside this peer container execute the following script to join the channel

```bash
./scripts/joinChannel.sh
```

**Do this for all the peers**

25. Now we have to setup the peer as an anchor peer for that we have to download the binaries. To download the binaries execute this command.

```bash
apt update

apt install curl -y

curl -V

curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/master/scripts/bootstrap.sh && chmod +x bootstrap.sh

```

We should also install jq

```bash
curl -L https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64 -o jq

chmod +x jq

cp jq /usr/local/bin

jq
```

25. Download the binaries using this command

```bash
./bootstrap.sh 2.5.4 1.5.7 -s -d
```

This will install all the binaries.

Now go inside the bin folder and remove the peer binary because it already has the peer binary

```bash
cd bin

rm peer

```

Now copy the binaries to the usr/local/bin folder to be able to accessible in the full application.

```bash
cp bin/* /usr/local/bin
```

26. Set an env variable

```bash

CORE_PEER_MSPCONFIGPATH=/organizations/peerOrganizations/manufacturer.auto.com/users/Admin@manufacturer.auto.com/msp

```
27. Now execute the script file

```bash
./scripts/manufacuturer_anchor_update.sh
```

28. Do the following for other peers also


29. Now we have to install the chaincode in each peer. Do do that go inside each peer. 

- Manufacturer peer

Set the msp to admin of manufacturer and export the Orderer CA

```bash

CORE_PEER_MSPCONFIGPATH=/organizations/peerOrganizations/manufacturer.auto.com/users/Admin@manufacturer.auto.com/msp

export ORDERER_CA=/organizations/ordererOrganizations/auto.com/orderers/orderer.auto.com/msp/tlscacerts/tlsca.auto.com-cert.pem

```

Now install the chaincode using this command

```bash
cd /opt/gopath/src/github.com/chaincode/automobile/packaging

peer lifecycle chaincode install automobile-manufacturer.tgz
```

**Copy the PID and store it somewhere safe**

- Dealer Peer

Set the msp to admin of dealer and specify the orderer ca 

```bash
CORE_PEER_MSPCONFIGPATH=/organizations/peerOrganizations/dealer.auto.com/users/Admin@dealer.auto.com/msp

export ORDERER_CA=/organizations/ordererOrganizations/auto.com/orderers/orderer2.auto.com/msp/tlscacerts/tlsca.auto.com-cert.pem

```

Now install the chaincode using this command

```bash
cd /opt/gopath/src/github.com/chaincode/automobile/packaging

peer lifecycle chaincode install automobile-dealer.tgz
```

**Copy the PID and store it somewhere safe**

- MVD Peer

Set the msp to admin of mvd and specify the orderer ca 

```bash

CORE_PEER_MSPCONFIGPATH=/organizations/peerOrganizations/mvd.auto.com/users/Admin@mvd.auto.com/msp

export ORDERER_CA=/organizations/ordererOrganizations/auto.com/orderers/orderer3.auto.com/msp/tlscacerts/tlsca.auto.com-cert.pem
```

Now install the chaincode in this peer. Execute this command

```bash
cd /opt/gopath/src/github.com/chaincode/automobile/packaging

peer lifecycle chaincode install automobile-mvd.tgz
```

30. Now go to the chaincode files and edit the PIDs of each pod accordingly.

31. Now deploy the chaincode deployment files.

```bash
kubectl apply -f 8.chaincode/.
```

32. Approve the chaincode from all the org.

- Manufacturer Peer

Change the PID according to your chaincode

```bash
peer lifecycle chaincode approveformyorg --channelID autochannel --name automobile --version 1.0 --package-id automobile:3f3e9158301315b2c5b487398b88be2d7ef0f6704af8fb504d604f62eba0f98f --sequence 1 -o orderer:7050 --tls --cafile $ORDERER_CA --collections-config /opt/gopath/src/github.com/chaincode/automobile/collections.json
```

- Dealer Peer

Change the PID according to your chaincode

```bash
peer lifecycle chaincode approveformyorg --channelID autochannel --name automobile --version 1.0 --package-id automobile:ecbafb7ff1c531e151f13edee40fe5e7393c27ebc674facbf160a964c0521214 --sequence 1 -o orderer:7050 --tls --cafile $ORDERER_CA --collections-config /opt/gopath/src/github.com/chaincode/automobile/collections.json
```

- MVD Peer

Change the PID according to your chaincode

```bash
peer lifecycle chaincode approveformyorg --channelID autochannel --name automobile --version 1.0 --package-id automobile:f9ea52baffaf1add1e3a9bce37ac497da7ac4d5de244fd0ec37c12f5f9ce9940 --sequence 1 -o orderer:7050 --tls --cafile $ORDERER_CA --collections-config /opt/gopath/src/github.com/chaincode/automobile/collections.json
```

33. Before committing the chaincode we have to copy the tls certificate of all the org to their respective folders.

Now we are creating the folder structure and then copying using the scp command

```bash
mkdir -p organizations/peerOrganizations/manufacturer.auto.com/peers/peer0.manufacturer.auto.com/tls

mkdir -p organizations/peerOrganizations/dealer.auto.com/peers/peer0.dealer.auto.com/tls

mkdir -p organizations/peerOrganizations/mvd.auto.com/peers/peer0.mvd.auto.com/tls/
```

```bash
scp -r organizations/peerOrganizations/manufacturer.auto.com/peers/peer0.manufacturer.auto.com/tls/ca.crt root@<ip>:/mnt/fabric/organizations/peerOrganizations/manufacturer.auto.com/peers/peer0.manufacturer.auto.com/tls
```

34. To check whether all the org has given approval use this command chaincode execute this command from any one peer

```bash
peer lifecycle chaincode checkcommitreadiness --channelID autochannel --name automobile --version 1.0 --sequence 1 -o -orderer:7050 --tls --cafile $ORDERER_CA --collections-config /opt/gopath/src/github.com/chaincode/automobile/collections.json

```

35. To commit the chaincode execiute this command from any peer 

```bash
peer lifecycle chaincode commit -o orderer:7050 --channelID autochannel --name automobile --version 1.0 --sequence 1 --tls true --cafile $ORDERER_CA --peerAddresses peer0-manufacturer:7051 --tlsRootCertFiles /organizations/peerOrganizations/manufacturer.auto.com/peers/peer0.manufacturer.auto.com/tls/ca.crt --peerAddresses peer0-dealer:7051 --tlsRootCertFiles /organizations/peerOrganizations/dealer.auto.com/peers/peer0.dealer.auto.com/tls/ca.crt --peerAddresses peer0-mvd:7051 --tlsRootCertFiles /organizations/peerOrganizations/mvd.auto.com/peers/peer0.mvd.auto.com/tls/ca.crt --collections-config /opt/gopath/src/github.com/chaincode/automobile/collections.json
```

36. To check whether the chaincode has been committed execute this command:

```bash
peer lifecycle chaincode querycommitted --channelID autochannel
```

37. Invoke the chaincode functions to check whether the chaincode works

```bash
peer chaincode invoke -o orderer:7050 --tls true --cafile $ORDERER_CA -C autochannel -n automobile --peerAddresses peer0-manufacturer:7051 --tlsRootCertFiles /organizations/peerOrganizations/manufacturer.auto.com/peers/peer0.manufacturer.auto.com/tls/ca.crt --peerAddresses peer0-dealer:7051 --tlsRootCertFiles /organizations/peerOrganizations/dealer.auto.com/peers/peer0.dealer.auto.com/tls/ca.crt --peerAddresses peer0-mvd:7051 --tlsRootCertFiles /organizations/peerOrganizations/mvd.auto.com/peers/peer0.mvd.auto.com/tls/ca.crt -c '{"Args":["createCar","car1","Ford","Mustang","Black","12/12/2020","Ford"]}' --waitForEvent
```

38. To query the chaincode execute this command

```bash
peer chaincode query -C autochannel -n automobile -c '{"Args":["readCar","car1"]}'
```