#!/usr/bin/env node
var AWS = require("aws-sdk");
var spawn = require("child_process").spawn;
var role = process.argv[2];
var STS = new AWS.STS();
STS.assumeRole({
  RoleArn: role+'/yisen.zhang',
	RoleSessionName: 'yisen.zhang'
}, function(error, data) {
  if (error) {
    console.error(error);
    process.exit(1);
  }
  var modEnv = process.env;
  modEnv.AWS_ACCESS_KEY_ID = data.Credentials.AccessKeyId;
  modEnv.AWS_SECRET_ACCESS_KEY = data.Credentials.SecretAccessKey;
  modEnv.AWS_SESSION_TOKEN = data.Credentials.SessionToken;
	modEnv.AWS_SECURITY_TOKEN = data.Credentials.SessionToken;
	spawn(process.env.SHELL, {
    env: modEnv,
    stdio: "inherit"
  });
	console.log("success");
});
