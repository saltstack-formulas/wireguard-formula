# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import wireguard with context %}

{%- for repo_name, repo in wireguard.pkg.repos.items() %}
wireguard-package-install-repo-{{ repo_name }}:
  pkgrepo.managed:
    - name: {{ repo_name }}
    {%- for key, value in repo.items() %}
      {%- if value is string %}
    - {{ key }}: {{ value | replace('\n', '') }}
      {%- else %}
    - {{ key }}: {{ value }}
      {%- endif %}
    {%- endfor %}
{%- endfor %}

{%- if wireguard.pkg.pkgs|length > 0 %}
  {%- for pkg_name, pkg in wireguard.pkg.pkgs.items() %}
wireguard-package-install-pkg-{{ pkg_name }}-installed:
  pkg.installed:
    - name: {{ pkg_name }}
    {%- if pkg.fromrepo is defined %}
    - fromrepo: {{ pkg.fromrepo }}
    - require:
      - pkgrepo: wireguard-package-install-repo-{{ pkg.fromrepo }}
    {%- endif %}
  {%- endfor %}
{%- else %}
wireguard-package-install-pkg-installed:
  pkg.installed:
    - name: {{ wireguard.pkg.name }}
{%- endif %}