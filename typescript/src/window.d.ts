// Copyright © 2017 DWANGO Co., Ltd.

declare type CallbackHandler = (...data: any[]) => void;

declare interface WKScriptMessageHandlerInterface {
    postMessage(...data: any[]): void;
}

declare interface WebkitMessageHandlers {
    CBBDataBus: WKScriptMessageHandlerInterface;
}

declare interface Webkit {
    messageHandlers: WebkitMessageHandlers;
}

declare interface Window {
    webkit: Webkit;
}

declare let CBBDataBusMessageReceiver: CallbackHandler;
