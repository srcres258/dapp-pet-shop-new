import { Label } from '@/components/ui/label';
import {
  useConnection
} from 'wagmi';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { useWriteContract, useReadContract } from 'wagmi';
import { useState, useEffect } from 'react';
import { contractAddress, contractABI } from '@/constants';
import { useQueryClient } from '@tanstack/react-query';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

function CreateNewTrade() {
  const { address } = useConnection();
  const [buyer, setBuyer] = useState('');
  const [duration, setDuration] = useState('');
  const [priceCT, setPriceCT] = useState('');
  const { mutate: writeContract, isPending, isSuccess, error } = useWriteContract();

  const handleCreateTrade = () => {
    if (!address || !buyer || !duration || !priceCT) return;
    writeContract({
      address: contractAddress.TradeFactory,
      abi: contractABI.TradeFactory,
      functionName: 'createTrade',
      args: [buyer as `0x${string}`, BigInt(duration), BigInt(priceCT)],
    });
  };

  return (
    <div className="flex flex-col items-center space-y-4 mb-4">
      <div className="flex justify-center items-center space-x-4">
        <Label>Buyer Address:</Label>
        <Input
          type="text"
          placeholder="Enter Buyer Address"
          value={buyer}
          onChange={(e) => setBuyer(e.target.value)}
        />
      </div>
      <div className="flex justify-center items-center space-x-4">
        <Label>Duration (seconds):</Label>
        <Input
          type="text"
          placeholder="Enter Duration"
          value={duration}
          onChange={(e) => setDuration(e.target.value)}
        />
      </div>
      <div className="flex justify-center items-center space-x-4">
        <Label>Price CT:</Label>
        <Input
          type="text"
          placeholder="Enter Price CT"
          value={priceCT}
          onChange={(e) => setPriceCT(e.target.value)}
        />
      </div>
      <Button onClick={handleCreateTrade} disabled={isPending}>
        {isPending ? 'Creating...' : 'Create Trade'}
      </Button>
      {isSuccess && <span>Success!</span>}
      {error && <span>Error: {error.message}</span>}
    </div>
  );
}

function TradeList() {
  const { address } = useConnection();
  const [tokenIdsInput, setTokenIdsInput] = useState('');

  const { data: tradeAddresses, isLoading, error } = useReadContract({
    address: contractAddress.Viewer,
    abi: contractABI.Viewer,
    functionName: 'getUserAllTrades',
    args: address ? [address] : undefined,
    query: { enabled: !!address }
  });

  if (isLoading) {
    return <div>Loading trades...</div>;
  }

  if (error) {
    return <div>Error loading trades: {error.message}</div>;
  }

  return (
    <div>
      <div className="mb-4">
        <Label>Token IDs to Deposit (comma separated):</Label>
        <Input
          type="text"
          placeholder="e.g. 1,2,3"
          value={tokenIdsInput}
          onChange={(e) => setTokenIdsInput(e.target.value)}
        />
      </div>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Trade Address</TableHead>
            <TableHead>Seller</TableHead>
            <TableHead>Buyer</TableHead>
            <TableHead>Expiration</TableHead>
            <TableHead>Price CT</TableHead>
            <TableHead>Active</TableHead>
            <TableHead>Actions</TableHead>
            <TableHead>Deposit</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {(tradeAddresses as `0x${string}`[])?.map((tradeAddr) => (
            <TradeRow key={tradeAddr} tradeAddr={tradeAddr} userAddr={address!} tokenIdsInput={tokenIdsInput} />
          ))}
        </TableBody>
      </Table>
    </div>
  );
}

function TradeRow({ tradeAddr, userAddr, tokenIdsInput }: { tradeAddr: `0x${string}`, userAddr: `0x${string}`, tokenIdsInput: string }) {
  const queryClient = useQueryClient();

  const { data: seller } = useReadContract({
    address: tradeAddr,
    abi: contractABI.Trade,
    functionName: 'seller',
  });

  const { data: buyer } = useReadContract({
    address: tradeAddr,
    abi: contractABI.Trade,
    functionName: 'buyer',
  });

  const { data: expiration } = useReadContract({
    address: tradeAddr,
    abi: contractABI.Trade,
    functionName: 'expiration',
  });

  const { data: priceCT } = useReadContract({
    address: tradeAddr,
    abi: contractABI.Trade,
    functionName: 'priceCT',
  });

  const { data: active } = useReadContract({
    address: tradeAddr,
    abi: contractABI.Trade,
    functionName: 'active',
  });

  const { mutate: confirmTrade, isPending: confirmPending } = useWriteContract();
  const { mutate: cancelTrade, isPending: cancelPending } = useWriteContract();
  const { mutate: expireTrade, isPending: expirePending } = useWriteContract();
  const { mutate: depositCP, isPending: depositPending } = useWriteContract();

  useEffect(() => {
    if (confirmPending || cancelPending || expirePending || depositPending) return;
    queryClient.invalidateQueries({ queryKey: ['readContract', contractAddress.Viewer] });
  }, [confirmPending, cancelPending, expirePending, depositPending, queryClient]);

  const handleConfirm = () => {
    confirmTrade({
      address: tradeAddr,
      abi: contractABI.Trade,
      functionName: 'confirm',
    });
  };

  const handleCancel = () => {
    cancelTrade({
      address: tradeAddr,
      abi: contractABI.Trade,
      functionName: 'cancel',
    });
  };

  const handleExpire = () => {
    expireTrade({
      address: tradeAddr,
      abi: contractABI.Trade,
      functionName: 'expire',
    });
  };

  const handleDeposit = () => {
    const ids = tokenIdsInput.split(',').map(id => {
      const trimmed = id.trim();
      const num = parseInt(trimmed, 10);
      return isNaN(num) ? null : BigInt(num);
    }).filter(id => id !== null && id > 0n) as bigint[];
    if (ids.length === 0) return;
    depositCP({
      address: tradeAddr,
      abi: contractABI.Trade,
      functionName: 'depositCP',
      args: [ids],
    });
  };

  const isExpired = !!expiration && Number(expiration as bigint) < Date.now() / 1000;

  return (
    <TableRow>
      <TableCell>{tradeAddr}</TableCell>
      <TableCell>{seller as string}</TableCell>
      <TableCell>{buyer as string}</TableCell>
      <TableCell>{expiration ? new Date(Number(expiration) * 1000).toLocaleString() : 'N/A'}</TableCell>
      <TableCell>{priceCT?.toString()}</TableCell>
      <TableCell>{(active as boolean) ? 'Yes' : 'No'}</TableCell>
      <TableCell>
        {(active as boolean) && (
          <div className="flex space-x-2">
            {(buyer as string) === userAddr && (
              <Button onClick={handleConfirm} disabled={confirmPending}>
                {confirmPending ? 'Confirming...' : 'Confirm'}
              </Button>
            )}
            {(seller as string) === userAddr && (
              <Button onClick={handleCancel} disabled={cancelPending}>
                {cancelPending ? 'Cancelling...' : 'Cancel'}
              </Button>
            )}
            {isExpired && (
              <Button onClick={handleExpire} disabled={expirePending}>
                {expirePending ? 'Expiring...' : 'Expire'}
              </Button>
            )}
          </div>
        )}
      </TableCell>
      <TableCell>
        {(seller as string) === userAddr && (active as boolean) && (
          <Button onClick={handleDeposit} disabled={depositPending}>
            {depositPending ? 'Depositing...' : 'Deposit'}
          </Button>
        )}
      </TableCell>
    </TableRow>
  );
}

function Trade() {
  const { address, isConnected } = useConnection();

  if (!isConnected || address === undefined) {
    return <Label>您还未连接钱包. 请先连接您的钱包!</Label>
  }

  return (
    <div>
      <Label>Trade Page</Label>
      <CreateNewTrade />
      <TradeList />
    </div>
  );
}

export default Trade;
