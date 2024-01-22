---
layout: liste
---
<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Company</th>
      <th>ASN</th>
      <th>IRC nick</th>
    </tr>
  </thead>
  <tbody>
  {% assign sorted = site.data.attendees_denogmeetup24-01 | sort_natural: 'name' %}
  {% for entry in sorted %}
    <tr>
      <td>{{ entry.name }}</td>
      <td>{{ entry.company }}</td>
      <td>
        {% if entry.asn %}
          {% if entry.asn contains ',' %}
            {% assign asns=entry.asn | split: ',' %}
          {% else %}
            {% assign asns=entry.asn | split: ' ' %}
          {% endif %}
          {% for asn in asns %}
          <a href="https://apps.db.ripe.net/db-web-ui/query?searchtext=AS{{ asn|strip|remove:"AS" }}&rflag=true&types=aut-num" target="_blank">{{ asn|remove:"AS" }}</a><br>
          {% endfor %}
        {% endif %}
      </td>
      <td>{{ entry.irc }}</td>
    </tr>
  {% endfor %}
  </tbody>
</table>

<script>
const getCellValue = (tr, idx) => tr.children[idx].innerText || tr.children[idx].textContent;

const comparer = (idx, asc) => (a, b) => ((v1, v2) =>
    v1 !== '' && v2 !== '' && !isNaN(v1) && !isNaN(v2) ? v1 - v2 : v1.toString().localeCompare(v2)
    )(getCellValue(asc ? a : b, idx), getCellValue(asc ? b : a, idx));

document.querySelectorAll('th').forEach(th => th.addEventListener('click', (() => {
    const table = th.closest('table').querySelector('tbody');
    Array.from(table.querySelectorAll('tr'))
        .sort(comparer(Array.from(th.parentNode.children).indexOf(th), this.asc = !this.asc))
        .forEach(tr => table.appendChild(tr) );
})));
</script>
