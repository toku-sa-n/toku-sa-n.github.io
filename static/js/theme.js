(() => {
  const root = document.documentElement;
  const toggle = document.getElementById('theme-toggle');
  const storageKey = 'theme';

  if (!toggle) return;

  const setTheme = (theme) => {
    root.setAttribute('data-theme', theme);
    localStorage.setItem(storageKey, theme);
    toggle.setAttribute('aria-pressed', theme === 'dark');
  };

  const current = root.getAttribute('data-theme') || 'dark';
  setTheme(current);

  toggle.addEventListener('click', () => {
    const next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
    setTheme(next);
  });
})();
