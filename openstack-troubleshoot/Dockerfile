FROM python:3.6-slim-buster
RUN apt update && \
    apt -y install --no-install-recommends curl httpie git \
        tcptraceroute && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY curltime /usr/local/bin/curltime
RUN openstack complete | tee /etc/bash_completion.d/osc.bash_completion > /dev/null
CMD ["bash"]
