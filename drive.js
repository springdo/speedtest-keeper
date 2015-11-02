/**
 * Created by donal on 01/11/2015.
 */

var google = require('googleapis');
var fs = require('fs');
var readline = require('readline');

var OAuth2Client = google.auth.OAuth2;


// Client ID and client secret are available at
// https://code.google.com/apis/console
var CLIENT_ID = process.env.GOOGLE_CLIENT_ID;
var CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET;
var REDIRECT_URL = 'http://localhost';


var oauth2Client = new OAuth2Client(CLIENT_ID, CLIENT_SECRET,REDIRECT_URL);

var rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function getAccessToken(oauth2Client, callback) {
  // generate consent page url
  var url = oauth2Client.generateAuthUrl({
    access_type: 'offline', // will return a refresh token
    scope: 'https://www.googleapis.com/auth/drive' // can be a space-delimited string or an array of scopes
  });

  console.log('Visit the url: ', url);
  rl.question('Enter the code here:', function(code) {
    // request access token
    oauth2Client.getToken(code, function(err, tokens) {
      // set tokens to the client
      // TODO: tokens should be set by OAuth2 client.
      oauth2Client.setCredentials(tokens);
      callback();
    });
  });
}

// retrieve an access token
getAccessToken(oauth2Client, function() {
  // retrieve user profile
  var drive = google.drive({ version: 'v2', auth: oauth2Client });
  var data = {
    resource: {
      title: 'test-scores',
      mimeType: 'text/plain'
      },
    media: {
      mimeType: 'text/plain',
      body: fs.createReadStream('test_scores.csv')
      }
    };
  drive.files.insert( data, function(err, res) {
    if (err) {
      console.log('An error occured', err);
      return;
    }
    console.log(res);
  });
});

