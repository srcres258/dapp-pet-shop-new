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
import { useState, useCallback } from 'react';
import { contractAddress, contractABI, PINATA_JWT } from '@/constants';
import { useDropzone } from 'react-dropzone';
import { PinataSDK } from 'pinata';

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
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);
  const { mutateAsync: writeContractAsync, isPending, isSuccess, error } = useWriteContract();

  const onDrop = useCallback((acceptedFiles: File[]) => {
    setImageFile(acceptedFiles[0]);
  }, []);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({ onDrop, accept: 'image/*' });

  const handleMint = async () => {
    if (!name || !description || !imageFile) return;

    setUploading(true);
    try {
      const pinata = new PinataSDK({
        pinataJwt: PINATA_JWT,
        pinataGateway: "gateway.pinata.cloud",
      });

      const imageUpload = await pinata.upload.public.file(
        imageFile,
        {
          metadata: {
            name: `nft-image-${imageFile.name}`
          }
        }
      );
      const imageUri = `https://gateway.pinata.cloud/ipfs/${imageUpload.IpfsHash}`;

      const metadata = {
        name,
        description,
        image: imageUri
      };
      const metadataUpload = await pinata.upload.public.json(
        metadata,
        {
          metadata: {
            name: 'nft-metadata.json'
          }
        }
      );
      const uri = `https://gateway.pinata.cloud/ipfs/${metadataUpload.IpfsHash}`;

      await writeContractAsync({
        address: contractAddress.CustomPet,
        abi: contractABI.CustomPet,
        functionName: 'mint',
        args: [address, uri],
      });
    } catch (err) {
      console.error(err);
    } finally {
      setUploading(false);
    }
  };

  return (
    <div className="space-y-4 mb-4">
      <div>
        <Label htmlFor="name">Name</Label>
        <Input
          id="name"
          type="text"
          placeholder="Enter pet name"
          value={name}
          onChange={(e) => setName(e.target.value)}
        />
      </div>
      <div>
        <Label htmlFor="description">Description</Label>
        <Input
          id="description"
          type="text"
          placeholder="Enter pet description"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
        />
      </div>
      <div>
        <Label>Image</Label>
        <div {...getRootProps()} className="border-2 border-dashed border-gray-300 p-4 text-center cursor-pointer hover:border-gray-400">
          <input {...getInputProps()} />
          {isDragActive ? (
            <p>Drop the image here...</p>
          ) : (
            <p>Drag 'n' drop an image here, or click to select</p>
          )}
          {imageFile && <p className="mt-2 text-sm text-gray-600">Selected: {imageFile.name}</p>}
        </div>
      </div>
      <Button onClick={handleMint} disabled={isPending || uploading || !name || !description || !imageFile}>
        {isPending || uploading ? 'Processing...' : 'Mint Pet'}
      </Button>
      {isSuccess && <span className="text-green-600">Success!</span>}
      {error && <span className="text-red-600">Error: {error.message}</span>}
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
