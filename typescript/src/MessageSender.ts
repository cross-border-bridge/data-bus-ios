// Copyright © 2017 DWANGO Co., Ltd.

const URLScheme = "cbb-data-bus://";

export interface MessageSender {
    send(...data: any[]): void;
}

export class WKWebViewMessageSender implements MessageSender {
    send(...data: any[]): void {
        window.webkit.messageHandlers.CBBDataBus.postMessage([data]);
    }
}

export class LocationHashMessageSender implements MessageSender {
    send(): void {
        location.hash =  URLScheme + JSON.stringify(arguments);
    }
}

export class DummyMessageSender implements MessageSender {
    send(): void {
        if (typeof CBBDataBusMessageReceiver !== 'undefined') {
            CBBDataBusMessageReceiver(arguments);
        }
    }
}
