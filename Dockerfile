FROM rroemhild/ejabberd
ADD ./ejabberd.yml.tpl /opt/ejabberd/conf/ejabberd.yml.tpl
ADD ./ejabberd.yml.tpl /opt/ejabberd/conf/ejabberdctl.cfg.tpl
