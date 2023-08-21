# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import wireguard with context %}

include:
  - {{ sls_config_file }}

{%- set interfaces = wireguard.get('interfaces', {}).keys() %}

{%- if 'init' in grains and grains['init'] == 'systemd' %}
{%-   for interface in interfaces %}
wireguard-service-running-service-running-{{ interface }}:
  service.running:
    - name: {{ wireguard.service.name }}@{{ interface }}
    - enable: True
    - watch:
      - sls: {{ sls_config_file }}
      - file: wireguard-config-file-interface-{{ interface }}-config
{%-   endfor %}
{%- endif %}

{%-  if grains['os_family'] == 'FreeBSD' %}

wireguard-service-running-sysrc-managed:
  sysrc.managed:
    - name: wireguard_interfaces
    - value: "{{ interfaces|join(' ') }}"

wireguard-service-running-service-enabled:
  service.enabled:
    - name: {{ wireguard.service.name }}
    - watch:
      - sysrc: wireguard-service-running-sysrc-managed

wireguard-service-running-service-running-trigger:
  cmd.run:
    - name: /bin/sh -c 'exit 0'
    - unless: service {{ wireguard.service.name }} onestatus

wireguard-service-running-service-running:
  cmd.run:
    # Close file descriptors so we don't end up with a <defuct> process
    - name: sh -c "service {{ wireguard.service.name }} onerestart 0<&- >/dev/null 2>&1"
    - onchanges:
      - sysrc: wireguard-service-running-sysrc-managed
      - service: wireguard-service-running-service-enabled
      - cmd: wireguard-service-running-service-running-trigger
      - sls: {{ sls_config_file }}
{%-   for interface in interfaces %}
      - file: wireguard-config-file-interface-{{ interface }}-config
{%-   endfor %}
{%- endif %}
