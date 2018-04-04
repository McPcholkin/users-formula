{% from "users/map.jinja" import users with context %}
include:
  - users
  - mc

{% for name, user in pillar.get('users', {}).items() if user.absent is not defined or not user.absent %}
{%- set current = salt.user.info(name) -%}
{%- if user == None -%}
{%- set user = {} -%}
{%- endif -%}
{%- set home = user.get('home', current.get('home', "/home/%s" % name)) -%}
{%- set manage_ini = user.get('manage_mc_ini', False) -%}
{%- set manage_panels = user.get('manage_mc_panels', False) -%}
{%- if 'prime_group' in user and 'name' in user['prime_group'] %}
{%- set user_group = user.prime_group.name -%}
{%- else -%}
{%- set user_group = name -%}
{%- endif %}
{%- if manage_ini -%}
users_{{ name }}_user_mc_ini:
  file.managed:
    - name: {{ home }}/.config/mc/ini
    - user: {{ name }}
    - group: {{ user_group }}
    - mode: 644
    - template: jinja
    - source:
      - salt://users/files/mc/{{ name }}/ini
      - salt://users/files/mc/ini.jinja
    - defaults:
      username: {{ name }}
{% endif %}
{%- if manage_panels -%}
users_{{ name }}_user_mc_panels:
  file.managed:
    - name: {{ home }}/.config/mc/panels.ini
    - user: {{ name }}
    - group: {{ user_group }}
    - mode: 644
    - template: jinja
    - source:
      - salt://users/files/mc/{{ name }}/panels.ini
      - salt://users/files/mc/panels.ini.jinja
    - defaults:
      username: {{ name }}

{% endif %}
{% endfor %}
