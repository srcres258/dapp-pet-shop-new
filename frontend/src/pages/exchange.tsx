import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  useConnection,
  useBalance,
  useReadContract,
  useWriteContract
} from 'wagmi';
import {
  contractAddress,
  contractABI
} from '@/constants';
import {
  useState
} from 'react';
import {
  formatEther,
  formatUnits
} from 'viem';
import { ephemeryChain } from '@/lib/chains';

function Exchange() {
  const { address, isConnected } = useConnection();

  const {
    mutate: writeContract,
    isPending,
  } = useWriteContract();

  const { data: ethBalance } = useBalance({
    address: address,
    chainId: ephemeryChain.id
  });
  const { data: ctBalance }: { data: bigint | undefined } = useReadContract({
    address: contractAddress.CustomToken,
    abi: contractABI.CustomToken,
    functionName: 'balanceOf',
    args: [address!],
    query: { enabled: isConnected && !!address }
  });

  const { data: kFactor }: { data: bigint | undefined } = useReadContract({
    address: contractAddress.Exchange,
    abi: contractABI.Exchange,
    functionName: 'k'
  });

  const [ctAmount, setCTAmount] = useState(1);

  const calcWeiFromCT = (ctAmount: number, k: bigint | undefined = kFactor) => k ? (BigInt(ctAmount) * k) : 0n;

  const handleExchangeETHToCT = () => {
    writeContract({
      address: contractAddress.Exchange,
      abi: contractABI.Exchange,
      functionName: 'exchangeETHToCT',
      value: BigInt(calcWeiFromCT(ctAmount))
    });
  };

  const handleExchangeCTToETH = () => {
    writeContract({
      address: contractAddress.Exchange,
      abi: contractABI.Exchange,
      functionName: 'exchangeCTToETH',
      args: [BigInt(ctAmount) * (10n ** 18n)]
    });
  };

  return (
    <div>
      <p>CustomToken Exchange</p>

      <p>您的 ETH 余额: {ethBalance !== undefined ? formatUnits(ethBalance.value, ethBalance.decimals) : 'Loading...'}</p>
      <p>您的 CT 余额: {ctBalance !== undefined ? formatEther(ctBalance) : 'Loading...'}</p>
      <p>当前兑换率: {kFactor ? `1 CT = ${formatEther(kFactor)} ETH` : 'Loading...'}</p>

      <p>
        要进行操作的 CT 数量:
        <Input
          type="number"
          value={ctAmount}
          onChange={e => setCTAmount(Number(e.target.value))}
          min={1}
        />
      </p>

      <p>
        {address ? (isPending ? '操作执行中...' : '请选择要执行的操作:') : '您还未连接钱包, 请先连接钱包!'}
      </p>

      <p>
        <Button
          variant="outline"
          onClick={handleExchangeETHToCT}
          disabled={!kFactor || isPending || !address}
        >
          使用 {formatEther(calcWeiFromCT(ctAmount))} ETH 兑换 {ctAmount} CT
        </Button>

        <Button
          variant="outline"
          onClick={handleExchangeCTToETH}
          disabled={!kFactor || isPending || !address}
        >
          兑换 {ctAmount} CT 为 {formatEther(calcWeiFromCT(ctAmount))} ETH
        </Button>
      </p>
    </div>
  );
}

export default Exchange;
