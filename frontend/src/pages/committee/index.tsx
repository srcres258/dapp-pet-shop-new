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
import {
  useConnection,
  useReadContract,
} from 'wagmi';
import {
  contractAddress,
  contractABI
} from '@/constants';
import { formatEther } from 'viem';

import {
  JoinCommittee,
  ChangeStake
} from './stake';
import {
  ProposalList,
  AdjustKProposal,
  MintCPProposal,
  BurnCPProposal,
  ChangeVotingTimeProposal,
  ToggleStoreProposal,
  ToggleStoreBuyingProposal,
  ToggleStoreSellingProposal,
  ListCPProposal,
  ExtractProposal
} from './proposal';

type Stake = { member: `0x${string}`, amount: bigint }[];

function CommitteeMemberList() {
  const { data: members }: { data: Stake | undefined } = useReadContract({
    address: contractAddress.Committee,
    abi: contractABI.Committee,
    functionName: 'getMembers'
  });

  if (members === undefined) {
    return <div>加载中...</div>;
  }

  return (
    <Table>
      <TableCaption>当前委员会成员 (共{members.length}人)</TableCaption>
      <TableHeader>
        <TableRow>
          <TableHead>序号</TableHead>
          <TableHead>成员地址</TableHead>
          <TableHead>质押量 (ETH)</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {members.map((member, index) => (
          <TableRow key={member.member}>
            <TableCell>{index + 1}</TableCell>
            <TableCell>{member.member}</TableCell>
            <TableCell>{formatEther(member.amount)}</TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}

function CommitteeMemberPanel() {
  const { address, isConnected } = useConnection();

  const { data: isMember } = useReadContract({
    address: contractAddress.Committee,
    abi: contractABI.Committee,
    functionName: 'isMember',
    args: [address!],
    query: { enabled: isConnected && !!address }
  });

  if (!isConnected) {
    return <Label>请先连接钱包, 以判断您是否为委员会成员.</Label>;
  }

  if (isMember === undefined) {
    return <Label>正在查询您是否为委员会成员...</Label>;
  }
  if (!isMember) {
    return (
      <div>
        <p>您不是委员会成员. 您可质押一定数量的 ETH 以加入委员会.</p>
        <JoinCommittee />
      </div>
    );
  }

  return (
    <div>
      <p>您是委员会成员! 您可通过此面板行使您的权利.</p>

      <ChangeStake />

      <AdjustKProposal />
      <MintCPProposal />
      <BurnCPProposal />
      <ChangeVotingTimeProposal />
      <ToggleStoreProposal />
      <ToggleStoreBuyingProposal />
      <ToggleStoreSellingProposal />
      <ListCPProposal />
      <ExtractProposal />
    </div>
  );
}

function Committee() {
  return (
    <div>
      <p>Committee Page</p>
      <ProposalList />
      <CommitteeMemberList />
      <CommitteeMemberPanel />
    </div>
  );
}

export default Committee;
