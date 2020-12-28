{%- set oscodename = grains['oscodename'] %}

debian-backports-pkgrepo-managed:
pkgrepo.managed:
- humanname: {{ oscodename }} backports
- name: deb http://deb.debian.org/debian {{ oscodename }}-backports
- comps: main,contrib,non-free
- file: /etc/apt/sources.list.d/{{ oscodename }}-backports.list
- enabled: True
- clean_file: True
{%- if oscodename == 'buster' and 'wireguard' in salt['pillar.get']('features', {}) %}
- require_in:
- pkg: wireguard-package-install-pkg-installed
{%- endif %}
