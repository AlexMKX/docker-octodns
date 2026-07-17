# Custom OctoDNS image: stock octodns core + the provider plugins our
# k3s DNS deployment needs (bind/RFC2136 + Cloudflare).
#
# The base image already ships these exact versions, but we re-pin them
# explicitly so the build is reproducible even if the floating base tag
# moves. No deployment config (config.yaml / subzone_source.py) is baked
# in here -- those are mounted by the k8s deployment via ConfigMap. This
# image is core + providers only.
FROM octodns/octodns:2026.07

# Pinned versions (resolved from PyPI, 2026-07).
RUN pip install --no-cache-dir \
      "octodns==1.21.0" \
      "octodns-bind==1.1.0" \
      "octodns-cloudflare==1.2.0"
