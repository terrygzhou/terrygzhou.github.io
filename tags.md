---
layout: default
title: Tags
permalink: /tags/
---

<h2>Tags</h2>

{% capture tags %}
  {% for tag in site.tags %}
    <a href="#{{ tag[0] | downcase | slugify }}">{{ tag[0] }}</a>
  {% endfor %}
{% endcapture %}

<ul>
{% for tag in site.tags %}
  <li>
    <strong>{{ tag[0] }}</strong>
    <ul>
      {% for post in tag[1] %}
        <li><a href="{{ post.url | relative_url }}">{{ post.title }}</a></li>
      {% endfor %}
    </ul>
  </li>
{% endfor %}
</ul>
