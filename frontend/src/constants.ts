import CustomTokenABI from '@/abis/Committee.json';
import CustomPetABI from '@/abis/CustomPet.json';
import CommitteeABI from '@/abis/Committee.json';
import CommitteeTreasuryABI from '@/abis/CommitteeTreasury.json';
import ProposalFactoryABI from '@/abis/ProposalFactory.json';
import ExchangeABI from '@/abis/Exchange.json';
import TradeFactoryABI from '@/abis/TradeFactory.json';
import ViewerABI from '@/abis/Viewer.json';

export const contractAddress: Record<string, `0x${string}`> = {
  CustomToken: "0xBCb212bf7f7b662c998dE9B7503A01Ea3c0b5b88",
  CustomPet: "0x53840A7756C93f17FF8B2DdE4Cf0e574cFf233C0",
  Committee: "0xB7a9ce7B9af4849dd54B0357ecB839f561FaB899",
  CommitteeTreasury: "0x823b17e82FCCb5c73fb0080a0d02df7f8280dE8F",
  ProposalFactory: "0x312117276f333DAc0FF60dbAeb8A3B1ED0fc3eF8",
  Exchange: "0xDb1e31FdAbe1c9387310fa28BEFd3988477B583d",
  TradeFactory: "0x849E01112f25Cc5ce48ECf97586847Ea5CEa01D6",
  Viewer: "0x63F0ae56E692655218e012bBdf649B65F81528f2"
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
