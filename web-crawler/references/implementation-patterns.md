# Web Crawler Implementation Patterns

## Core Database Schema

### Pages Table
Stores metadata about crawled pages:

| Field | Type | Description |
|-------|------|-------------|
| id | INTEGER | Primary key |
| url | TEXT | Unique page URL |
| domain | TEXT | Extracted domain name |
| path_hash | TEXT | MD5 hash of URL for indexing |
| content_hash | TEXT | SHA-256 hash of page content |
| last_crawled | INTEGER | Timestamp of last crawl |
| last_modified | INTEGER | Page modification timestamp |
| status | TEXT | Crawl status (pending/active/completed/error) |
| depth | INTEGER | Crawl depth from seed URL |
| referrer | TEXT | Referring URL |
| created_at | INTEGER | Record creation timestamp |

### Versions Table
Tracks historical versions of pages:

| Field | Type | Description |
|-------|------|-------------|
| id | INTEGER | Primary key |
| page_id | INTEGER | Foreign key to pages table |
| version_number | INTEGER | Sequential version number |
| content_hash | TEXT | SHA-256 hash of this version |
| crawled_at | INTEGER | Timestamp when this version was captured |
| title | TEXT | Page title at crawl time |
| description | TEXT | Page meta description |
| file_path | TEXT | Path to stored content file |
| size_bytes | INTEGER | Size of content in bytes |
| change_type | TEXT | Type of change (new/updated/deleted) |

### Queue Table
Manages crawl queue with priority:

| Field | Type | Description |
|-------|------|-------------|
| id | INTEGER | Primary key |
| url | TEXT | Unique URL to crawl |
| depth | INTEGER | Crawl depth |
| referrer | TEXT | Referring URL |
| priority | INTEGER | Priority level (higher = first) |
| status | TEXT | Queue status (pending/processing/completed/failed) |
| created_at | INTEGER | When added to queue |
| attempts | INTEGER | Number of crawl attempts |
| error_message | TEXT | Last error if failed |

### Cookies Table
Stores cookies for authenticated crawling:

| Field | Type | Description |
|-------|------|-------------|
| id | INTEGER | Primary key |
| name | TEXT | Cookie name |
| value | TEXT | Cookie value |
| domain | TEXT | Cookie domain |
| path | TEXT | Cookie path |
| expires | INTEGER | Expiration timestamp |
| created_at | INTEGER | When cookie was stored |

## Storage Architecture

### Two-Tier Storage System

1. **Database Tier**: Metadata and queue management (SQLite)
2. **File System Tier**: Actual page content storage

### Content Hashing Strategy

- **Path Hash**: MD5 hash of URL for fast lookup
- **Content Hash**: SHA-256 hash of sanitized content for deduplication

### File Storage Layout

```
storage/
└── {domain}/
    └── {first2}/{next2}/
        └── {content_hash}/
            └── {version_hash}
```

## Crawler Architecture

### Browser-Based Crawling

Uses headless browser (Puppeteer) for:
- JavaScript rendering
- Dynamic content loading
- Login/authentication handling
- Cookie management

### Dynamic Content Handling

Multi-stage waiting strategy:
1. Initial page load (2-5 seconds)
2. Content selector detection
3. Scroll-triggered lazy loading
4. Login wall detection and fallback extraction

### Politeness Controls

- Random delays between requests (configurable range)
- Respects robots.txt (optional)
- Crawl-depth limiting
- Domain-based rate limiting

## HTML Sanitization

### Conservative Sanitization Strategy

Removes:
- `<script>` tags and inline scripts
- `on*` event handlers
- `javascript:` URLs
- `eval()` and similar functions

Preserves:
- HTML structure
- CSS styles and inline styles
- Images and media
- Links and navigation
- Form elements (without action attributes)

## Deduplication Strategy

### Content-Based Deduplication

Uses SHA-256 hash of sanitized HTML for:
- Queue deduplication (before crawling)
- Storage deduplication (after sanitization)
- Change detection (between versions)

### Hash Consistency

Same hash used for:
1. Queue deduplication check
2. File path generation
3. Version comparison
4. Database lookup

## Proxy Server Architecture

### Native HTTP Proxy

Serves archived content through:
- Domain-based URL routing
- On-the-fly content serving
- Static asset proxying
- No JavaScript execution (static only)

### Access URL Format

```
http://proxy-host/{domain}/{path}
```

## Queue Management

### Priority-Based Queue

Priority factors:
- Depth (shallower = higher priority)
- Domain (seed domain = higher priority)
- Freshness (new URLs = higher priority)

### Transactional Dequeue

Atomic operation:
1. Get highest priority pending item
2. Mark as processing in same transaction
3. Return item for crawling

## Version Control

### Version Tracking

Each page crawl creates:
- New version record in versions table
- New file in storage (only if content changed)
- content_hash comparison for change detection

### Change Detection

Compares:
- Content hash differences
- Size changes
- Title/description changes
- Classifies as new/updated/deleted

## Crawl Scheduling

### Configurable Scheduler

Features:
- Periodic full recrawls
- Incremental updates
- Domain-specific schedules
- Pause/resume capability

## Indexing Strategy

### Database Indexes

Key indexes for performance:
- `pages(url)` - Unique URL lookup
- `pages(domain)` - Domain-based queries
- `pages(path_hash)` - Fast path lookup
- `versions(page_id)` - Version history
- `queue(status, priority, created_at)` - Queue ordering
- `cookies(domain)` - Cookie lookup
