import { Label } from '@/components/ui/label';
import {
  useConnection
} from 'wagmi';
import { useOwnedPets } from '@/hooks/CustomPet';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { useWriteContract } from 'wagmi';
import { useState } from 'react';
import { contractAddress, contractABI } from '@/constants';

function OwnedPetList(props: { address: `0x${string}` }) {
  const address = props.address;

  const { tokenIds, isLoading, error } = useOwnedPets(address);

  if (isLoading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error: {error.message}</div>;
  }

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>序号</TableHead>
          <TableHead>Token ID</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {tokenIds.map((tokenId, index) => (
          <TableRow key={tokenId.toString()}>
            <TableCell>{index + 1}</TableCell>
            <TableCell>{tokenId.toString()}</TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}

function MintPet(props: { address: `0x${string}` }) {
  const address = props.address;
  const [uri, setUri] = useState('');
  const { mutate: writeContract, isPending, isSuccess, error } = useWriteContract();

  const handleMint = () => {
    if (!address || !uri) return;
    writeContract({
      address: contractAddress.CustomPet,
      abi: contractABI.CustomPet,
      functionName: 'mint',
      args: [address, uri],
    });
  };

  return (
    <div className="flex justify-center items-center space-x-4 mb-4">
      <Input
        type="text"
        placeholder="Enter URI"
        value={uri}
        onChange={(e) => setUri(e.target.value)}
      />
      <Button onClick={handleMint} disabled={isPending}>
        {isPending ? 'Minting...' : 'Mint Pet'}
      </Button>
      {isSuccess && <span>Success!</span>}
      {error && <span>Error: {error.message}</span>}
    </div>
  );
}

function DestroyPet() {
  const [tokenId, setTokenId] = useState('');
  const { mutate: writeContract, isPending, isSuccess, error } = useWriteContract();

  const handleDestroy = () => {
    if (!tokenId) return;
    writeContract({
      address: contractAddress.CustomPet,
      abi: contractABI.CustomPet,
      functionName: 'burn',
      args: [BigInt(tokenId)],
    });
  };

  return (
    <div className="flex justify-center items-center space-x-4 mb-4">
      <Input
        type="text"
        placeholder="Enter Token ID"
        value={tokenId}
        onChange={(e) => setTokenId(e.target.value)}
      />
      <Button onClick={handleDestroy} disabled={isPending}>
        {isPending ? 'Destroying...' : 'Destroy Pet'}
      </Button>
      {isSuccess && <span>Success!</span>}
      {error && <span>Error: {error.message}</span>}
    </div>
  );
}

function PetManage() {
  const { address, isConnected } = useConnection();

  if (!isConnected || address === undefined) {
    return <Label>您还未连接钱包. 请先连接您的钱包!</Label>
  }

  return (
    <div>
      <Label>Pet Manage Page</Label>
      <MintPet address={address} />
      <DestroyPet />
      <OwnedPetList address={address} />
    </div>
  );
}

export default PetManage;
