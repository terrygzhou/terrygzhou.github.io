---
layout: default
title: Posts
permalink: /posts/
---

<h2>All Posts</h2>

<ul>
{% for post in site.posts %}
  <li>
    <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
    <span>{{ post.date | date: "%B %-d, %Y" }}</span>
    <span class="post-card__views">
      <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
      <span data-views-count data-path="{{ post.url | relative_url }}">…</span>
    </span>
  </li>
{% endfor %}
</ul>
