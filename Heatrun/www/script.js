// Copyright © 2017 DWANGO Co., Ltd.
var dataBus = new CBB.WebViewDataBus();
var counter = 0;

var handler = function() {
    if (arguments[0] === "Request") {
        dataBus.send("Response");
    } else {
        counter++;
        if (counter % 10000 === 0) {
            alert("Received 10000 response");
        }
    }
};

dataBus.addHandler(handler);

function OnStart() {
    console.log("send 10000 request");
    for (var i = 0; i < 10000; i++) {
        dataBus.send("Request");
    }
}
