import { createHash } from 'crypto';

interface CacheEntry<T> {
    data: T;
    timestamp: number;
    ttl: number; // Time to live in milliseconds
}

class GitHubCache {
    private cache = new Map<string, CacheEntry<any>>();
    private readonly DEFAULT_TTL = 5 * 60 * 1000; // 5 minutes
    private readonly REPO_STATS_TTL = 2 * 60 * 1000; // 2 minutes for repo stats
    private readonly CONTRIBUTORS_TTL = 10 * 60 * 1000; // 10 minutes for contributors
    
    private generateKey(url: string, headers: Record<string, string>): string {
        const keyData = `${url}:${JSON.stringify(headers)}`;
        return createHash('sha256').update(keyData).digest('hex');
    }
    
    private isExpired(entry: CacheEntry<any>): boolean {
        return Date.now() - entry.timestamp > entry.ttl;
    }
    
    private getTTL(url: string): number {
        if (url.includes('/repos/') && !url.includes('/commits') && !url.includes('/contents')) {
            return this.REPO_STATS_TTL;
        }
        if (url.includes('/contributors')) {
            return this.CONTRIBUTORS_TTL;
        }
        return this.DEFAULT_TTL;
    }
    
    async get<T>(url: string, headers: Record<string, string>): Promise<T | null> {
        const key = this.generateKey(url, headers);
        const entry = this.cache.get(key);
        
        if (!entry || this.isExpired(entry)) {
            this.cache.delete(key);
            return null;
        }
        
        console.log(`🎯 Cache HIT for ${url}`);
        return entry.data;
    }
    
    set<T>(url: string, headers: Record<string, string>, data: T): void {
        const key = this.generateKey(url, headers);
        const ttl = this.getTTL(url);
        
        this.cache.set(key, {
            data,
            timestamp: Date.now(),
            ttl
        });
        
        console.log(`💾 Cache SET for ${url} (TTL: ${ttl}ms)`);
    }
    
    clear(): void {
        this.cache.clear();
        console.log('🧹 Cache cleared');
    }
    
    // Cleanup expired entries
    cleanup(): void {
        const now = Date.now();
        let cleanedCount = 0;
        
        for (const [key, entry] of this.cache.entries()) {
            if (this.isExpired(entry)) {
                this.cache.delete(key);
                cleanedCount++;
            }
        }
        
        if (cleanedCount > 0) {
            console.log(`🧹 Cleaned ${cleanedCount} expired cache entries`);
        }
    }
    
    getStats(): { size: number; hitRatio: number } {
        return {
            size: this.cache.size,
            hitRatio: 0 // Would need to track hits/misses for this
        };
    }
}

export const githubCache = new GitHubCache();

// Enhanced fetch with caching
export async function cachedFetch(url: string, options: RequestInit = {}): Promise<Response> {
    const headers = (options.headers as Record<string, string>) || {};
    
    // Try to get from cache first
    const cachedData = await githubCache.get<any>(url, headers);
    if (cachedData) {
        return new Response(JSON.stringify(cachedData), {
            status: 200,
            headers: { 'Content-Type': 'application/json' }
        });
    }
    
    // If not in cache, make the actual request
    const response = await fetch(url, options);
    
    if (response.ok) {
        const data = await response.json();
        githubCache.set(url, headers, data);
        
        // Return a new response with the same data
        return new Response(JSON.stringify(data), {
            status: response.status,
            headers: { 'Content-Type': 'application/json' }
        });
    }
    
    return response;
}

// Cleanup task to run periodically
setInterval(() => {
    githubCache.cleanup();
}, 60000); // Run every minute
