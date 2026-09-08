            <footer style="margin-top: 40px; padding-top: 20px; border-top: 1px solid var(--cm-border); display: flex; justify-content: space-between; align-items: center; font-size: 13px; color: var(--cm-text-muted); flex-wrap: wrap; gap: 10px;">
                <div>
                    <?= cookmate_brand_html() ?> &bull; Culinary Admin Suite
                </div>
                <div>
                    Connected to MySQL: <code style="color: var(--cm-primary);">Food CHART DB</code>
                    <span style="font-size: 11px; opacity: 0.8;">(Active Database)</span>
                </div>
            </footer>
        </main>
    </div>

    <!-- Scripts -->
    <script>
        // Responsive sidebar toggle
        const toggleBtn = document.getElementById('sidebarToggle');
        const sidebar = document.getElementById('adminSidebar');
        if (toggleBtn && sidebar) {
            // Only show toggle button on smaller screens
            function checkWidth() {
                if (window.innerWidth <= 900) {
                    toggleBtn.style.display = 'inline-flex';
                } else {
                    toggleBtn.style.display = 'none';
                    sidebar.classList.remove('open');
                }
            }
            window.addEventListener('resize', checkWidth);
            checkWidth();

            toggleBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                sidebar.classList.toggle('open');
            });

            document.addEventListener('click', (e) => {
                if (window.innerWidth <= 900 && !sidebar.contains(e.target) && !toggleBtn.contains(e.target)) {
                    sidebar.classList.remove('open');
                }
            });
        }
    </script>
</body>
</html>
