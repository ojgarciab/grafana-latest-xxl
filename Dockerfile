FROM debian:jessie
MAINTAINER Oscar Garcia oscar.github@linaresdigital.com

# inbuilt datasources:
# cloudwatch elasticsearch grafana graphite influxdb mixed opentsdb prometheus
# sql kairosdb

ENV GRAFANA_VERSION 3.0.0

COPY ./run.sh /run.sh

RUN \
  apt-get update && \
  apt-get -y --no-install-recommends install libfontconfig curl ca-certificates git && \
  curl https://grafanarel.s3.amazonaws.com/builds/grafana_latest_amd64.deb > /tmp/grafana.deb && \
  dpkg -i /tmp/grafana.deb && \
  rm /tmp/grafana.deb

RUN \
  curl -L https://github.com/tianon/gosu/releases/download/1.5/gosu-amd64 > /usr/sbin/gosu && \
  chmod +x /usr/sbin/gosu

RUN \
  ### plugin pie chart - ignored in 2.6 ###
  git clone https://github.com/grafana/panel-plugin-piechart.git /usr/local/src/panel-plugin-piechart && \
  echo '[plugin.piechart]' >> /etc/grafana/grafana.ini && \
  echo 'path = /usr/local/src/panel-plugin-piechart' >> /etc/grafana/grafana.ini && \
  ### zabbix ### && \
  git clone -b grafana-3.0 https://github.com/alexanderzobnin/grafana-zabbix /tmp/grafana-zabbix && \
  mv /tmp/grafana-zabbix/zabbix/ /usr/share/grafana/public/app/plugins/datasource/ && \
  rm -rf /tmp/grafana-zabbix/ && \
  ### atlas atsd bosun clouderamanager druid gnocchi ### && \
  git clone https://github.com/grafana/grafana-plugins /tmp/grafana-plugins && \
  rm -rf /tmp/grafana-plugins/datasources/zabbix && \
  mv /tmp/grafana-plugins/datasources/* /usr/share/grafana/public/app/plugins/datasource/ && \
  rm -rf /tmp/grafana-plugins && \
  ### PRTG ### && \
  git clone https://github.com/neuralfraud/grafana-prtg /tmp/grafana-prtg && \
  mv /tmp/grafana-prtg/PRTG/ /usr/share/grafana/public/app/plugins/datasource/ && \
  rm -rf /tmp/grafana-prtg && \
  ### ambari ### && \
  git clone https://github.com/u39kun/ambari-grafana /tmp/ambari-grafana && \
  mv /tmp/ambari-grafana/ambari/ /usr/share/grafana/public/app/plugins/datasource/ && \
  rm -rf /tmp/ambari-grafana && \
  ### dalmatinerdb ### && \
  git clone https://github.com/dalmatinerdb/dalmatiner-grafana-plugin /tmp/dalmatiner-grafana-plugin && \
  mv /tmp/dalmatiner-grafana-plugin/dalmatinerdb/ /usr/share/grafana/public/app/plugins/datasource/ && \
  rm -rf /tmp/dalmatiner-grafana-plugin && \
  ### opennms && \
  echo "deb http://debian.opennms.org opennms-17 main\ndeb-src http://debian.opennms.org opennms-17 main" > /etc/apt/sources.list.d/opennms.list && \
  curl -s https://debian.opennms.org/OPENNMS-GPG-KEY | apt-key add - && \   
  sleep 10 && \
  apt-get update && \
  apt-get install -y grafana-opennms-plugin && \
  rm -rf /etc/apt/sources.list.d/opennms.list && \
  ### kairosdb ### && \
  #git clone https://github.com/br0th3r/grafana2-kairosdb-datasource-plugin /tmp/grafana2-kairosdb-datasource-plugin && \
  #mv /tmp/grafana2-kairosdb-datasource-plugin/kairosdb/ /usr/share/grafana/public/app/plugins/datasource/ && \
  #rm -rf /tmp/grafana2-kairosdb-datasource-plugin && \
  echo "---"

RUN \
  ### branding && \
  sed -i 's#<title>Grafana</title>#<title>Grafana UdO RTVE</title>#g' /usr/share/grafana/public/views/index.html && \
  sed -i 's#<title>Grafana</title>#<title>Grafana UdO RTVE</title>#g' /usr/share/grafana/public/views/500.html && \
  sed -i 's#logo_transparent_200x75.png">#logo_transparent_200x75.png"><br />Grafana UdO RTVE<br /><small><a href="//sye-operacion.rtve.int/wiki/" target="_blank">Personalizado por la Unidad de Operación de RTVE</a></small>#g' /usr/share/grafana/public/app/partials/login.html && \
  sed -i 's#logo_transparent_200x75.png">#logo_transparent_200x75.png"><br />Grafana UdO RTVE<br /><small><a href="//sye-operacion.rtve.int/wiki/" target="_blank">Personalizado por la Unidad de Operación de RTVE</a></small>#g' /usr/share/grafana/public/app/app.js && \
  sed -i 's#logo_transparent_200x75.png">#logo_transparent_200x75.png"><br />Grafana UdO RTVE<br /><small><a href="//sye-operacion.rtve.int/wiki/" target="_blank">Personalizado por la Unidad de Operación de RTVE</a></small>#g' /usr/share/grafana/public/app/app*.js && \
  chmod +x /run.sh && \
  apt-get remove -y curl git && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

VOLUME ["/var/lib/grafana", "/var/log/grafana", "/etc/grafana"]

EXPOSE 3000

ENTRYPOINT ["/run.sh"]
