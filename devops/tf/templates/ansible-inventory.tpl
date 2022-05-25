[webapps]
%{ for host in webapps ~}
${host}
%{ endfor ~}

[loadbalancer]
${loadbalancer}

[redis]
${redis}

[workers]
%{ for host in workers ~}
${host}
%{ endfor ~}