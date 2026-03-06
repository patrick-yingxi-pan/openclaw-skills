# Web Crawler Security Considerations

## Security Considerations

- **Unintended consequences**: can lead to compromise or data breach if indexing private resources
- **Prevention**: use robots.txt, block transactional/login pages, use Google hacking techniques defensively

## Crawler Identification

Web servers identify crawlers via:
- **User-agent** HTTP header
- Server log analysis
- Tools for identification, tracking, and verification
- Malicious crawlers may mask identity as browsers

## Crawling the Deep Web

Pages not accessible via standard links:
- **Database-driven content**: requires form submissions
- **AJAX pages**: content loaded dynamically
- **Sitemaps protocol**: helps discovery
- **Mod OAI**: for academic resources
- **Visual scrapers**: for AJAX-heavy sites
