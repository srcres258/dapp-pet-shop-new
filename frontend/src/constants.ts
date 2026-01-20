import CustomTokenABI from '@/abis/Committee.json';
import CustomPetABI from '@/abis/CustomPet.json';
import CommitteeABI from '@/abis/Committee.json';
import CommitteeTreasuryABI from '@/abis/CommitteeTreasury.json';
import ProposalFactoryABI from '@/abis/ProposalFactory.json';
import ExchangeABI from '@/abis/Exchange.json';
import TradeFactoryABI from '@/abis/TradeFactory.json';
import ViewerABI from '@/abis/Viewer.json';

export const contractAddress: Record<string, `0x${string}`> = {
  CustomToken: "0xf33a022751c88BFe69C12632FD2eDc42091DBbe7",
  CustomPet: "0xcC89f3ADfE694b5Fe7c6e90D870A5Fa3ed4266d2",
  Committee: "0xFfaAAa32689461Fdd7c071F69e18839DF31413dE",
  CommitteeTreasury: "0x8Ec2DD586c751d0aAFA22b9e1d908222A29Da5a2",
  ProposalFactory: "0x067D054676B8b2097307f85d640C076542364A9c",
  Exchange: "0x6E208Cf2A305599382CfDE002abDE39A739b6d10",
  TradeFactory: "0x3c7475661A26Cf110B2F53642D93629D5F577Bb4",
  Viewer: "0x08Caf8E8334Ffcddf768FBf32D917F929458e18B"
};

export const contractABI: Record<string, object[]> = {
  CustomToken: CustomTokenABI,
  CustomPet: CustomPetABI,
  Committee: CommitteeABI,
  CommitteeTreasury: CommitteeTreasuryABI,
  ProposalFactory: ProposalFactoryABI,
  Exchange: ExchangeABI,
  TradeFactory: TradeFactoryABI,
  Viewer: ViewerABI
};
