import { useConnection } from 'wagmi';
import { useOwnedCPs, useUserAllTrades, useTradeDetails } from '@/hooks/Viewer';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Label } from '@/components/ui/label';

function OwnedCPList() {
  const { address } = useConnection();
  const { tokenIds, tokenURIs, isLoading, error } = useOwnedCPs(address);

  if (!address) return <div>Please connect your wallet</div>;
  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <div>
      <Label>Your Owned Custom Pets</Label>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Token ID</TableHead>
            <TableHead>Token URI</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {tokenIds.map((id, index) => (
            <TableRow key={id.toString()}>
              <TableCell>{id.toString()}</TableCell>
              <TableCell>{tokenURIs[index]}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}

function TradeList() {
  const { address } = useConnection();
  const { trades, isLoading, error } = useUserAllTrades(address);

  if (!address) return <div>Please connect your wallet</div>;
  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <div>
      <Label>Your Trades</Label>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Trade Address</TableHead>
            <TableHead>Role</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {trades.map((tradeAddr) => (
            <TradeRow key={tradeAddr} tradeAddress={tradeAddr} userAddress={address} />
          ))}
        </TableBody>
      </Table>
    </div>
  );
}

function TradeRow({ tradeAddress, userAddress }: { tradeAddress: `0x${string}`, userAddress: `0x${string}` }) {
  const { role, isLoading } = useTradeDetails(tradeAddress, userAddress);

  return (
    <TableRow>
      <TableCell>{tradeAddress}</TableCell>
      <TableCell>{isLoading ? 'Loading...' : role || 'Unknown'}</TableCell>
    </TableRow>
  );
}

function Viewer() {
  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Viewer Page</h1>
      <div className="mb-8">
        <OwnedCPList />
      </div>
      <div>
        <TradeList />
      </div>
    </div>
  );
}

export default Viewer;
