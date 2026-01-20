import {
  Table,
  TableBody,
  TableCaption,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { Label } from '@radix-ui/react-label';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  useWalletClient,
  useReadContract,
  useWriteContract,
  useConnection,
  useWaitForTransactionReceipt
} from 'wagmi';
import {
  contractAddress,
  contractABI
} from '@/constants';
import {
  useState,
  useEffect
} from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { getContract } from 'viem';

type Proposal = {
  address: `0x${string}`,
  active: boolean
};
type ProposalInfo = [
  `0x${string}`, // _initiator
  bigint,        // _startTime
  bigint,        // _endTime
  string,        // _proposalType
  bigint,        // _yesWeight
  bigint,        // _noWeight
  boolean        // _executed
]

export function ProposalList() {
  const { data: walletClient } = useWalletClient();

  const { address, isConnected } = useConnection();

  const apResult = useReadContract({
    address: contractAddress.ProposalFactory,
    abi: contractABI.ProposalFactory,
    functionName: 'getActiveProposals',
    query: {
      refetchInterval: 2000,
      refetchIntervalInBackground: true
    }
  });
  const hpResult = useReadContract({
    address: contractAddress.ProposalFactory,
    abi: contractABI.ProposalFactory,
    functionName: 'getHistoricalProposals',
    query: {
      refetchInterval: 2000,
      refetchIntervalInBackground: true
    }
  });

  const { data: isMember } = useReadContract({
    address: contractAddress.Committee,
    abi: contractABI.Committee,
    functionName: 'isMember',
    args: [address!],
    query: { enabled: isConnected && !!address }
  });

  const {
    mutate: writeContract,
    isPending,
    isSuccess,
  isError,
  error,
  status,               // 'idle' | 'pending' | 'success' | 'error'
  reset,
  data:hash
  } = useWriteContract();

  const vote = (proposalAddress: `0x${string}`, yes: boolean) => {
    writeContract({
      address: proposalAddress,
      abi: contractABI.Proposal,
      functionName: 'vote',
      args: [yes]
    });
    console.log(`Voting on proposal ${proposalAddress} with ${yes}`);
  };

  const endProposal = (proposalAddress: `0x${string}`) => {
    writeContract({
      address: proposalAddress,
      abi: contractABI.Proposal,
      functionName: 'endProposal'
    });
    console.log(`Ending proposal ${proposalAddress}`);
  };

  const combineProposals = () => {
    const activeProposals = apResult.data as `0x${string}`[] | undefined;
    const historicalProposals = hpResult.data as `0x${string}`[] | undefined;
    const combinedProposals: Proposal[] = [];
    if (activeProposals) {
      activeProposals.forEach((address) => {
        combinedProposals.push({ address, active: true });
      });
    }
    if (historicalProposals) {
      historicalProposals.forEach((address) => {
        combinedProposals.push({ address, active: false });
      });
    }
    return combinedProposals;
  };
  const proposals = combineProposals();

console.log({
  hash,                 // 如果一直是 undefined → 问题核心
  isPending,
  isSuccess,
  isError,
  error,                // 这里往往有线索
  status
})

  return (
    <div>
      {apResult === undefined ? (<p><Label>正在加载活跃提案...</Label></p>) : null}
      {hpResult === undefined ? (<p><Label>正在加载历史提案...</Label></p>) : null}
      <Table>
        <TableCaption>提案列表 (共{proposals.length}个)</TableCaption>
        <TableHeader>
          <TableRow>
            <TableHead>序号</TableHead>
            <TableHead>提案地址</TableHead>
            <TableHead>状态</TableHead>
            <TableHead>操作</TableHead>
            <TableHead>结束投票</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {proposals.map((proposal, index) => {
            return (
              <TableRow key={proposal.address}>
                <TableCell>{index + 1}</TableCell>
                <TableCell>{proposal.address}</TableCell>
                <TableCell>{proposal.active ? '进行中' : '已结束'}</TableCell>
                <TableCell>
                  {proposal.active && isMember ? (
                    <div>
                      <Button
                        onClick={() => vote(proposal.address, true)}
                        disabled={isPending}
                      >赞成</Button>
                      <Button
                        onClick={() => vote(proposal.address, false)}
                        disabled={isPending}
                      >反对</Button>
                    </div>
                  ) : proposal.active ? (
                    <div>
                      <Button disabled>赞成</Button>
                      <Button disabled>反对</Button>
                      <p>您不是委员会成员，无法投票</p>
                    </div>
                  ) : (
                    <span>提案已结束</span>
                  )}
                </TableCell>
                <TableCell>
                  <Button
                    onClick={() => endProposal(proposal.address)}
                    disabled={isPending}
                  >结束投票</Button>
                </TableCell>
              </TableRow>
            );
          })}
        </TableBody>
      </Table>
    </div>
  );
}

export function AdjustKProposal() {
  const [newK, setNewK] = useState('');

  const { mutate: writeContract } = useWriteContract();

  const handleSubmit = () => {
    if (!newK) return;
    writeContract({
      address: contractAddress.ProposalFactory,
      abi: contractABI.ProposalFactory,
      functionName: 'createAdjustKProposal',
      args: [BigInt(newK)],
    });
  };

  return (
    <div>
      <Label>调整 k 值</Label>
      <Input value={newK} onChange={(e) => setNewK(e.target.value)} placeholder="新 k 值" />
      <Button onClick={handleSubmit}>创建提案</Button>
    </div>
  );
}

export function MintCPProposal() {
  const [to, setTo] = useState('');
  const [tokenURI, setTokenURI] = useState('');

  const { mutate: writeContract } = useWriteContract();

  const handleSubmit = () => {
    if (!to || !tokenURI) return;
    writeContract({
      address: contractAddress.ProposalFactory,
      abi: contractABI.ProposalFactory,
      functionName: 'createMintCPProposal',
      args: [to as `0x${string}`, tokenURI],
    });
  };

  return (
    <div>
      <Label>铸造 CP</Label>
      <Input value={to} onChange={(e) => setTo(e.target.value)} placeholder="接收地址" />
      <Input value={tokenURI} onChange={(e) => setTokenURI(e.target.value)} placeholder="Token URI" />
      <Button onClick={handleSubmit}>创建提案</Button>
    </div>
  );
}

export function BurnCPProposal() {
  const [tokenId, setTokenId] = useState('');

  const { mutate: writeContract } = useWriteContract();

  const handleSubmit = () => {
    if (!tokenId) return;
    writeContract({
      address: contractAddress.ProposalFactory,
      abi: contractABI.ProposalFactory,
      functionName: 'createBurnCPProposal',
      args: [BigInt(tokenId)],
    });
  };

  return (
    <div>
      <Label>销毁 CP</Label>
      <Input value={tokenId} onChange={(e) => setTokenId(e.target.value)} placeholder="Token ID" />
      <Button onClick={handleSubmit}>创建提案</Button>
    </div>
  );
}

export function ChangeVotingTimeProposal() {
  const [newTime, setNewTime] = useState('');

  const { mutate: writeContract } = useWriteContract();

  const handleSubmit = () => {
    if (!newTime) return;
    writeContract({
      address: contractAddress.ProposalFactory,
      abi: contractABI.ProposalFactory,
      functionName: 'createChangeVotingTimeProposal',
      args: [BigInt(newTime)],
    });
  };

  return (
    <div>
      <Label>修改投票时间</Label>
      <Input value={newTime} onChange={(e) => setNewTime(e.target.value)} placeholder="新投票时间 (秒)" />
      <Button onClick={handleSubmit}>创建提案</Button>
    </div>
  );
}

export function ToggleStoreProposal() {
  const { mutate: writeContract } = useWriteContract();

  const handleSubmit = () => {
    writeContract({
      address: contractAddress.ProposalFactory,
      abi: contractABI.ProposalFactory,
      functionName: 'createToggleStoreProposal',
    });
  };

  return (
    <div>
      <Label>切换商店开关</Label>
      <Button onClick={handleSubmit}>创建提案</Button>
    </div>
  );
}

export function ToggleStoreBuyingProposal() {
  const { mutate: writeContract } = useWriteContract();

  const handleSubmit = () => {
    writeContract({
      address: contractAddress.ProposalFactory,
      abi: contractABI.ProposalFactory,
      functionName: 'createToggleStoreBuyingProposal',
    });
  };

  return (
    <div>
      <Label>切换商店购买功能开关</Label>
      <Button onClick={handleSubmit}>创建提案</Button>
    </div>
  );
}

export function ToggleStoreSellingProposal() {
  const { mutate: writeContract } = useWriteContract();

  const handleSubmit = () => {
    writeContract({
      address: contractAddress.ProposalFactory,
      abi: contractABI.ProposalFactory,
      functionName: 'createToggleStoreSellingProposal',
    });
  };

  return (
    <div>
      <Label>切换商店出售功能开关</Label>
      <Button onClick={handleSubmit}>创建提案</Button>
    </div>
  );
}

export function ListCPProposal() {
  const [tokenId, setTokenId] = useState('');
  const [price, setPrice] = useState('');

  const { mutate: writeContract } = useWriteContract();

  const handleSubmit = () => {
    if (!tokenId || !price) return;
    writeContract({
      address: contractAddress.ProposalFactory,
      abi: contractABI.ProposalFactory,
      functionName: 'createListCPProposal',
      args: [BigInt(tokenId), BigInt(price)],
    });
  };

  return (
    <div>
      <Label>上架 CP</Label>
      <Input value={tokenId} onChange={(e) => setTokenId(e.target.value)} placeholder="Token ID" />
      <Input value={price} onChange={(e) => setPrice(e.target.value)} placeholder="价格" />
      <Button onClick={handleSubmit}>创建提案</Button>
    </div>
  );
}

export function ExtractProposal() {
  const [to, setTo] = useState('');
  const [assetType, setAssetType] = useState('');
  const [amountOrId, setAmountOrId] = useState('');

  const { mutate: writeContract } = useWriteContract();

  const handleSubmit = () => {
    if (!to || !assetType || !amountOrId) return;
    writeContract({
      address: contractAddress.ProposalFactory,
      abi: contractABI.ProposalFactory,
      functionName: 'createExtractProposal',
      args: [to as `0x${string}`, assetType, BigInt(amountOrId)],
    });
  };

  return (
    <div>
      <Label>提取资产</Label>
      <Input value={to} onChange={(e) => setTo(e.target.value)} placeholder="接收地址" />
      <Input value={assetType} onChange={(e) => setAssetType(e.target.value)} placeholder="资产类型" />
      <Input value={amountOrId} onChange={(e) => setAmountOrId(e.target.value)} placeholder="数量或 ID" />
      <Button onClick={handleSubmit}>创建提案</Button>
    </div>
  );
}
