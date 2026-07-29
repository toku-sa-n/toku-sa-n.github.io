(() => {
  const root = document.documentElement;
  const toggle = document.getElementById('theme-toggle');
  const storageKey = 'theme';

  if (!toggle) return;

  const applyTheme = (theme) => {
    root.setAttribute('data-theme', theme);
    toggle.setAttribute('aria-pressed', theme === 'dark');
  };

  const current = root.getAttribute('data-theme') || 'dark';
  applyTheme(current);

  toggle.addEventListener('click', () => {
    const next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
    applyTheme(next);
    try {
      localStorage.setItem(storageKey, next);
    } catch {
      // 保存できない場合も現在のページではテーマ切替を反映する
    }
  });
})();
