## Dckerize Meteor - A Simple to Use Docker Runtime for Meteor


### 1. Build Your Meteor App into a Plain Node Js Application

The Meteor tool has a command `meteor build` that creates a deployment bundle that contains a plain Node.js application.

Before use it, you'll have to install all the npm dependencis fo your app.

Also it's important to chose a correct target architecture for your app, you can specify with `--architecture`.

Issue these commands on your app folder.

~~~shell
npm install --production
meteor build .. --architecture os.linux.x86_64
~~~
