---
name: web-crawler
description: "Web crawler design and implementation skill, based on Wikipedia's Web crawler article. Covers crawler policies, architectures, selection strategies, and best practices."
license: CC-BY-SA-3.0
metadata:
  author: Wikipedia contributors
  version: "1.0"
  category: web-scraping
  references:
    - "https://en.wikipedia.org/wiki/Web_crawler"
---

# Web Crawler Skill

Design and implement web crawlers following best practices from Wikipedia's comprehensive Web crawler article.

## When to Use

Use this skill when:

- Building a new web crawler or spider
- Designing crawler policies and strategies
- Implementing distributed or parallel crawlers
- Archiving websites (web archiving)
- Creating focused or topical crawlers

## Core Concepts

### Crawler Policies

A web crawler's behavior is determined by four key policies:

1. **Selection policy** - which pages to download
2. **Re-visit policy** - when to check for page changes
3. **Politeness policy** - how to avoid overloading websites
4. **Parallelization policy** - how to coordinate distributed crawlers

### Selection Strategy

Given the size of the Web, even large crawlers only cover a portion. Important considerations:

- **Page importance metrics**: quality, popularity, link count, URL features
- **Common ordering strategies**:
  - Breadth-first search
  - Backlink count
  - Partial PageRank
  - OPIC (On-line Page Importance Computation)
  - Focused crawling (topical similarity)

### URL Normalization

Crawlers normalize URLs to avoid multiple downloads of the same page:

- Convert to lowercase
- Remove "." and ".." segments
- Add trailing slashes to non-empty paths
- Remove query strings when appropriate

### Path-Ascending Crawling

For downloading/uploading many resources from a site:

- Ascends to every path in each URL
- Effective for finding isolated resources
- Example: given `http://llama.org/hamster/monkey/page.html`, crawls `/hamster/monkey/`, `/hamster/`, and `/`

### Focused Crawling

Crawlers that try to download only pages relevant to a given topic:

- Uses link text and complete page content for similarity prediction
- Relies on general web search engines for starting points
- Academic focused crawlers target free-access academic documents

### Re-Visit Policy

Checks for page changes based on:

- **Freshness**: binary measure of local copy accuracy
- **Age**: how outdated the local copy is
- **Common policies**:
  - Uniform: re-visit all pages with same frequency
  - Proportional: re-visit more frequently changing pages more often

### Politeness Policy

Crawlers can impact server performance. Best practices:

- **robots.txt**: standard for indicating which parts not to crawl
- **Crawl-delay**: some sites specify delay between requests (10-15 seconds typical)
- **Server overload avoidance**: avoid high request rates or large file downloads
- **Crawler identification**: use proper User-agent strings

### Parallelization Policy

Multiple processes running in parallel:

- Requires URL assignment policies to avoid duplicates
- Distributed crawlers coordinate across multiple machines
- MercatorWeb uses adaptive politeness: waits 10× download time

## Architectures

### High-Level Components

A crawler needs:

1. Good crawling strategy
2. Highly optimized architecture
3. Efficient I/O and network handling
4. Robust error handling
5. Manageability at scale

### Historical Crawlers

- **World Wide Web Worm**: early crawler for simple title/URL index
- **Mercator**: modular, extensible crawler
- **Googlebot**: Google's web crawler (architecture kept secret)

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

## List of Crawlers

### Open Source

- Apache Nutch (Java/Hadoop/Solr/Elasticsearch)
- Heritrix (Internet Archive, Java)
- HTTrack (website mirroring, C)
- Scrapy (Python framework)
- GNU Wget

### Commercial

- Diffbot (API-based general crawler)
- SortSite (website analysis)
- Swiftbot (Swiftype SaaS crawler)

### In-House

- Googlebot (Google)
- Bingbot (Microsoft/Bing)
- Baiduspider (Baidu)
- DuckDuckBot (DuckDuckGo)
- Applebot (Apple/Siri)

## See Also

- Web archiving
- Focused crawler
- Distributed web crawling
- Web scraping
- List of search engine software
- Robots exclusion standard
- URL normalization
- Spider trap
- Search engine indexing
- Link farm

## References

Based on Wikipedia's Web crawler article (CC BY-SA 3.0):
https://en.wikipedia.org/wiki/Web_crawler

Citation:

- Brin, S., & Page, L. (1998). The anatomy of a large-scale hypertextual Web search engine. Computer Networks, 30(1-7), 107-117.
- Cho, J., Garcia-Molina, H., & Page, L. (1998). Efficient crawling through URL ordering. Computer Networks, 30(1-7), 161-172.
- Cho, J., & Garcia-Molina, H. (2003). The evolution of the web and implications for an incremental crawler. Proceedings of the 29th International Conference on Very Large Data Bases (VLDB '03).
