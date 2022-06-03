## Simple self-signed certificates generator

You can edit scripts and add certificate parameters (CN and etc) manually.

* `gen.sh` - saving certificates in to `certs` catalog

Script also can generate certs for:

* Nginx (`-n`)
* Monit (`-m`)

`solid` catalog, contains just divided functions to different script files:
* `sgen-conf.sh` - generate with custom ssl config
* `sgen-line.sh` - simple generator with one line
