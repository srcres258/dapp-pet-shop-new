import { NavLink, Outlet } from 'react-router';
import { cn } from '@/lib/utils';

export default function MainLayout() {
  const classNameFunctor = ({ isActive }: { isActive: boolean }) =>
    cn(
      'text-sm font-medium transition-colors hover:text-primary',
      isActive ? 'text-primary' : 'text-muted-foreground'
    );

  return (
    <div className="border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 sticky top-0 z-50">
      {/* 顶部导航栏 */}
      <header className='border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 sticky top-0 z-50'>
        <div className='container flex h-14 items-center justify-between'>
          {/* DApp 名称 */}
          <div className='font-bold text-lg'>
            Pet Shop DApp
          </div>

          {/* 导航链接 */}
          <nav className='flex items-center gap-6'>
            <NavLink to='/' className={classNameFunctor}>
              Home (Wallet)
            </NavLink>
            <NavLink to='/viewer' className={classNameFunctor}>
              Viewer
            </NavLink>
            <NavLink to='/exchange' className={classNameFunctor}>
              Exchange
            </NavLink>
            <NavLink to='/trade' className={classNameFunctor}>
              Trade
            </NavLink>
            <NavLink to='/committee' className={classNameFunctor}>
              Committee
            </NavLink>
          </nav>
        </div>
      </header>

      {/* 页面内容区域 */}
      <main className='flex-1 container py-8'>
        <Outlet /> {/* 这里渲染子页面内容 */}
      </main>

      {/* 脚注 */}
      <footer className='border-t py-4 text-center text-sm text-muted-foreground'>
        &copy; 2026 Pet Shop DApp. All rights reserved.
      </footer>
    </div>
  );
}
