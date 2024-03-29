#FROM nvidia/cuda:9.2-devel-ubuntu16.04
FROM nvidia/cuda:9.2-runtime-ubuntu16.04
MAINTAINER BlazingDB <percy@blazingdb.com>
LABEL Description="blazingdb/blazingsql is the official BlazingDB environment for BlazingSQL on NIVIDA RAPIDS." Vendor="BlazingDB" Version="1.0"

ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda/lib64

RUN apt-get update && \
    apt-get install -y --no-install-recommends libicu55 libcurl3 libssl1.0.0 zlib1g libuuid1 && \
    apt-get clean

COPY ./blazingsql-files/cudf/cpp/install/lib/libcudf.so /usr/local/cuda/lib64/
COPY ./blazingsql-files/cudf/cpp/install/lib/librmm.so /usr/local/cuda/lib64/

COPY ./blazingsql-files/nvstrings/lib/libNVCategory.so /usr/local/cuda/lib64/
COPY ./blazingsql-files/nvstrings/lib/libNVStrings.so /usr/local/cuda/lib64/

COPY ./blazingsql-files/testing-libgdf /usr/bin/testing-libgdf

# Orchestrator
COPY ./blazingsql-files/blazingdb_orchestator_service /usr/bin/

# If the user wants to communicate by unix socket need to mount his /tmp folder
VOLUME /tmp

# 8890 for Orchestrator, 8891 for Calcite, 8892 for RAL
#EXPOSE 8890
#EXPOSE 8891
EXPOSE 8892

EXPOSE 8001

EXPOSE 9000

EXPOSE 8889
EXPOSE 9001
EXPOSE 8891
EXPOSE 8890


COPY entrypoint.sh /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]

#CMD ["/usr/bin/testing-libgdf", "1", "172.0.0.1", "9000", "127.0.0.1", "8001"]
#CMD ["/usr/bin/blazingdb_orchestator_service"]
