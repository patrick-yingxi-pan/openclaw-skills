# Web Crawler Design Patterns

## Crawler Policies

A web crawler's behavior is determined by four key policies:

1. **Selection policy** - which pages to download
2. **Re-visit policy** - when to check for page changes
3. **Politeness policy** - how to avoid overloading websites
4. **Parallelization policy** - how to coordinate distributed crawlers

## Selection Strategies

Given the size of the Web, even large crawlers only cover a portion. Important considerations:

- **Page importance metrics**: quality, popularity, link count, URL features
- **Common ordering strategies**:
  - Breadth-first search
  - Backlink count
  - Partial PageRank
  - OPIC (On-line Page Importance Computation)
  - Focused crawling (topical similarity)

## URL Normalization

Crawlers normalize URLs to avoid multiple downloads of the same page:
- Convert to lowercase
- Remove "." and ".." segments
- Add trailing slashes to non-empty paths
- Remove query strings when appropriate

## Path-Ascending Crawling

For downloading/uploading many resources from a site:
- Ascends to every path in each URL
- Effective for finding isolated resources
- Example: given `http://llama.org/hamster/monkey/page.html`, crawls `/hamster/monkey/`, `/hamster/`, and `/`

## Focused Crawling

Crawlers that try to download only pages relevant to a given topic:
- Uses link text and complete page content for similarity prediction
- Relies on general web search engines for starting points
- Academic focused crawlers target free-access academic documents

## Re-Visit Policy

Checks for page changes based on:
- **Freshness**: binary measure of local copy accuracy
- **Age**: how outdated the local copy is
- **Common policies**:
  - Uniform: re-visit all pages with same frequency
  - Proportional: re-visit more frequently changing pages more often

## Politeness Policy

Crawlers can impact server performance. Best practices:
- **robots.txt**: standard for indicating which parts not to crawl
- **Crawl-delay**: some sites specify delay between requests (10-15 seconds typical)
- **Server overload avoidance**: avoid high request rates or large file downloads
- **Crawler identification**: use proper User-agent strings

## Parallelization Policy

Multiple processes running in parallel:
- Requires URL assignment policies to avoid duplicates
- Distributed crawlers coordinate across multiple machines
- MercatorWeb uses adaptive politeness: waits 10× download time
