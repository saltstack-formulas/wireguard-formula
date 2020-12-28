{%- set oscodename = grains['oscodename'] %}

debian-backports-repo:
  file.managed:
    - name: /etc/apt/sources.list.d/{{ oscodename }}-backports.list
    - contents: |
        deb http://deb.debian.org/debian {{ oscodename }}-backports main contrib non-free

debian-backports-repo-update:
  cmd.run:
    - name: apt-get update
    - onchanges:
      - file: debian-backports-repo
    - require:
      - file: debian-backports-repo
    - require_in:
      - pkg: wireguard-package-install-pkg-installed
