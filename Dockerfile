# jekyll-centos7
FROM centos/ruby-24-centos7
MAINTAINER John McCawley <john.mccawley@thedigitalgarage.io>


# Inform about software versions being used inside the builder
ENV JEKYLL_VERSION=3.2.1

# Labels used in OpenShift to describe the builder image
LABEL io.k8s.description="Platform for building Jekyll-based static sites" \
      io.k8s.display-name="Jekyll 3.2.1" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,jekyll,3.2.1,static"

# Install required package
# RUN yum install -y centos-release-scl && \
#    INSTALL_PKGS="rh-ruby23 rh-ruby23-ruby-devel rh-ruby23-rubygem-rake rh-ruby23-rubygem-bundler rh-nginx110 rh-nodejs6 rh-nodejs6-npm" && \
#    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && rpm -V $INSTALL_PKGS && \
#    yum clean all -y

USER root

# Install Jekyll and Bundler with RubyGems
 RUN /bin/bash -l -c "gem install jekyll"
 RUN /bin/bash -l -c "gem install bundler"

# Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7
# image sets io.openshift.s2i.scripts-url label that way
COPY ./.s2i/bin/ /usr/libexec/s2i

# Create directories for nginx
 RUN mkdir -p /opt/app-root/etc/nginx && \
 mkdir -p /opt/app-root/var/run/nginx && \
 mkdir -p /opt/app-root/var/log/nginx && \
 mkdir -p /opt/app-root/var/lib/nginx/tmp

# Copy the nginx configuration
# COPY ./etc /opt/app-root/etc

# Link the nginx logs to stdout/stderr
# RUN ln -sf /dev/stdout /var/log/nginx/error.log && \
# ln -sf /dev/stdout /opt/app-root/var/log/nginx/access.log && \
# ln -sf /dev/stderr /opt/app-root/var/log/nginx/error.log

# Chown /opt/app-root to the deployment user and drop privileges
RUN chown -R 1001:0 /opt/app-root && chmod -R og+rwx /opt/app-root
USER 1001

# Set the default port for applications built using this image
EXPOSE 8080

# Set the default CMD for the image when executed directly
CMD ["/usr/libexec/s2i/usage"]
