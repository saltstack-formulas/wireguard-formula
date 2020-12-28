# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import wireguard with context %}


{%- if 'init' in grains and grains['init'] == 'systemd' %}
{%-   for interface in wireguard.get('interfaces', {}).keys() %}
wireguard-service-clean-service-dead-{{ interface }}:
  service.dead:
    - name: {{ wireguard.service.name }}@{{ interface }}
    - enable: False
{%-   endfor %}
{%- endif %}

{%-  if grains['os_family'] == 'FreeBSD' %}
wireguard-service-clean-service-dead:
  service.dead:
    - name: {{ wireguard.service.name }}
    - sig: wireguard-go
    - enable: False

wireguard-service-clean-sysrc-absent:
  sysrc.absent:
    - name: wireguard_interfaces
    - require:
      - service: wireguard-service-clean-service-dead
{%- endif %}
