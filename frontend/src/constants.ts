import CustomPetABI from '@/abis/CustomPet.json';
import ExchangeABI from '@/abis/Exchange.json';
import TradeFactoryABI from '@/abis/TradeFactory.json';
import ViewerABI from '@/abis/Viewer.json';

export const contractAddress: Record<string, `0x${string}`> = {
  CustomToken: "0x0F0EfF908955018910Cd061cfFea6181D6B1Bca3",
  CustomPet: "0xb5a1b5C746895d00Da47920fDb0bC86782A17f64",
  Exchange: "0x5218EeF7a655a384b7dB1582c0741F52f88B3023",
  TradeFactory: "0x34ceEd95148c77ecc13101174c5ED29A47bDa35C",
  Viewer: "0x225C1F421B4Bc96788484355f3FbEccaF553A858"
};

export const contractABI: Record<string, object[]> = {
  CustomPet: CustomPetABI,
  Exchange: ExchangeABI,
  TradeFactory: TradeFactoryABI,
  Viewer: ViewerABI
};
