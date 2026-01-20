import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Checkbox } from '@/components/ui/checkbox';
import { Label } from '@/components/ui/label';
import {
  useWriteContract
} from 'wagmi';
import {
  useState
} from 'react';
import {
  contractAddress,
  contractABI
} from '@/constants';

export function JoinCommittee() {
  const {
    mutate: writeContract,
    isPending,
  } = useWriteContract();

  const [ethAmount, setEthAmount] = useState(1.0);

  const handleJoinCommittee = () => {
    writeContract({
      address: contractAddress.Committee,
      abi: contractABI.Committee,
      functionName: 'join',
      value: BigInt(Math.floor(ethAmount * 1e18))
    });
  };

  return (
    <div>
      <Input
        type='number'
        value={ethAmount}
        onChange={(e) => setEthAmount(parseFloat(e.target.value))}
        step={0.1}
        min={0.1}
      />
      <Button onClick={handleJoinCommittee} disabled={isPending}>
        加入委员会 (质押 {ethAmount} ETH)
      </Button>
    </div>
  );
}

export function ChangeStake() {
  const {
    mutate: writeContract,
    isPending,
  } = useWriteContract();

  const [ethAmount, setEthAmount] = useState(1.0);
  const [removeStakeAction, setRemoveStakeAction] = useState(false);

  const handleAddStake = () => {
    if (removeStakeAction === true) {
      writeContract({
        address: contractAddress.Committee,
        abi: contractABI.Committee,
        functionName: 'removeStake',
        args: [BigInt(Math.floor(ethAmount * 1e18))]
      });
    } else {
      writeContract({
        address: contractAddress.Committee,
        abi: contractABI.Committee,
        functionName: 'addStake',
        value: BigInt(Math.floor(ethAmount * 1e18))
      });
    }
  };

  return (
    <div>
      <Input
        type='number'
        value={ethAmount}
        onChange={(e) => setEthAmount(parseFloat(e.target.value))}
        step={0.1}
        min={0.1}
      />
      <div className="flex items-center gap-3">
        <Checkbox
          checked={removeStakeAction}
          onCheckedChange={(checked) => setRemoveStakeAction(checked === true)}
        />
        <Label>移除质押</Label>
      </div>
      <Button onClick={handleAddStake} disabled={isPending}>
        {removeStakeAction ? '移除' : '增加'} 质押 ({ethAmount} ETH)
      </Button>
    </div>
  );
}

export function RemoveStake() {
  return (
    <div></div>
  );
}
