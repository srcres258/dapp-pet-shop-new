import CustomPetABI from '@/abis/CustomPet.json';
import ExchangeABI from '@/abis/Exchange.json';
import TradeABI from '@/abis/Trade.json';
import TradeFactoryABI from '@/abis/TradeFactory.json';
import ViewerABI from '@/abis/Viewer.json';

export const contractAddress: Record<string, `0x${string}`> = {
  CustomToken: "0x6649E782bB5EcBF1C9F979E789c82Eb94Cdf02a4",
  CustomPet: "0x4fB609EE829751bA212F11E2B60b99Ad0FF1b772",
  Exchange: "0x10045DE72c17a0799dF471EF4229160eA5C35C12",
  TradeFactory: "0x3Be14C82F9951b2B6221B7A30e50F031CB0CA8d2",
  Viewer: "0x12aA9244081eAC654C6C0Af4C2795a3810e32627"
};

export const contractABI: Record<string, object[]> = {
  CustomPet: CustomPetABI,
  Exchange: ExchangeABI,
  Trade: TradeABI,
  TradeFactory: TradeFactoryABI,
  Viewer: ViewerABI
};
