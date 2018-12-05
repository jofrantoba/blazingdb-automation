FROM blazingdb/blazingsql:latest

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/blazingsql is the official BlazingDB environment for BlazingSQL on NIVIDA RAPIDS." Vendor="BlazingDB" Version="1.0"

RUN source activate cudf && pip install pydrill

# Create the user 'tester'
RUN useradd -ms /bin/bash kharoly

USER kharoly
WORKDIR /home/kharoly/

RUN mkdir -p /home/kharoly/blazing

# For the tester user
VOLUME /home/kharoly/blazing

# nvidia-docker build -t blazingsqltest
# nvidia-docker run --name bzsqlcontainer --rm -p 8884:8888 -p 8787:8787 -p 8786:8786 -p 9001:9001 -v /home/kharoly/:/home/kharoly/ -ti blazingsqltest bash
# 
# Start up BlazingSQL
# nvidia-docker exec bzsqlcontainer /usr/bin/testing-libgdf
# nvidia-docker exec bzsqlcontainer /usr/bin/blazingdb_orchestator_service
# nvidia-docker exec bzsqlcontainer java -jar /usr/bin/BlazingCalcite.jar