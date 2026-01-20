import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
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
import { parseEther } from 'viem';

function Exchange() {
  const address = contractAddress.Exchange;
  const abi = contractABI.Exchange;

  const {
    mutate: writeContract,
    mutateAsync: writeContractAsync,
    isPending,
    isSuccess,
    data: hash,
    error,
    reset,
    status
  } = useWriteContract();

  const { data: kFactor }: { data?: bigint } = useReadContract({
    address,
    abi,
    functionName: 'k'
  });

  const [ctAmount, setCTAmount] = useState(1);

  const calcETHFromCT = (ctAmount: number, k: bigint | undefined = kFactor) => k ? (ctAmount * Number(k)) : 0;

  const handleExchangeETHToCT = () => {
    writeContract({
      address,
      abi,
      functionName: 'exchangeETHToCT',
      value: parseEther(`${calcETHFromCT(ctAmount)}`, 'wei')
    });
  };

  const handleExchangeCTToETH = () => {
    writeContract({
      address,
      abi,
      functionName: 'exchangeCTToETH',
      args: [BigInt(ctAmount)]
    });
  };

  return (
    <div>
      <p>CustomToken Exchange</p>

      <p>当前兑换率: {kFactor ? `1 CT = ${kFactor} ETH` : 'Loading...'}</p>

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
        {address ? (isPending ? '操作执行中...' : '请选择要执行的操作:') : '合约地址加载失败.'}
      </p>

      <p>
        <Button
          variant="outline"
          onClick={handleExchangeETHToCT}
          disabled={isPending || !address}
        >
          使用 {calcETHFromCT(ctAmount)} ETH 兑换 {ctAmount} CT
        </Button>

        <Button
          variant="outline"
          onClick={handleExchangeCTToETH}
          disabled={isPending || !address}
        >
          兑换 {ctAmount} CT 为 {calcETHFromCT(ctAmount)} ETH
        </Button>
      </p>
    </div>
  );
}

export default Exchange;
