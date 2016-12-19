FROM        debian
MAINTAINER  Martin Lehmann "martin@ml-solutions.org"
ENV         VERSION         0.7
ENV         TERM            linux
ENV         DEBIAN_FRONTEND noninteractive
ENV         CITM_HOST       "d41d8cd98f00b204e9800998ecf8427e" 
ENV         SIMBOL_PROFILE  "docker"
ENV         USER_USERNAME   "schtunt"
ENV         SIMBOL_PATH     "/opt/schtunt/simbol"
EXPOSE     22

#RUN /bin/bash -c '/bin/echo "nameserver 8.8.8.8" > /etc/resolv.conf'
RUN [ "apt-get", "update" ]
RUN [ "apt-get", "dist-upgrade", "--yes" ]
RUN [ "apt-get", "install", "--yes",      \
  "libbz2-dev", "libreadline-gplv2-dev", "libssl-dev" \
    ]
RUN [ "apt-get", "install", "--yes", \
  "coreutils", "make", "gcc",                    \
  "bash", "sed", "gawk",                         \
  "git", "haveged",                              \
  "wget", "curl", "bzip2", "vim", "sudo",     \
  "dnsutils",\
  "gnupg2", "pwgen", "xclip", \
  "iproute", "net-tools", "netcat", "socat", "tmux" \
]

RUN useradd --create-home --shell /bin/bash schtunt
RUN install -m 0755 -o schtunt -d /opt/schtunt
RUN /bin/bash -c '/bin/echo "schtunt ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'
USER schtunt
ENV PATH "/home/schtunt/bin:${PATH}"
RUN /bin/bash -c '/bin/echo "PATH=${HOME}/bin:${PATH}" >> ${HOME}/.bashrc'
RUN /bin/bash -c '/bin/echo "export CITM_HOST=\"d41d8cd98f00b204e9800998ecf8427e\"" >> ${HOME}/.bash_profile'
RUN /bin/bash -c '/bin/echo "PATH=${HOME}/bin:${PATH}" >> ${HOME}/.bash_profile'
RUN git clone https://github.com/schtunt/simbol.git ${SIMBOL_PATH}
WORKDIR ${SIMBOL_PATH}
RUN git checkout develop
RUN make install
RUN simbol py install
RUN simbol rb install
RUN simbol pl install

# unit testing
#RUN CONTEXT=installer MODULE=foo ${SIMBOL_PATH}/share/unit/citm script
#RUN CONTEXT=execute MODULE=core ${SIMBOL_PATH}/share/unit/citm script


USER root
ENTRYPOINT [ "/bin/bash" ]

# vim:syntax=ruby
