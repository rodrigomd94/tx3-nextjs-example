// This file is auto-generated.

import { Client as TRPClient, type ClientOptions, type TxEnvelope } from 'tx3-sdk/trp';

export const DEFAULT_TRP_ENDPOINT = "http://localhost:8164";

export const DEFAULT_HEADERS = {
    'api_key': '',
};

export const DEFAULT_ENV_ARGS = {
};

export type TransferParams = {
    quantity: number;
    receiver: string;
    sender: string;
}

export const TRANSFER_IR = {
    bytecode: "11000000000000000000000001000000000000000600000000000000736f7572636501010c000000060000000000000073656e64657205000000010b000000010000000000000000000000000000000c00000008000000000000007175616e746974790200000000000000000000000000000200000000000000010c000000080000000000000072656365697665720500000000010b000000010000000000000000000000000000000c00000008000000000000007175616e7469747902000000010c000000060000000000000073656e64657205000000000110000000100000000f0000000600000000000000736f757263650b000000010000000000000000000000000000000c00000008000000000000007175616e7469747902000000010000001100000001000000000000000000000000000000000000000000000000000000",
    encoding: "hex",
    version: "v1alpha4",
};

export class Client {
    readonly #client: TRPClient;

    constructor(options: ClientOptions) {
        this.#client = new TRPClient(options);
    }

    async transferTx(args: TransferParams): Promise<TxEnvelope> {
        return await this.#client.resolve({
            tir: TRANSFER_IR,
            args,
        });
    }
}

// Create a default client instance
export const protocol = new Client({
    endpoint: DEFAULT_TRP_ENDPOINT,
    headers: DEFAULT_HEADERS,
    envArgs: DEFAULT_ENV_ARGS,
});
