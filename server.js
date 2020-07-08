const express = require("express");
const getLabel = require("./shipkeeBot");
const shipkeeBot = require("./shipkeeBot");
// const getReport = require("./getReport");

var reportInJson;
var app = express();
app.use(express.static(__dirname + "/public"));

app.get("/home", function (req, res) {
  console.log("Got a GET request for the homepage");

  res.sendFile("index.html", {
    root: __dirname,
  });
});

app.get(
  "/getLabel/:orderNumber/:weight/:value/:width/:height/:length",
  async function (req, res) {
    console.log("Got a GET request for the label page");
    console.log(req.params);
    var orderNumber = req.params.orderNumber;
    var weight = req.params.weight;
    var value = req.params.value;
    var width = req.params.width;
    var height = req.params.height;
    var length = req.params.length;
    // if (password !== "Benandesty1!") {
    //   res.status(500).send("Incorrect Password");
    //   return
    // }

    await shipkeeBot
      .getLabel(orderNumber, weight, value, width, height, length)
      .then(
        function (value) {
          reportInJson = value;
          res.send(value);
        },
        function (err) {
          res.status(500).send(err);
          console.log(err);
        }
      );
  }
);

const PORT = process.env.PORT || 8080;
var server = app.listen(PORT, function () {
  server.setTimeout(500000);
  var host = server.address().address;
  var port = server.address().port;

  console.log("Example app listening at http://%s:%s", host, port);
});
