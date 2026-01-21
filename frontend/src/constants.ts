import CustomPetABI from '@/abis/CustomPet.json';
import ExchangeABI from '@/abis/Exchange.json';
import TradeABI from '@/abis/Trade.json';
import TradeFactoryABI from '@/abis/TradeFactory.json';
import ViewerABI from '@/abis/Viewer.json';

export const contractAddress: Record<string, `0x${string}`> = {
  CustomToken: "0xCE8B56d40398B100bb90e37D9a52462Ac85a894A",
  CustomPet: "0x5F17Bf19Af3A1694Ca2D8848aA452D2f10489E66",
  Exchange: "0x6b80e91eF09670820c8E02015Eb17b14184Aaa9a",
  TradeFactory: "0xc707F78e3ece5403e208936763Bf12E019567213",
  Viewer: "0x20913671d029611461568d24ca2e4B3F660519F6"
};

export const contractABI: Record<string, object[]> = {
  CustomPet: CustomPetABI,
  Exchange: ExchangeABI,
  Trade: TradeABI,
  TradeFactory: TradeFactoryABI,
  Viewer: ViewerABI
};

export const PINATA_JWT = import.meta.env.VITE_PINATA_JWT as string;
