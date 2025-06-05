"use client";

import { useCallback } from "react";
import { protocol as simpleTxProtocol } from "@tx3/protocol";

export default function TestTx3() {
  const alice = "addr_test1vqsj204gwmxklmvkkd8jtxy9jc8qp70dxjel3w2555cnjwcefzlzc";
  const bob = "addr_test1vp044lyrq26h5gv8rhtqp5y8w4ndge9tvdu65t5qee58kaqthdt2h";

  const onClick = useCallback(async () => {
    try {
      const tx = await simpleTxProtocol.transferTx(
        {
          sender: alice,
          receiver: bob,
          quantity: 1000000, // 1 ADA in lovelace
        }
      );

      console.log(tx);
    } catch (error) {
      console.error("Error resolving tx:", error);
    }
  }, []);

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-4">TX3 Test Page</h1>
      <div className="space-y-4">
        <button 
          onClick={onClick}
          className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
        >
          Resolve Tx
        </button>
        <p className="text-gray-600">
          Click the button to test the TX3 faucet protocol
        </p>
      </div>
    </div>
  );
}
