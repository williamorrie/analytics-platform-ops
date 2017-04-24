/*
*  This rule been automatically generated by auth0-authz-extension
 */
function (user, context, callback) {
  // If connection is not passwordless skip this rule
  if (context.connection !== 'email') {
    return callback(null, user, context);
  }

  var _ = require('lodash');
  var EXTENSION_URL = "https://kerinmoj.eu.webtask.io/adf6e2f2b84784b57522e3b19dfc9201";
  var API_KEY = "YOUR_EXTENSION_API_KEY";

  getPolicy(user, context, function(err, res, data) {
    if (err) {
      console.log('Error from Authorization Extension:', err);
      return callback(new UnauthorizedError('Authorization Extension: ' + err.message));
    }

    if (res.statusCode !== 200) {
      console.log('Error from Authorization Extension:', res.body || res.statusCode);
      return callback(
        new UnauthorizedError('Authorization Extension: ' + ((res.body && (res.body.message || res.body) || res.statusCode)))
      );
    }

    // Add permissions (from Authorization Extension) to the user object.
    user.permissions = data.permissions;

    // Check if user has permission to view this shiny app
    if (!canViewShinyApp(user)) {
      return callback(new UnauthorizedError('Access denied.'));
    }

    return callback(null, user, context);
  });

  function canViewShinyApp(user) {
    // NOTE: 'view-shiny-app' is the name of the permission but the
    //       authorization plugin only expose the permissions for the current
    //       client the user is trying to log into.
    return _.includes(user.permissions, 'view-shiny-app');
  }

  // Get the policy for the user.
  function getPolicy(user, context, cb) {
    request.post({
      url: EXTENSION_URL + "/api/users/" + user.user_id + "/policy/" + context.clientID,
      headers: {
        "x-api-key": API_KEY
      },
      json: {
        connectionName: context.connection || user.identities[0].connection,
        groups: user.groups
      },
      timeout: 5000
    }, cb);
  }
}