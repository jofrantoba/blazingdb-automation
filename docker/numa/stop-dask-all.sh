#!/bin/bash

echo "### docker rm all ###"
nvidia-docker rm -f  bzsql_worker1 bzsql_worker2 bzsql_worker3 bzsql_worker4
#nvidia-docker rm -f  bzsql_worker5 bzsql_worker6 bzsql_worker7 bzsql_worker8
#nvidia-docker rm -f  bzsql_scheduler
