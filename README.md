# MeteorN - A Simple Tool to Run Meteor App with an Nginx Reverse Proxy

MeteorN is meant to help you run your Meteor app with a reverse proxy of Nginx at the front end in docker containers.

A reverse proxy can serve many purpose such as firewall or load balancer.

But for me, the most important thing is that reverse proxy can help me add SSL support to my web app.

This project is composed of two parts.

Use the `Basic` version if you do not need SSL.

Otherwise, check the `SSLImplementd` one out.
## Notice
- Ensure docker compose **v1.6**  or above is installed.
- Don't play with  **lsEncrypt** too frequently, because there is a [quota][qt] on how many certificates you can get per week**.

## Which Branch to use:
- master for the newest version of Meteor
- pre1.4 for older version

## How to Use the Basic Version


###  1. Build Your Meteor App into a Plain Node Js Application

The Meteor tool has a command `meteor build` that creates a deployment bundle which contains a plain Node.js application.

Before using it, you'll have to install all the npm dependencis for your app in advance.

Also it's important to chose a correct target architecture for your app, you can specify it  with `--architecture`.

Issue these commands inside your Meteor app folder.

~~~shell
npm install --production
meteor build /tmp --architecture os.linux.x86_64
~~~

After finishing these two commands, you will find a bundle file in **/tmp**.(Named as projectName.tar.gz)

###  2. Clone MeteorN

~~~shell
cd /tmp
git clone https://github.com/lo-tp/MeteorN.git
cp projectName.tar.gz  MeteorN/Basic
cd MeteorN/Basic
~~~

### 3. Build And Run
~~~shell
docker-compose build
docker-compose up
~~~
You can also run `docker-compose up -d` to run your application in the background.

If this is your first time running or you have recreated the containers, then you would have to create the **mongo replica set**.
It's very easy, just run `docker exec   -it primary mongo /tmp/script/primary.js` and you are done.

Now your app is happily running on your server.

## How to Use the SSLImplemented Version
It's largely similiar to the use of the `Basic` version.

All the relevant files are located in the `MeteorN/SSLImplemented` folder.

There is one more thing to be done before using this version.

You'll have to copy your SSL cirtificate file and SSL cirtificate key to the `MeteorN/SSLImplemented/ssl` folder respectively as cert.pem and privkey.pem.

Then run `docker-compose up` and your meteor app is ready to go with SSL support.

**One thing to mention: The http traffic is redirected to https by default.**

If you want to keep the http working, you can edit the Nginx configure file located at `conf` folder.

## How to Use the lsEncrypt Version

In addtion to the steps described in the [Basic Version](#how-to-use-the-basic-version).

Some more file modifications are necessary.

Find these lines in `docker-compose.yml`.
```yml
environment:
	- DOMAIN=www.test.xyz
	- MAIL=test@hotmail.com
```
Change the values of `MAIL` and `DOMAIN` to your domain name and email address.

Then open `conf/cert.conf`.
```
domains = www.test.xyz
email=test@hotmail.com
rsa-key-size = 4096
authenticator = webroot
webroot-path = /tmp
```
Change the first two lines to your domain name and email address.

Also change all the domain names from **www.test.xyz** to your own contained in `conf/nginx.conf`.

```
http{
	upstream app_servers {
		server meteor:8080;
	}
	server {
		listen 80 ;
		server_name www.test.xyz                				#This Line
		location '/.well-known/acme-challenge' {
			...
		}
		location / {
			return    301 https://$server_name$request_uri;
		}
	}
	server { 
		listen 443; 
		ssl on; 
		ssl_certificate /etc/letsencrypt/live/www.test.xyz/cert.pem;            #This Line
		ssl_certificate_key /etc/letsencrypt/live/www.test.xyz/privkey.pem;     #This Line
		...
		location / {
		...
		}
	}
}

events {
	worker_connections 1024;
}
```

Now run `docker-compose up` and wait for the **Nginx** container to automatically get the necessary SSL files from [Let's Encrypt][lpt] and serve your website in https mode.

## The Configurations about the Mongo Replica Set.

Two files are pertinent to the configuration of the mongo replica set of your app.
- `./docker-compose.yml`.
- `./script/primary.js`.

`./docker-compose.yml` is where we define our replica set.
```
version: '2'
services: 
   node:
       container_name: meteor_test
       build: 
         context: .
         dockerfile: ./dockerfiles/node.dockerfile
       environment:
         - MONGO_URL=mongodb://pri:27017/meteor?replicaSet=test&readPreference=primaryPreferred&w=majority
         - MONGO_OPG_URL=mongodb://pri:27017/local?replicaSet=test
         - ROOT_URL=http://127.0.0.1
         - PORT=8080
       command:  node main.js
       restart: always                      
       networks:
               mongo_net:
                       aliases:
                                   - app
       ports:
           - 8080:8080
   primary:
       container_name: primary_test
       image: mongo:3.2.8
       restart: always                      
       volumes:
           - ./script/:/tmp/script/
       command: [mongod,--replSet,test]
       networks:
               mongo_net:
                       aliases:
                               - pri
networks:
     mongo_net:
```
Take this snippet as an example,we defined two docker services, one to run the app and one to serve as a primary in the mongo replica set.

In this docker-compose file, a subnet named **mongo_net** and all the two services above have alias in this subnet.
All the aliases are used to compose the **MONGO_URL** and **MONGO_OPG_URL** environment variables for the node service.

Then let's check the `./script/primary.js`.
```js
var secondaries=['s1'];
var arb='arb';
rs.initiate();
secondaries.forEach(function(address){
  print(address);
  rs.add(address);
});
rs.addArb(arb);
rs.conf();
```
What this file does is to initiate a replica set and add the secondaries and arbiter to it if existing.

The `secondaries` and the `arb` variable are where you should store the corresponding aliases.

Advanced replica set configuration can be achived by modifying this java script file.

Use this project as a starting point if you want to incorporate other remote mongo instances into your replica set.

For more infomation about the configuration of mongo replica set, check this [page][repconf].

Make sure every is ok and fire up your project with `docker-compose up`. 

Now All you have to do is to open a bash inside your primary mongo instance: `docker exec -it primary_test bash`,

Run the js script to initialize the mongo replica set inside the the previous opened bash: `mongo /tmp/script/primary.js`

After all these, you project is ready to go.

## Use the Nginx Reverse Proxy to Do Other Thing

You can edit the `conf/nginx.conf` to implement other functionalities with the reverse proxy.


[lpt]:https://letsencrypt.org/
[repconf]:https://docs.mongodb.com/manual/reference/replication/
[qt]:https://letsencrypt.org/docs/rate-limits/
