# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import wireguard with context %}

wireguard-service-clean-service-dead:
  service.dead:
    - name: {{ wireguard.service.name }}
    - enable: False
