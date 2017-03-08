// Copyright © 2017 DWANGO Co., Ltd.

import { DataBus, DataBusHandler } from '@cross-border-bridge/data-bus';
import { MessageSender, WKWebViewMessageSender, LocationHashMessageSender, DummyMessageSender } from './MessageSender';

export class WebViewDataBus implements DataBus {
    static _instances: WebViewDataBus[] = [];
    private _sender: MessageSender;
    private _handlers: DataBusHandler[];
    private _destroyed: boolean;

    constructor() {
        if (typeof window !== 'undefined') {
            if (window.webkit && window.webkit.messageHandlers.CBBDataBus) {
                this._sender = new WKWebViewMessageSender();
            } else {
                this._sender = new LocationHashMessageSender();
            }
        } else {
            this._sender = new DummyMessageSender();
        }
        this._handlers = [];
        WebViewDataBus._instances.push(this);
    }

    send(): void {
        if (this._destroyed) return;
        this._sender.send.apply(null, arguments);
    }

    addHandler(handler: DataBusHandler): void {
        if (this._destroyed) return;
        this._handlers.push(handler);
    }

    removeHandler(handler: DataBusHandler): void {
        if (this._destroyed) return;
        this._handlers.splice(this._handlers.indexOf(handler), 1);
    }

    removeAllHandlers() {
        if (this._destroyed) return;
        this._handlers = [];
    }

    destroy() {
        if (this._destroyed) return;
        this._handlers = undefined;
        this._sender = undefined;
        this._destroyed = true;
        WebViewDataBus._instances.splice(WebViewDataBus._instances.indexOf(this), 1);
    }

    static onData(...data: any[]) {
        for (let ins of this._instances) {
            if (ins._destroyed) return;
            var r: DataBusHandler[] = [];
            ins._handlers.forEach((handler) => {
                if (handler.apply(this, data[0])) {
                    r.push(handler);
                }
            });
            for (let h of r) {
                ins.removeHandler(h);
            }
        }
    }
}
