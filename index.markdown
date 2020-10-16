---
layout: liste
---
<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Firma</th>
      <th>ASN</th>
      <th>IRC-Nickname</th>
    </tr>
  </thead>
  <tbody>
  {% assign sorted = site.data.attendees | sort_natural: 'name' %}
  {% for entry in sorted %}
    <tr>
      <td>{{ entry.name }}</td>
      <td>{{ entry.company }}</td>
      <td>
        {% if entry.asn %}
          {% assign asns=entry.asn | split: ',' %}
          {% for asn in asns %}
          <a href="https://apps.db.ripe.net/search/query.html?searchtext=AS{{ asn|strip }}&flags=r&types=AUT_NUM" target="_blank">{{ asn }}</a><br>
          {% endfor %}
        {% endif %}
      </td>
      <td>{{ entry.irc }}</td>
    </tr>
  {% endfor %}
  </tbody>
</table>
