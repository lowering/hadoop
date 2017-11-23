#############################
#   Build Hadoop Image      #
#############################
FROM centos

# Install JDK Env
RUN yum install -y wget
RUN yum install -y vim
RUN wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
RUN yum install -y ant
RUN yum install -y net-tools
RUN yum install -y git
RUN wget -P ~/ --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u141-b15/336fa29ff2bb4ef291e347e091f7f4a7/jdk-8u141-linux-x64.tar.gz
RUN mkdir -p /usr/local/java/
RUN tar -xvf ~/jdk-8u141-linux-x64.tar.gz -C /usr/local/java/
RUN rm ~/jdk-8u141-linux-x64.tar.gz

# Setting JDK Env
ENV JAVA_HOME=/usr/local/java/jdk1.8.0_141
ENV JRE_HOME=${JAVA_HOME}/jre
ENV CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
ENV PATH=${JAVA_HOME}/bin:$PATH

# Install SSH 
RUN yum install -y openssh-server openssh-clients

# Generate key files
RUN ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
RUN ssh-keygen -q -t dsa -f /etc/ssh/ssh_host_ed25519_key  -N ''

# Login Localhost Without Password
RUN ssh-keygen -f /root/.ssh/id_rsa -N ''
RUN touch /root/.ssh/authorized_keys
RUN cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

# Set Password Of root
RUN echo "root:123456" | chpasswd

# Open the port 22
EXPOSE 22

# Install Hadoop
# Download Hadoop
RUN wget -P ~/ https://mirrors.aliyun.com/apache/hadoop/common/hadoop-2.7.4/hadoop-2.7.4.tar.gz
RUN mkdir -p /usr/local/hadoop/
RUN tar -xvf ~/hadoop-2.7.4.tar.gz -C /usr/local/hadoop/
RUN rm ~/hadoop-2.7.4.tar.gz
RUN mkdir -p /usr/local/hadoop/hadoop-2.7.4/temp
RUN mkdir -p /usr/local/hadoop/hadoop-2.7.4/nodes/data
RUN mkdir -p /usr/local/hadoop/hadoop-2.7.4/nodes/name

ADD etc/mapred-site.xml /usr/local/hadoop/hadoop-2.7.4/etc/hadoop/
ADD etc/core-site.xml /usr/local/hadoop/hadoop-2.7.4/etc/hadoop/
ADD etc/hdfs-site.xml /usr/local/hadoop/hadoop-2.7.4/etc/hadoop/

ENV HADOOP_HOME /usr/local/hadoop/hadoop-2.7.4
ENV HADOOP_CONFIG_HOME ${HADOOP_HOME}/etc/hadoop
ENV PATH ${HADOOP_HOME}/bin:$PATH
ENV PATH ${HADOOP_HOME}/sbin:$PATH:

RUN sed -i 's/\${JAVA_HOME}/\/usr\/local\/java\/jdk1.8.0_141/g' /usr/local/hadoop/hadoop-2.7.4/etc/hadoop/hadoop-env.sh
RUN yum install -y which
RUN /usr/local/hadoop/hadoop-2.7.4/bin/hadoop namenode -format

CMD ["/usr/sbin/sshd","-D"]
