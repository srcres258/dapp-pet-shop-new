import { Routes, Route } from 'react-router';
import MainLayout from '@/components/layout/MainLayout';

import './App.css';
import Index from './pages/index';
import Viewer from './pages/viewer';
import Exchange from './pages/exchange';
import Trade from './pages/trade';
import PetManage from './pages/pet-manage';

function App() {
  return (
    <Routes>
      <Route element={<MainLayout />}>
        <Route index element={<Index />} />
        <Route path="viewer" element={<Viewer />} />
        <Route path="exchange" element={<Exchange />} />
        <Route path="trade" element={<Trade />} />
        <Route path="pet-manage" element={<PetManage />} />
      </Route>
    </Routes>
  );
}

export default App
