(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.CBB = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
// Copyright © 2017 DWANGO Co., Ltd.
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var URLScheme = "cbb-data-bus://";
var WKWebViewMessageSender = (function () {
    function WKWebViewMessageSender() {
    }
    WKWebViewMessageSender.prototype.send = function () {
        var data = [];
        for (var _i = 0; _i < arguments.length; _i++) {
            data[_i] = arguments[_i];
        }
        window.webkit.messageHandlers.CBBDataBus.postMessage([data]);
    };
    return WKWebViewMessageSender;
}());
exports.WKWebViewMessageSender = WKWebViewMessageSender;
var LocationHashMessageSender = (function () {
    function LocationHashMessageSender() {
    }
    LocationHashMessageSender.prototype.send = function () {
        location.hash = URLScheme + JSON.stringify(arguments);
    };
    return LocationHashMessageSender;
}());
exports.LocationHashMessageSender = LocationHashMessageSender;
var DummyMessageSender = (function () {
    function DummyMessageSender() {
    }
    DummyMessageSender.prototype.send = function () {
        if (typeof CBBDataBusMessageReceiver !== 'undefined') {
            CBBDataBusMessageReceiver(arguments);
        }
    };
    return DummyMessageSender;
}());
exports.DummyMessageSender = DummyMessageSender;

},{}],2:[function(require,module,exports){
// Copyright © 2017 DWANGO Co., Ltd.
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var MessageSender_1 = require("./MessageSender");
var WebViewDataBus = (function () {
    function WebViewDataBus() {
        if (typeof window !== 'undefined') {
            if (window.webkit && window.webkit.messageHandlers.CBBDataBus) {
                this._sender = new MessageSender_1.WKWebViewMessageSender();
            }
            else {
                this._sender = new MessageSender_1.LocationHashMessageSender();
            }
        }
        else {
            this._sender = new MessageSender_1.DummyMessageSender();
        }
        this._handlers = [];
        WebViewDataBus._instances.push(this);
    }
    WebViewDataBus.prototype.send = function () {
        if (this._destroyed)
            return;
        this._sender.send.apply(null, arguments);
    };
    WebViewDataBus.prototype.addHandler = function (handler) {
        if (this._destroyed)
            return;
        this._handlers.push(handler);
    };
    WebViewDataBus.prototype.removeHandler = function (handler) {
        if (this._destroyed)
            return;
        this._handlers.splice(this._handlers.indexOf(handler), 1);
    };
    WebViewDataBus.prototype.removeAllHandlers = function () {
        if (this._destroyed)
            return;
        this._handlers = [];
    };
    WebViewDataBus.prototype.destroy = function () {
        if (this._destroyed)
            return;
        this._handlers = undefined;
        this._sender = undefined;
        this._destroyed = true;
        WebViewDataBus._instances.splice(WebViewDataBus._instances.indexOf(this), 1);
    };
    WebViewDataBus.onData = function () {
        var _this = this;
        var data = [];
        for (var _i = 0; _i < arguments.length; _i++) {
            data[_i] = arguments[_i];
        }
        for (var _a = 0, _b = this._instances; _a < _b.length; _a++) {
            var ins = _b[_a];
            if (ins._destroyed)
                return;
            var r = [];
            ins._handlers.forEach(function (handler) {
                if (handler.apply(_this, data[0])) {
                    r.push(handler);
                }
            });
            for (var _c = 0, r_1 = r; _c < r_1.length; _c++) {
                var h = r_1[_c];
                ins.removeHandler(h);
            }
        }
    };
    return WebViewDataBus;
}());
WebViewDataBus._instances = [];
exports.WebViewDataBus = WebViewDataBus;

},{"./MessageSender":1}],3:[function(require,module,exports){
// Copyright © 2017 DWANGO Co., Ltd.
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var WebViewDataBus_1 = require("./WebViewDataBus");
exports.WebViewDataBus = WebViewDataBus_1.WebViewDataBus;

},{"./WebViewDataBus":2}]},{},[3])(3)
});
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIm5vZGVfbW9kdWxlcy9icm93c2VyLXBhY2svX3ByZWx1ZGUuanMiLCJsaWIvTWVzc2FnZVNlbmRlci5qcyIsImxpYi9XZWJWaWV3RGF0YUJ1cy5qcyIsImxpYi9pbmRleC5qcyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiQUFBQTtBQ0FBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7O0FDckNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTs7QUMxRUE7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBIiwiZmlsZSI6ImdlbmVyYXRlZC5qcyIsInNvdXJjZVJvb3QiOiIiLCJzb3VyY2VzQ29udGVudCI6WyIoZnVuY3Rpb24gZSh0LG4scil7ZnVuY3Rpb24gcyhvLHUpe2lmKCFuW29dKXtpZighdFtvXSl7dmFyIGE9dHlwZW9mIHJlcXVpcmU9PVwiZnVuY3Rpb25cIiYmcmVxdWlyZTtpZighdSYmYSlyZXR1cm4gYShvLCEwKTtpZihpKXJldHVybiBpKG8sITApO3ZhciBmPW5ldyBFcnJvcihcIkNhbm5vdCBmaW5kIG1vZHVsZSAnXCIrbytcIidcIik7dGhyb3cgZi5jb2RlPVwiTU9EVUxFX05PVF9GT1VORFwiLGZ9dmFyIGw9bltvXT17ZXhwb3J0czp7fX07dFtvXVswXS5jYWxsKGwuZXhwb3J0cyxmdW5jdGlvbihlKXt2YXIgbj10W29dWzFdW2VdO3JldHVybiBzKG4/bjplKX0sbCxsLmV4cG9ydHMsZSx0LG4scil9cmV0dXJuIG5bb10uZXhwb3J0c312YXIgaT10eXBlb2YgcmVxdWlyZT09XCJmdW5jdGlvblwiJiZyZXF1aXJlO2Zvcih2YXIgbz0wO288ci5sZW5ndGg7bysrKXMocltvXSk7cmV0dXJuIHN9KSIsIi8vIENvcHlyaWdodCDCqSAyMDE3IERXQU5HTyBDby4sIEx0ZC5cblwidXNlIHN0cmljdFwiO1xuT2JqZWN0LmRlZmluZVByb3BlcnR5KGV4cG9ydHMsIFwiX19lc01vZHVsZVwiLCB7IHZhbHVlOiB0cnVlIH0pO1xudmFyIFVSTFNjaGVtZSA9IFwiY2JiLWRhdGEtYnVzOi8vXCI7XG52YXIgV0tXZWJWaWV3TWVzc2FnZVNlbmRlciA9IChmdW5jdGlvbiAoKSB7XG4gICAgZnVuY3Rpb24gV0tXZWJWaWV3TWVzc2FnZVNlbmRlcigpIHtcbiAgICB9XG4gICAgV0tXZWJWaWV3TWVzc2FnZVNlbmRlci5wcm90b3R5cGUuc2VuZCA9IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgdmFyIGRhdGEgPSBbXTtcbiAgICAgICAgZm9yICh2YXIgX2kgPSAwOyBfaSA8IGFyZ3VtZW50cy5sZW5ndGg7IF9pKyspIHtcbiAgICAgICAgICAgIGRhdGFbX2ldID0gYXJndW1lbnRzW19pXTtcbiAgICAgICAgfVxuICAgICAgICB3aW5kb3cud2Via2l0Lm1lc3NhZ2VIYW5kbGVycy5DQkJEYXRhQnVzLnBvc3RNZXNzYWdlKFtkYXRhXSk7XG4gICAgfTtcbiAgICByZXR1cm4gV0tXZWJWaWV3TWVzc2FnZVNlbmRlcjtcbn0oKSk7XG5leHBvcnRzLldLV2ViVmlld01lc3NhZ2VTZW5kZXIgPSBXS1dlYlZpZXdNZXNzYWdlU2VuZGVyO1xudmFyIExvY2F0aW9uSGFzaE1lc3NhZ2VTZW5kZXIgPSAoZnVuY3Rpb24gKCkge1xuICAgIGZ1bmN0aW9uIExvY2F0aW9uSGFzaE1lc3NhZ2VTZW5kZXIoKSB7XG4gICAgfVxuICAgIExvY2F0aW9uSGFzaE1lc3NhZ2VTZW5kZXIucHJvdG90eXBlLnNlbmQgPSBmdW5jdGlvbiAoKSB7XG4gICAgICAgIGxvY2F0aW9uLmhhc2ggPSBVUkxTY2hlbWUgKyBKU09OLnN0cmluZ2lmeShhcmd1bWVudHMpO1xuICAgIH07XG4gICAgcmV0dXJuIExvY2F0aW9uSGFzaE1lc3NhZ2VTZW5kZXI7XG59KCkpO1xuZXhwb3J0cy5Mb2NhdGlvbkhhc2hNZXNzYWdlU2VuZGVyID0gTG9jYXRpb25IYXNoTWVzc2FnZVNlbmRlcjtcbnZhciBEdW1teU1lc3NhZ2VTZW5kZXIgPSAoZnVuY3Rpb24gKCkge1xuICAgIGZ1bmN0aW9uIER1bW15TWVzc2FnZVNlbmRlcigpIHtcbiAgICB9XG4gICAgRHVtbXlNZXNzYWdlU2VuZGVyLnByb3RvdHlwZS5zZW5kID0gZnVuY3Rpb24gKCkge1xuICAgICAgICBpZiAodHlwZW9mIENCQkRhdGFCdXNNZXNzYWdlUmVjZWl2ZXIgIT09ICd1bmRlZmluZWQnKSB7XG4gICAgICAgICAgICBDQkJEYXRhQnVzTWVzc2FnZVJlY2VpdmVyKGFyZ3VtZW50cyk7XG4gICAgICAgIH1cbiAgICB9O1xuICAgIHJldHVybiBEdW1teU1lc3NhZ2VTZW5kZXI7XG59KCkpO1xuZXhwb3J0cy5EdW1teU1lc3NhZ2VTZW5kZXIgPSBEdW1teU1lc3NhZ2VTZW5kZXI7XG4iLCIvLyBDb3B5cmlnaHQgwqkgMjAxNyBEV0FOR08gQ28uLCBMdGQuXG5cInVzZSBzdHJpY3RcIjtcbk9iamVjdC5kZWZpbmVQcm9wZXJ0eShleHBvcnRzLCBcIl9fZXNNb2R1bGVcIiwgeyB2YWx1ZTogdHJ1ZSB9KTtcbnZhciBNZXNzYWdlU2VuZGVyXzEgPSByZXF1aXJlKFwiLi9NZXNzYWdlU2VuZGVyXCIpO1xudmFyIFdlYlZpZXdEYXRhQnVzID0gKGZ1bmN0aW9uICgpIHtcbiAgICBmdW5jdGlvbiBXZWJWaWV3RGF0YUJ1cygpIHtcbiAgICAgICAgaWYgKHR5cGVvZiB3aW5kb3cgIT09ICd1bmRlZmluZWQnKSB7XG4gICAgICAgICAgICBpZiAod2luZG93LndlYmtpdCAmJiB3aW5kb3cud2Via2l0Lm1lc3NhZ2VIYW5kbGVycy5DQkJEYXRhQnVzKSB7XG4gICAgICAgICAgICAgICAgdGhpcy5fc2VuZGVyID0gbmV3IE1lc3NhZ2VTZW5kZXJfMS5XS1dlYlZpZXdNZXNzYWdlU2VuZGVyKCk7XG4gICAgICAgICAgICB9XG4gICAgICAgICAgICBlbHNlIHtcbiAgICAgICAgICAgICAgICB0aGlzLl9zZW5kZXIgPSBuZXcgTWVzc2FnZVNlbmRlcl8xLkxvY2F0aW9uSGFzaE1lc3NhZ2VTZW5kZXIoKTtcbiAgICAgICAgICAgIH1cbiAgICAgICAgfVxuICAgICAgICBlbHNlIHtcbiAgICAgICAgICAgIHRoaXMuX3NlbmRlciA9IG5ldyBNZXNzYWdlU2VuZGVyXzEuRHVtbXlNZXNzYWdlU2VuZGVyKCk7XG4gICAgICAgIH1cbiAgICAgICAgdGhpcy5faGFuZGxlcnMgPSBbXTtcbiAgICAgICAgV2ViVmlld0RhdGFCdXMuX2luc3RhbmNlcy5wdXNoKHRoaXMpO1xuICAgIH1cbiAgICBXZWJWaWV3RGF0YUJ1cy5wcm90b3R5cGUuc2VuZCA9IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgaWYgKHRoaXMuX2Rlc3Ryb3llZClcbiAgICAgICAgICAgIHJldHVybjtcbiAgICAgICAgdGhpcy5fc2VuZGVyLnNlbmQuYXBwbHkobnVsbCwgYXJndW1lbnRzKTtcbiAgICB9O1xuICAgIFdlYlZpZXdEYXRhQnVzLnByb3RvdHlwZS5hZGRIYW5kbGVyID0gZnVuY3Rpb24gKGhhbmRsZXIpIHtcbiAgICAgICAgaWYgKHRoaXMuX2Rlc3Ryb3llZClcbiAgICAgICAgICAgIHJldHVybjtcbiAgICAgICAgdGhpcy5faGFuZGxlcnMucHVzaChoYW5kbGVyKTtcbiAgICB9O1xuICAgIFdlYlZpZXdEYXRhQnVzLnByb3RvdHlwZS5yZW1vdmVIYW5kbGVyID0gZnVuY3Rpb24gKGhhbmRsZXIpIHtcbiAgICAgICAgaWYgKHRoaXMuX2Rlc3Ryb3llZClcbiAgICAgICAgICAgIHJldHVybjtcbiAgICAgICAgdGhpcy5faGFuZGxlcnMuc3BsaWNlKHRoaXMuX2hhbmRsZXJzLmluZGV4T2YoaGFuZGxlciksIDEpO1xuICAgIH07XG4gICAgV2ViVmlld0RhdGFCdXMucHJvdG90eXBlLnJlbW92ZUFsbEhhbmRsZXJzID0gZnVuY3Rpb24gKCkge1xuICAgICAgICBpZiAodGhpcy5fZGVzdHJveWVkKVxuICAgICAgICAgICAgcmV0dXJuO1xuICAgICAgICB0aGlzLl9oYW5kbGVycyA9IFtdO1xuICAgIH07XG4gICAgV2ViVmlld0RhdGFCdXMucHJvdG90eXBlLmRlc3Ryb3kgPSBmdW5jdGlvbiAoKSB7XG4gICAgICAgIGlmICh0aGlzLl9kZXN0cm95ZWQpXG4gICAgICAgICAgICByZXR1cm47XG4gICAgICAgIHRoaXMuX2hhbmRsZXJzID0gdW5kZWZpbmVkO1xuICAgICAgICB0aGlzLl9zZW5kZXIgPSB1bmRlZmluZWQ7XG4gICAgICAgIHRoaXMuX2Rlc3Ryb3llZCA9IHRydWU7XG4gICAgICAgIFdlYlZpZXdEYXRhQnVzLl9pbnN0YW5jZXMuc3BsaWNlKFdlYlZpZXdEYXRhQnVzLl9pbnN0YW5jZXMuaW5kZXhPZih0aGlzKSwgMSk7XG4gICAgfTtcbiAgICBXZWJWaWV3RGF0YUJ1cy5vbkRhdGEgPSBmdW5jdGlvbiAoKSB7XG4gICAgICAgIHZhciBfdGhpcyA9IHRoaXM7XG4gICAgICAgIHZhciBkYXRhID0gW107XG4gICAgICAgIGZvciAodmFyIF9pID0gMDsgX2kgPCBhcmd1bWVudHMubGVuZ3RoOyBfaSsrKSB7XG4gICAgICAgICAgICBkYXRhW19pXSA9IGFyZ3VtZW50c1tfaV07XG4gICAgICAgIH1cbiAgICAgICAgZm9yICh2YXIgX2EgPSAwLCBfYiA9IHRoaXMuX2luc3RhbmNlczsgX2EgPCBfYi5sZW5ndGg7IF9hKyspIHtcbiAgICAgICAgICAgIHZhciBpbnMgPSBfYltfYV07XG4gICAgICAgICAgICBpZiAoaW5zLl9kZXN0cm95ZWQpXG4gICAgICAgICAgICAgICAgcmV0dXJuO1xuICAgICAgICAgICAgdmFyIHIgPSBbXTtcbiAgICAgICAgICAgIGlucy5faGFuZGxlcnMuZm9yRWFjaChmdW5jdGlvbiAoaGFuZGxlcikge1xuICAgICAgICAgICAgICAgIGlmIChoYW5kbGVyLmFwcGx5KF90aGlzLCBkYXRhWzBdKSkge1xuICAgICAgICAgICAgICAgICAgICByLnB1c2goaGFuZGxlcik7XG4gICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgfSk7XG4gICAgICAgICAgICBmb3IgKHZhciBfYyA9IDAsIHJfMSA9IHI7IF9jIDwgcl8xLmxlbmd0aDsgX2MrKykge1xuICAgICAgICAgICAgICAgIHZhciBoID0gcl8xW19jXTtcbiAgICAgICAgICAgICAgICBpbnMucmVtb3ZlSGFuZGxlcihoKTtcbiAgICAgICAgICAgIH1cbiAgICAgICAgfVxuICAgIH07XG4gICAgcmV0dXJuIFdlYlZpZXdEYXRhQnVzO1xufSgpKTtcbldlYlZpZXdEYXRhQnVzLl9pbnN0YW5jZXMgPSBbXTtcbmV4cG9ydHMuV2ViVmlld0RhdGFCdXMgPSBXZWJWaWV3RGF0YUJ1cztcbiIsIi8vIENvcHlyaWdodCDCqSAyMDE3IERXQU5HTyBDby4sIEx0ZC5cblwidXNlIHN0cmljdFwiO1xuT2JqZWN0LmRlZmluZVByb3BlcnR5KGV4cG9ydHMsIFwiX19lc01vZHVsZVwiLCB7IHZhbHVlOiB0cnVlIH0pO1xudmFyIFdlYlZpZXdEYXRhQnVzXzEgPSByZXF1aXJlKFwiLi9XZWJWaWV3RGF0YUJ1c1wiKTtcbmV4cG9ydHMuV2ViVmlld0RhdGFCdXMgPSBXZWJWaWV3RGF0YUJ1c18xLldlYlZpZXdEYXRhQnVzO1xuIl19
