import CustomTokenABI from '@/abis/Committee.json';
import CustomPetABI from '@/abis/CustomPet.json';
import CommitteeABI from '@/abis/Committee.json';
import CommitteeTreasuryABI from '@/abis/CommitteeTreasury.json';
import ProposalABI from '@/abis/Proposal.json';
import ProposalFactoryABI from '@/abis/ProposalFactory.json';
import ExchangeABI from '@/abis/Exchange.json';
import TradeFactoryABI from '@/abis/TradeFactory.json';
import ViewerABI from '@/abis/Viewer.json';

export const contractAddress: Record<string, `0x${string}`> = {
  CustomToken: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
  CustomPet: "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0",
  Committee: "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9",
  CommitteeTreasury: "0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9",
  ProposalFactory: "0x0165878A594ca255338adfa4d48449f69242Eb8F",
  Exchange: "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853",
  TradeFactory: "0x8A791620dd6260079BF849Dc5567aDC3F2FdC318",
  Viewer: "0x610178dA211FEF7D417bC0e6FeD39F05609AD788"
};

export const contractABI: Record<string, object[]> = {
  CustomToken: CustomTokenABI,
  CustomPet: CustomPetABI,
  Committee: CommitteeABI,
  CommitteeTreasury: CommitteeTreasuryABI,
  Proposal: ProposalABI,
  ProposalFactory: ProposalFactoryABI,
  Exchange: ExchangeABI,
  TradeFactory: TradeFactoryABI,
  Viewer: ViewerABI
};
