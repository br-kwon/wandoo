var db = require('../db');
var room = require('../models/room');

var queryBuilder = function (qs, data, callback) {
  db.query(qs, data, function (err, result) {
    if (err) {
      callback(err);
    } else {
      callback(null, result);
    }
  });
}

module.exports = {
  getAll : function (callback) {
    var qs = "select * from wandoo where status='A' order by start_time asc;";
    queryBuilder(qs, [], callback);  
  },

  getPartialRes : function (params, callback) {
    var qs = "select * from wandoo where wandooID >= ? order by start_time asc limit ?;";
    queryBuilder(qs, params, callback);
  },

  getByHost : function (userID, callback) {
    var qs = "select * from wandoo where userID = ?;"
    queryBuilder(qs, userID, callback);
  },

  getByUser : function (userID, callback) {
    var qs1 = 'select latitude, longitude from user where userID = ?;';
    var qs2 = "select * from wandoo where status ='A' order by start_time asc;"
    db.query(qs1, userID, function (err, results1) {
      if (err) {
        callback(err);
      } else if (!results1.length) {
        callback('The specified userID does not exist');
      } else if (!results1[0].latitude || !results1[0].longitude) {
        callback('The user location is undefined');
      } else {
        var location = [results1[0].latitude, results1[0].longitude];
        db.query(qs2, [], function (err, results2) {
          if (err) {
            callback(err);
          } else {
            callback(err, results2, location);
          }
        });
      }
    })

  },

  create : function (wandooData, callback) {
    var qs = 'INSERT INTO `wandoo` (`wandooID`,`userID`,`text`,`start_time`,\
    `end_time`,`post_time`,`latitude`,`longitude`,`num_people`,`status`) VALUES \
    (0,?,?,?,?,?,?,?,?,"A");';
    queryBuilder(qs, wandooData, callback);
  },

  delete : function (wandooID, callback) {
    var qs1 = "delete from wandoo_interest where wandooID = ?;" 
    var qs2 = "delete from wandoo_tag where wandooID = ?;"
    var qs3 = "delete from wandoo where wandooID = ?;"

    db.query(qs1, wandooID, function (err, results1) {
      if (err) {
        callback(err);
      } else {
        db.query(qs1, wandooID, function (err, results2) {
          if (err) {
            callback(err);
          } else {
            room.deleteByWandoo(wandooID, function (err, results3) {
              if (err) {
                callback(err);
              } else {
                db.query(qs3, wandooID, function (err, results4) {
                  if (err) {
                    callback(err);
                  } else {
                    callback(null, results1, results2, results3, results4);
                  }
                });
              }
            });
          }
        });
      }
    });
  }
}
