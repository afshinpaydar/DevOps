yum install centos-release-scl-rh
yum --enablerepo=centos-sclo-rh-testing install source-to-image

docker pull registry.centos.org/dotnet/dotnet-21-centos7:latest


s2i build https://github.com/redhat-developer/s2i-dotnetcore-ex registry.centos.org/dotnet/dotnet-21-centos7:latest mywebapp -r dotnetcore-2.1 -e DOTNET_STARTUP_PROJECT=app -p always

#Test
docker run --rm -p 8080:8080 mywebapp


s2i build https://github.com/afshinpaydar/test.git registry.centos.org/dotnet/dotnet-21-centos7:latest afshin  -e DOTNET_STARTUP_PROJECT=app/SadTahli.WebApi/src/SadTahli.WebApi.csproj -p always

#https://github.com/redhat-developer/s2i-dotnetcore.git

#scp /home/mohsen/Documents/Soshyant/100Tahlil.zip soshya-openshift-master1:/root/s2i-dotnetcore/2.1/