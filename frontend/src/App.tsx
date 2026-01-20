import { Routes, Route } from 'react-router';
import MainLayout from '@/components/layout/MainLayout';

import './App.css';
import Index from './pages/index';
import Viewer from './pages/viewer';
import Exchange from './pages/exchange';
import Trade from './pages/trade';
import Committee from './pages/committee';

function App() {
  return (
    <Routes>
      <Route element={<MainLayout />}>
        <Route index element={<Index />} />
        <Route path="viewer" element={<Viewer />} />
        <Route path="exchange" element={<Exchange />} />
        <Route path="trade" element={<Trade />} />
        <Route path="committee" element={<Committee />} />
      </Route>
    </Routes>
  );
}

export default App
