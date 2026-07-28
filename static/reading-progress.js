(() => {
    const content = document.querySelector("[data-reading-content]");
    const progressBar = document.querySelector(".reading-progress");

    if (!content || !progressBar) {
        return;
    }

    let updateRequested = false;

    const updateProgress = () => {
        const contentTop = content.getBoundingClientRect().top + window.scrollY;
        const contentBottom = contentTop + content.offsetHeight;
        const endPosition = Math.max(contentTop, contentBottom - window.innerHeight);
        const scrollRange = endPosition - contentTop;
        const progress = scrollRange === 0
            ? Number(window.scrollY >= contentTop)
            : (window.scrollY - contentTop) / scrollRange;
        const percentage = Math.min(1, Math.max(0, progress));

        progressBar.style.transform = `scaleX(${percentage})`;
        progressBar.setAttribute("aria-valuenow", String(Math.round(percentage * 100)));
        updateRequested = false;
    };

    const requestUpdate = () => {
        if (updateRequested) {
            return;
        }

        updateRequested = true;
        window.requestAnimationFrame(updateProgress);
    };

    window.addEventListener("scroll", requestUpdate, { passive: true });
    window.addEventListener("resize", requestUpdate);
    requestUpdate();
})();
