---
name: web-crawler
description: "Web crawler design and implementation skill, based on Wikipedia's Web crawler article. Covers crawler policies, architectures, selection strategies, and best practices."
license: CC-BY-SA-3.0
metadata:
  author: Wikipedia contributors
  version: "2.0"
  category: web-scraping
  references:
    - "https://en.wikipedia.org/wiki/Web_crawler"
    - "references/design-patterns.md"
    - "references/architectures.md"
    - "references/security.md"
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

See [references/design-patterns.md](references/design-patterns.md) for detailed strategies and implementation patterns.

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

For detailed design patterns, see [references/design-patterns.md](references/design-patterns.md).
For architecture information, see [references/architectures.md](references/architectures.md).
For security considerations, see [references/security.md](references/security.md).
